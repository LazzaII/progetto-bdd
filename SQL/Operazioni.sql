# Naturalmente il file è ancora vuoto ma almeno è pronto su github [sembra che con operazioni si intenda solo procedure e funzioni ma informiamoci]
# [mi sono basato sui progetti vecchi]
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
CREATE PROCEDURE aggiornamentoMateriale(IN _nome INT, IN _quantita INT UNSIGNED, IN _costo INT, IN _unita VARCHAR(4), IN _larghezza INT, IN _lunghezza INT,
										IN _altezza INT, IN _costituzione INT, IN _colore VARCHAR(45), IN _fornitore VARCHAR(45), IN _data_acquisto DATE, IN _cod_lotto INT)
BEGIN
		#VAR
        DECLARE idMateriale INT DEFAULT NULL;
		
        #MAIN
        SELECT M.`ID` INTO idMateriale
		FROM `Materiale` M WHERE M.`nome` = _nome;
		
		IF idMateriale IS NULL
		THEN -- se non è prensente lo crea
			INSERT INTO `Materiale` VALUES (_nome, _cod_lotto, _fornitore, _larghezza, _lunghezza, _altezza,
											_costituzione, _costituzione, _unita, _data_acquisto, _quantita);
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
-- Dato in ingresso l'id di un dipendente calcola il costo totale della manodopera del dipendente, tiene conto     --
-- della maggiorzione del 30% in caso di ore di straordinario.                                                     --
-- =============================================================================================================== --

DROP PROCEDURE IF EXISTS calcoloCostoManodopera;
DELIMITER $$
CREATE PROCEDURE calcoloCostoManodopera(IN _idOperaio INT) 
BEGIN
	
    IF NOT EXISTS (SELECT 1 FROM `Lavoratore` L WHERE L.`ID` = _idOperaio)
	THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Operaio non presente';
	END IF;
		
    
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

