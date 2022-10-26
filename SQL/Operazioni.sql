USE SmartBuildings;

-- =============================================================================================================== --
-- 													OPERATION 1        		  									   --
-- Dato in ingresso il nome di un materiale, la quantità utilizzata e l'id del lavoro a cui fa riferimento si      --
-- inserisce il nuovo record in MaterialeUtilizzato. In caso il materiale non sia presente lo crea (è stata creata --	
-- una procedura sotto per aggiornare il materiale appena creato), in caso il lavoro non sia presente              --
-- l'inserimento fallisce. Invece in caso il record esista già viene solamente aggiornata la quantità.             --
-- Fallisce anche nel caso la quantità richiesta per il lavoro non sia presente in magazzino.                      --
-- =============================================================================================================== --

DROP PROCEDURE IF EXISTS inserimentoMaterialeUtilizzato;
DELIMITER $$
CREATE PROCEDURE inserimentoMaterialeUtilizzato(IN _nome VARCHAR(45), IN _quantita INT UNSIGNED, IN _IDlavoro INT)
BEGIN
    # VAR
    DECLARE idMateriale INT DEFAULT NULL;
    DECLARE idLAvoro INT DEFAULT NULL;
	DECLARE quantitaRimasta INT DEFAULT 0;
	DECLARE tmp INT DEFAULT NULL;
    
    # MAIN
	-- Cerchiamo se il lavoro è presente
	SELECT LPE.`ID` INTO idLavoro
	FROM `LavoroProgettoEdilizio` LPE WHERE LPE.`ID` = _IDlavoro;
	
	-- Se il lavoro non è presente
	IF idLavoro IS NULL
	THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Il LavoroProgettoEdilizio inserito non è valido';
	END IF;
    
    -- Cerchiamo se il materiale è presente
    SELECT M.`ID` INTO idMateriale
    FROM `Materiale` M WHERE M.`nome` = _nome;
    
    IF idMateriale IS NULL
	THEN 
		-- Inserisce il nuovo materiale
		-- In questo caso l'operazione continua sotto con un'altra procedura per aggiornare il nuovo materiale appena inserito
		-- Si suppone che la quantità richiesta sia la quantità disponibile al momento del nuovo materiale quindi si può lasciare 0 di default alla quantita
		INSERT INTO `Materiale`(`nome`) VALUES(_nome);	

		SELECT M.`ID` INTO idMateriale 
		FROM `Materiale` M WHERE M.`nome` = _nome;
	END IF;
	
	-- Se sia il materiale che il lavoro sono presenti viene controllato che la quantità rimasta sia 
	-- maggiore o uguale a quella richiesta per il lavoro
	SELECT M.quantita INTO quantitaRimasta
	FROM `Materiale` M WHERE M.`nome` = _nome;
	
	IF quantitaRimasta < _quantita
	THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Quantita rimasta insufficiente';
	ELSE	
		UPDATE `Materiale` M SET M.`quantita` = M.`quantita` - _quantita 
		WHERE M.`nome` = _nome;
	END IF;

	-- Viene controllato se il lavoro è già presente, in caso affermativo si modifca solamente la quantita
	SELECT COUNT(1) INTO tmp
	FROM `MaterialeUtilzzato` MU WHERE MU.`materiale` = idMateriale AND MU.`lavoro`= _IDlavoro;
	
	IF tmp IS NULL 
	THEN -- inserimento del nuovo materiale utilizzato
		INSERT INTO `MaterialeUtilizzato` VALUES (_IDlavoro, idMateriale, _quantita);
	ELSE -- aggiornamento
		UPDATE `MaterialeUtilizzato` MU SET MU.`quantita` = MU.`quantita` + _quantita
		WHERE MU.`materiale` = idMateriale AND MU.`lavoro`= _IDlavoro;
	END IF;
	
END $$
DELIMITER ;

-- Procedura di aggiornamento materiale, può essere usata anche per inserire un nuovo materiale
DROP PROCEDURE IF EXISTS aggiornamentoMateriale;
DELIMITER $$
CREATE PROCEDURE aggiornamentoMateriale(IN _nome VARCHAR(45), IN _cod_lotto INT UNSIGNED, IN _fornitore VARCHAR(45), IN _lunghezza DOUBLE, IN _larghezza DOUBLE, IN _altezza DOUBLE,
										IN _costituzione VARCHAR(45), IN _costo DOUBLE, IN _unita VARCHAR(4), IN _data_acquisto DATE, IN _quantita DOUBLE, IN _colore VARCHAR(25))
BEGIN
		#VAR
        DECLARE idMateriale INT DEFAULT NULL;
		
        #MAIN
        SELECT M.`ID` INTO idMateriale
		FROM `Materiale` M WHERE M.`nome` = _nome;
		
		IF idMateriale IS NULL
		THEN -- se non è prensente lo crea
			INSERT INTO `Materiale` (`nome`, `cod_lotto`, `fornitore`, `larghezza`, `lunghezza`, `altezza`, `costituzione`, `costo`, `unita`, `data_acquisto`, `quantita`, `colore`) 
									VALUES (_nome, _cod_lotto, _fornitore, _larghezza, _lunghezza, _altezza,
								            _costituzione, _costo, _unita, _data_acquisto, _quantita, _colore);
		ELSE -- se è presente lo aggiorna
			UPDATE `Materiale` M 
			SET M.`quantita` = _quantita, M.`costo` = _costo, M.`unita` = _unita, M.`larghezza` = _larghezza,
			    M.`lunghezza` = _lunghezza, M.`altezza` = _altezza, M.`costituzione` = _costituzione, M.`colore` = _colore,
				M.`fornitore`= _fornitore, M.`data_acquisto` = _data_acquisto, M.`cod_lotto` = _cod_lotto
			WHERE M.`ID` = idMateriale;
        END IF;
        
END $$
DELIMITER ;

-- =============================================================================================================== --
-- 													OPERATION 2        		  									   --
-- Dato in ingresso il codice fiscale di un lavoratore calcola il costo totale della manodopera del dipendente,    --
-- suddiviso per ogni progetto. Tiene conto della maggiorzione del 30% in caso di ore di straordinario.                                         --
-- =============================================================================================================== --

DROP PROCEDURE IF EXISTS calcoloCostoManodopera;
DELIMITER $$
CREATE PROCEDURE calcoloCostoManodopera(IN _cfOperaio VARCHAR(16), OUT _costo DOUBLE) 
BEGIN
    # Se il lavoratore inserito non è presente si interrompe l'esecuzione
    IF NOT EXISTS (SELECT 1 FROM `Lavoratore` L WHERE L.`CF` = _cfOperaio)
	THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Lavoratore non presente';
	END IF;
		
    DROP TABLE IF EXISTS costoManodoperaProgetto; 
    CREATE TABLE costoManodoperaProgetto (
		operaio VARCHAR(16) NOT NULL, 
        progetto INT NOT NULL,
        costo DOUBLE,
        PRIMARY KEY(operaio, progetto)
    );
    
    WITH OreLavoratoreProgetto AS (
		SELECT L.`CF` as operaio, PE.`codice` as progetto, T.`ora_fine` - T.`ora_inizio` as oreLavorate
		FROM `ProgettoEdilizio` PE
		JOIN `StadioDiAvanzamento` SDA ON SDA.`progetto_edilizio` = PE.`codice`
		JOIN `LavoroProgettoEdilizio` LPE ON LPE.`stadio` = SDA.`ID`
		JOIN `PartecipazioneLavoratoreLavoro` PLL ON PLL.`lavoro` = LPE.`ID`
		JOIN `SupervisioneLavoro` SL ON SL.`lavoro` = LPE.`ID`
		JOIN `Lavoratore` L ON L.`CF` = PLL.`lavoratore` OR L.`CF` = SL.`lavoratore`
		JOIN `LavoratoreDirigeTurno` LDT ON LDT.`capo_turno` = L.`CF`
		JOIN `SvolgimentoTurno` ST ON ST.`lavoratore` = L.`CF`
		JOIN `Turno` T ON (T.`giorno` = ST.`giorno` AND T.`ora_inizio` = ST.`ora_inizio` AND T.`ora_fine` = ST.`ora_fine`) 
					   OR (T.`giorno` = LDT.`giorno` AND T.`ora_inizio` = LDT.`ora_inizio` AND T.`ora_fine` = LDT.`ora_fine`)
		GROUP BY L.`CF`, PE.`codice`, T.`giorno`;
    )
    SELECT * FROM ProgettoEdilizio;
    
    WITH oreLavorateProgetto AS (
		SELECT L.`CF` as operaio, PE.`codice` as progetto, SUM(HOUR(T.`ora_fine`) - HOUR(T.`ora_inizio`)), T.`giorno`
		FROM `ProgettoEdilizio` PE
		JOIN `StadioDiAvanzamento` SDA ON SDA.`progetto_edilizio` = PE.`codice`
		JOIN `LavoroProgettoEdilizio` LPE ON LPE.`stadio` = SDA.`ID`
		JOIN `PartecipazioneLavoratoreLavoro` PLL ON PLL.`lavoro` = LPE.`ID`
		JOIN `SupervisioneLavoro` SL ON SL.`lavoro` = LPE.`ID`
		JOIN `Lavoratore` L ON L.`CF` = PLL.`lavoratore` OR L.`CF` = SL.`lavoratore`
		JOIN `LavoratoreDirigeTurno` LDT ON LDT.`capo_turno` = L.`CF`
		JOIN `SvolgimentoTurno` ST ON ST.`lavoratore` = L.`CF`
		JOIN `Turno` T ON (T.`giorno` = ST.`giorno` AND T.`ora_inizio` = ST.`ora_inizio` AND T.`ora_fine` = ST.`ora_fine`) 
					   OR (T.`giorno` = LDT.`giorno` AND T.`ora_inizio` = LDT.`ora_inizio` AND T.`ora_fine` = LDT.`ora_fine`)
		GROUP BY L.`CF`, PE.`codice`, T.`giorno`
	)
    INSERT INTO costoManodoperaProgetto(operaio, progetto, costo) 
    SELECT OLP.`operaio`, OLP.`progetto`,  
		SUM(IF(OLP.oreLavorate <= 8, (L.`retribuzione_oraria`*OLP.`oreLavorate`)), 
			-- else
			(L.`retribuzione_oraria`*8+(L.`retribuzione_oraria`*1.3*(OLP.`oreLavorate` - 8)))) AS costo 
    FROM oreLavorateProgetto OLP
    JOIN Lavoratore L ON L.`CF` = OLP.`operaio`
	GROUP BY OLP.`operaio`, OLP.`progetto`, OLP.`giorno`;
END $$
DELIMITER ;

-- ================================================================================ --
--                                   OPERATION 3                                    --
-- ================================================================================ --

-- ================================================================================ --
--                                   OPERATION 4                                    --
-- ================================================================================ --

-- ================================================================================ --
--                                   OPERATION 5                                    --
-- ================================================================================ --

-- ================================================================================ --
--                                   OPERATION 6                                    --
-- ================================================================================ --

-- ================================================================================ --
--                                   OPERATION 7                                    --
-- ================================================================================ --

-- ================================================================================ --
--                                   OPERATION 8                                    --
-- ================================================================================ --

