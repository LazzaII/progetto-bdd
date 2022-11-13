USE SmartBuildings;

-- =============================================================================================================== --
-- 												FUNZIONI DI UTILITÀ       		  							       --
-- Funzione per il calcolo del costo giornaliero della manodopera, tiene conto della maggiorazione per gli         --
-- straordinari 																								   --
-- =============================================================================================================== --
DROP FUNCTION IF EXISTS costoManodoperaGiornaliera;
DELIMITER $$
CREATE FUNCTION costoManodoperaGiornaliera (minutiLavorati INT, retribuzione DOUBLE)
RETURNS DOUBLE DETERMINISTIC 
BEGIN
	#MAIN
	IF (minutiLavorati/60) <= 8 -- si controlla se ha eseguito ore di straordinario
    THEN 
		RETURN retribuzione * minutiLavorati/60;
	ELSE
		RETURN retribuzione * 8 + (retribuzione * 1.3 *((minutiLavorati/60) - 8)); -- maggiorazione del 30% per gli straordinari
	END IF;
    
END $$
DELIMITER ;
-- =============================================================================================================== --
-- 											  FINE FUNZIONI UTILITÀ        		  								   --
-- =============================================================================================================== --

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
	DECLARE quantitaRimasta INT DEFAULT 0;
	DECLARE tmp INT DEFAULT NULL;
    
    # MAIN
	-- controllo se il lavoro è presente
	IF NOT EXISTS (SELECT 1 FROM `LavoroProgettoEdilizio` LPE WHERE LPE.`ID` = _IDlavoro)
	THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] LavoroProgettoEdilizio non presente';
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

-- Procedura di aggiornamento materiale, in caso il materiale non sia presente lo aggiunge
DROP PROCEDURE IF EXISTS valorizzazioneMateriale;
DELIMITER $$
CREATE PROCEDURE valorizzazioneMateriale(IN _nome VARCHAR(45), IN _cod_lotto INT UNSIGNED, IN _fornitore VARCHAR(45), IN _lunghezza DOUBLE, IN _larghezza DOUBLE, IN _altezza DOUBLE,
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
-- suddiviso per ogni progetto e il costo totale, restituisce un result set. Tiene conto della maggiorzione del    --
-- 30% in caso di ore di straordinario.                                                                            --
-- =============================================================================================================== --

DROP PROCEDURE IF EXISTS calcoloCostoManodopera;
DELIMITER $$
CREATE PROCEDURE calcoloCostoManodopera(IN _cfOperaio VARCHAR(16)) 
BEGIN
	# MAIN
    -- Se il lavoratore inserito non è presente si interrompe l esecuzione
    IF NOT EXISTS (SELECT 1 FROM `Lavoratore` L WHERE L.`CF` = _cfOperaio)
	THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Lavoratore non presente';
	END IF;

    WITH oreLavorateProgetto AS (  
		SELECT L.`CF` AS operaio, PE.`codice` AS progetto, SUM(TIMESTAMPDIFF(MINUTE, CONCAT('0000-01-01 ', T.`ora_fine`), CONCAT('0000-01-01 ', T.`ora_inizio`))) AS minutiLavorati
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
		WHERE L.`CF` = _cfOperaio
		GROUP BY PE.`codice`, T.`giorno`
	)
    SELECT OLP.operaio, OLP.progetto, SUM(costoManodoperaGiornaliera(OLP.minutiLavorati, L.`retribuzione_oraria`)) AS Costo
    FROM oreLavorateProgetto OLP
    JOIN Lavoratore L ON L.`CF` = OLP.operaio
	GROUP BY OLP.progetto WITH ROLLUP; 
END $$
DELIMITER ;

-- =============================================================================================================== --
-- 													OPERATION 3        		  									   --
-- Dato in ingresso un lavoratore (ID), la mansione, il giorno, ora fine e inizio inserisce il turno lavorativo    --
-- nel database. La procedura controlla che un lavoratore non stia svolgendo un altra mansione nelle stesse ore    --
-- e controlla che il totale delle ore lavorate durante la giornata non sia superiore a 13 numero massimo fissato  --
-- per legge. Se non è presente un turno con quella mansione procede a crearla.									   --																   														
-- =============================================================================================================== --

DROP PROCEDURE IF EXISTS mansioneLavorata;
DELIMITER $$
CREATE PROCEDURE mansioneLavorata(IN _cfOperaio VARCHAR(16), IN _mansione VARCHAR(45), IN _giorno DATE, IN _inizio INT, IN _fine INT)
BEGIN
	# VAR
	DECLARE nOre INT DEFAULT NULL;

	# MAIN
	--  Se il lavoratore inserito non è presente si interrompe l esecuzione
    IF NOT EXISTS ( SELECT 1 FROM `Lavoratore` L WHERE L.`CF` = _cfOperaio)
	THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Lavoratore non presente';
	END IF;

	-- Se uno dei dati inseriti del turno è nullo esce
	IF _mansione IS NULL OR _giorno IS NULL OR _inizio IS NULL OR _fine IS NULL OR _inizio > _fine
	THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Dati inseriti non validi';
	END IF;

	-- controllo per vedere se il lavoratore ha svolto una mansione in quel giorno
	IF NOT EXISTS (SELECT 1 FROM `SvolgimentoTurno` ST WHERE ST.`giorno` = _giorno AND ST.`lavoratore` = _idLavoratore)
	THEN 	
		IF NOT EXISTS (SELECT 1 FROM `Turno` T WHERE T.`giorno` = _giorno AND T.`mansione` = _mansione AND T.`ora_inizio` = _inizio AND T.`ora_fine` = _fine)
		THEN
			-- se non esiste il turno viene inserito sia il turno che poi lo "svolge" turno
			INSERT INTO `Turno` VALUES (_inizio, _fine, _giorno, _mansione);

			INSERT INTO `SvolgimentoTurno` VALUES (_cfOperaio, _inizio, _fine, _giorno);
		ELSE
			INSERT INTO `SvolgimentoTurno` VALUES (_cfOperaio, _inizio, _fine, _giorno);
		END IF;
	ELSE -- controllo per vedere se è l'operaio sta svolgendo un altro turno in concomittanza
		IF EXISTS (SELECT 1 FROM `SvolgimentoTurno` ST WHERE ST.`giorno` = _giorno AND ST.`lavoratore` = _idLavoratore 
					AND (ST.`ora_fine` > _inizio OR ST.`ora_inizio` < _fine OR (ST.`ora_inizio` > _inizio AND ST.`ora_fine` < _fine)))
		THEN
			SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = '[ERROR] Operaio inserito impegnato in un altro turno';
		ELSE -- se non lo sta svolgendo si controlla che le ore totali inserite non superino 13
			SELECT SUM(TIMESTAMPDIFF(MINUTE, CONCAT('0000-01-01 ', ST.`ora_inizio`), CONCAT('0000-01-01 ', ST.`ora_fine`))) INTO nOre
			FROM `SvolgimentoTurno` ST
			WHERE ST.`giorno` = _giorno AND ST.`lavoratore` = _idLavoratore;

			IF (nOre + TIMESTAMPDIFF(MINUTE, CONCAT('0000-01-01 ', _inizio), CONCAT('0000-01-01 ', _fine)) < 680) -- 13 ore = 680 minuti, differenza tra le ore del nuovo turno
			THEN -- se la differenze è accettibile si controlla se esiste già un turno
				IF NOT EXISTS (SELECT 1 FROM `Turno` T WHERE T.`giorno` = _giorno AND T.`mansione` = _mansione AND T.`ora_inizio` = _inizio AND T.`ora_fine` = _fine)
				THEN
					-- se non esiste il turno viene inserito sia il turno che poi lo "svolge" turno
					INSERT INTO `Turno` VALUES (_inizio, _fine, _giorno, _mansione);

					INSERT INTO `SvolgimentoTurno` VALUES (_cfOperaio, _inizio, _fine, _giorno);
				ELSE
					INSERT INTO `SvolgimentoTurno` VALUES (_cfOperaio, _inizio, _fine, _giorno);
				END IF;
			ELSE
				SIGNAL SQLSTATE '45000' 
				SET MESSAGE_TEXT = '[ERROR] Il totale delle ore lavorate supera il massimo lavorabile giornalmente';
			END IF;
		END IF;
	END IF;
END $$
DELIMITER ;

-- =============================================================================================================== --
-- 													OPERATION 4       		  									   --
-- Evento che ogni anno elimina le misurazioni che non incidono con la valutazione dello stato dell'edificio       --       
-- =============================================================================================================== --

DROP EVENT IF EXISTS puliziaMisurazioni;
DELIMITER $$
CREATE EVENT puliziaMisurazioni
ON SCHEDULE EVERY 1 YEAR DO
BEGIN
	DELETE M FROM `misurazione` M 
	WHERE M.`timestamp` < CURRENT_TIMESTAMP - INTERVAL 1 YEAR 
		AND
		M.`livello` = 'L0';
END $$
DELIMITER ; 

-- =============================================================================================================== --
-- 													OPERATION 5        		  									   --
-- Evento che aggiorna ogni settimana la ridondanza del costo del progetto										   --
-- =============================================================================================================== --

DROP EVENT IF EXISTS aggiornamentoCosto;
DELIMITER $$
CREATE EVENT aggiornamentoCosto
ON SCHEDULE EVERY 1 WEEK DO
BEGIN
	# UTILS
	DROP TABLE IF EXISTS costoProgetto; 
    CREATE TEMPORARY TABLE costoProgetto (
        progetto INT NOT NULL,
        costo DOUBLE,
        PRIMARY KEY(progetto)
    );

	# MAIN
    -- calcolo del costo delle manodopera totale per ogni progetto
    INSERT INTO costoProgetto (progetto, costo) 
	WITH oreLavorateProgetto AS (
		SELECT L.`CF` AS operaio, PE.`codice` AS progetto, SUM(TIMESTAMPDIFF(MINUTE, CONCAT('0000-01-01 ', T.`ora_fine`), CONCAT('0000-01-01 ', T.`ora_inizio`))) AS minutiLavorati
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
		WHERE T.`giorno` > CURRENT_DATE - INTERVAL 7 DAY
        GROUP BY L.`CF`, PE.`codice`
	)
    , costoManodopera AS (
		SELECT OLP.progetto, SUM(costoManodoperaGiornaliera(OLP.minutiLavorati, L.`retribuzione_oraria`)) AS costoManodopera
		FROM oreLavorateProgetto OLP
		JOIN Lavoratore L ON L.`CF` = OLP.operaio
		GROUP BY OLP.progetto
    ) -- calcolo del costo totale dei materiali per ogni progetto
    , costoMateriali AS (
		SELECT PE.`codice` AS progetto, SUM(M.`costo` * MU.`quantita`) as costoMateriali
		FROM `ProgettoEdilizio` PE
		JOIN `StadioDiAvanzamento` SDA ON SDA.`progetto_edilizio` = PE.`codice`
		JOIN `LavoroProgettoEdilizio` LPE ON LPE.`stadio` = SDA.`ID`
        JOIN `MaterialeUtilizzato` MU ON MU.`lavoro` = LPE.`ID`
        JOIN `Materiale` M ON M.`ID` = MU.`materiale`
        GROUP BY PE.`progetto`
    )
    SELECT CM.progetto, CM.costoManodopera + CMA.costoMateriali
    FROM costoManodopera CM
    JOIN costoMateriali CMA ON CMA.progetto = CM.progetto;
    
    -- aggiornamento della tabella
	UPDATE `ProgettoEdilizio` PE
		JOIN costoProgetto CP ON CP.progetto = PE.`codice`
	SET PE.`costo` = PE.`costo` + CP.costo;
    
END $$
DELIMITER :

-- =============================================================================================================== --
-- 													OPERATION 6        		  									   --
-- Procedura che dato in ingresso un balcone calcola l'atezza da terrra del balcone preso in ingresso.			   --
-- Fallisce se il balcone inserito non è presente. 																   --
-- =============================================================================================================== --

DROP PROCEDURE IF EXISTS altezzaBalcone();
DELIMITER $$
CREATE PROCEDURE altezzaBalcone(IN _idBalcone INT, OUT altezzaDaTerra DOUBLE)
BEGIN
	# VAR
	DECLARE idEdificio INT DEFAULT NULL;
	DECLARE numeroPiano INT DEFAULT NULL;

	# MAIN
	-- se non esiste il balcone da errore
	IF NOT EXISTS (SELECT 1 FROM `Balcone` B WHERE B.`ID` = _idBalcone)
	THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] il balcone inserito è non presente';
	END IF;

	-- se il balcone esiste si trova l'id dell'edificio e il piano di cui fa parte
	SELECT V.`edificio`, V.`piano` INTO idEdificio, numeroPiano
	FROM `Balcone` B	
	JOIN `BalconeVano` BV ON BV.`balcone` = B.`ID`
	JOIN `Vano` V ON V.`ID` = BV.`vano` -- mi posso fermare a vano senza andare su piano perchè V.`piano` è la fk che rappresenta il numero di piano
    WHERE B.`ID` = _idBalcone
    LIMIT 1; 
    
	SELECT SUM(P.`altezza`) INTO altezzaDaTerra
	FROM `Piano` P
	WHERE P.`numero` < numeroPiano AND P.`edificio` = idEdificio;
END $$
DELIMITER ;

-- Trigger che in automatico inserisce l'altezza da terra sfruttando la procedura
DROP PROCEDURE IF EXISTS inserimentoAltezzaBalconi;
DELIMITER $$
CREATE PROCEDURE inserimentoAltezzaBalconi()
BEGIN 
	# VAR
    DECLARE finito INT DEFAULT 0;
    DECLARE idBalcone INT DEFAULT 0;
    DECLARE altezza DOUBLE DEFAULT 0;

	# MAIN
    DECLARE cur CURSOR FOR SELECT B.`ID` FROM `Balcone` B;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cur;
    WHILE finito = 0 DO 
		FETCH cur INTO idBalcone;
        
        CALL altezzaBalcone(idBalcone, altezza);
    
		UPDATE `Balcone` B 
		SET B.`altezza_da_terra` = altezza 
		WHERE B.`ID` = idBalcone;
    END WHILE;
    
    CLOSE cur;
END $$
DELIMITER ;

-- =============================================================================================================== --
-- 													OPERATION 7        		  									   --
-- Procedura che dato un edificio un edificio in input ne rende tutte le informazioni necessarie. Calcola la   	   --
-- superficie, il volume, il numero di vani, la superficie media e il volume medio. Inoltre rende la tipologia e   --
-- lo stato dell'edificio.
-- =============================================================================================================== --
DROP PROCEDURE IF EXISTS infoEdificio;
DELIMITER $$
CREATE PROCEDURE infoEdificio(IN _idEdificio INT, OUT sup DOUBLE, OUT volume DOUBLE, 
							  OUT vani INT, OUT supMedia DOUBLE, OUT volMedio DOUBLE,
                              OUT stato VARCHAR(6), OUT tipolgia VARCHAR(45))
BEGIN
	# MAIN
    IF NOT EXISTS (SELECT 1 FROM `Edificio` E WHERE E.`ID` = _idEdificio)
	THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] edificio inserito non presente';
	END IF;
    
    SELECT SUM(V.`larghezza` * V.`lunghezza`), SUM(V.`larghezza` * V.`lunghezza` * P.`altezza`) INTO sup, volume
    FROM `Edificio` E 
    JOIN `Piano` P ON P.`edificio` = E.`ID`
    JOIN `Vano` V ON V.`piano` = P.`numero` AND V.`edificio` =  P.`edificio`
    WHERE E.`ID` = _idEdificio
    GROUP BY E.`ID`;
    
    SET @statoN = 0;
    
    SELECT COUNT(1), E.`tipologia`, E.`stato` INTO vani, tipolgia, @statoN
    FROM `Edificio` E 
    JOIN `Piano` P ON P.`edificio` = E.`ID`
    JOIN `Vano` V ON V.`piano` = P.`numero` AND V.`edificio` =  P.`edificio`
    WHERE E.`ID` = _idEdificio
    GROUP BY E.`ID`;
    
    SET supMedia = sup / vani;
    SET volMedio = volume / vani;
    
    CASE 
		WHEN @statoN >= 75 
			THEN SET stato = "ottimo";
        WHEN @statoN BETWEEN 74 AND 50
			THEN SET stato = "buono";
        WHEN stato BETWEEN 49 AND 25
			THEN SET stato = "critico";
        WHEN stato <= 25 
			THEN SET stato = "da demolire";
	END CASE;
        
END $$
DELIMITER ;

-- Test
CALL infoEdificio(1, @sup, @vol, @vani, @supM, @volM, @stato, @tipo);
SELECT @sup, @vol, @vani, @supM, @volM, @tipo, @stato;

-- =============================================================================================================== --
-- 													OPERATION 8        		  									   --
-- Procedura che calcola l'AreaGeografica maggiormente colpita da calamità in un intervallo di tempo dato.		   --
-- Oltre all'area geografica rende in output la calamità che ha colpito più volte quell'area geografica			   --
-- =============================================================================================================== --
DROP PROCEDURE IF EXISTS areaMaggiormenteColpita;
DELIMITER $$
CREATE PROCEDURE areaMaggiormenteColpita (IN _mesi INT, OUT area VARCHAR(45), OUT calamita VARCHAR(45))
BEGIN
	# VAR
	DECLARE tmpId INT DEFAULT 0;

	# MAIN
	WITH areaMaggiore AS (
		SELECT COUNT(1) AS numCalamità, AG.`nome`, AG.`ID`
		FROM `AreaGeografica` AG
		JOIN `AreaColpita` AC ON AC.`area` = AG.`ID`
		GROUP BY AC.`area`
	)
	SELECT AM.`nome`, AM.`ID` INTO area, tmpId
	FROM areaMaggiore AM
	WHERE numCalamità = (SELECT MAX(AM2.numCalamità) FROM areaMaggiore AM2);

	WITH calamitaMaggiore AS (
		SELECT COUNT(1) AS numSingCalamita, AC.`calamita` 
		FROM `AreaColpita` AC
		WHERE AC.`area` = tmpId
		GROUP BY AC.`calamita`
	)
	SELECT CM.`calamita` INTO calamita
	FROM calamitaMaggiore CM 
	WHERE numSingCalamita = (SELECT MAX(CM2.calamitaMaggiore) FROM calamitaMaggiore CM2);
	
END $$
DELIMITER ;

-- =============================================================================================================== --
-- 													  EXTRA        		  									   --
-- Procedura che calcola l'AreaGeografica che ha speso di più per costi di ristrutturazione dopo una calamità.     -- 
-- e la rende in output insieme al costo.																		   --
-- =============================================================================================================== --

DROP PROCEDURE IF EXISTS costoRistrutturazioneArea;
DELIMITER $$
CREATE PROCEDURE costoRistrutturazioneArea (IN _calamita VARCHAR(45))
BEGIN
	# MAIN 
	WITH oreLavorateProgetto AS (
		SELECT L.`CF` AS operaio, AG.`ID` AS AreaGeografica, SUM(TIMESTAMPDIFF(MINUTE, CONCAT('0000-01-01 ', T.`ora_fine`), CONCAT('0000-01-01 ', T.`ora_inizio`))) AS minutiLavorati
		FROM `ProgettoEdilizio` PE
		JOIN `Edificio` E ON E.`ID` = PE.`codice`
		JOIN `AreaGeografica` AG ON AG.`ID` = E.`area_geografica`
		JOIN `StadioDiAvanzamento` SDA ON SDA.`progetto_edilizio` = PE.`codice`
		JOIN `LavoroProgettoEdilizio` LPE ON LPE.`stadio` = SDA.`ID`
		JOIN `PartecipazioneLavoratoreLavoro` PLL ON PLL.`lavoro` = LPE.`ID`
		JOIN `SupervisioneLavoro` SL ON SL.`lavoro` = LPE.`ID`
		JOIN `Lavoratore` L ON L.`CF` = PLL.`lavoratore` OR L.`CF` = SL.`lavoratore`
		JOIN `LavoratoreDirigeTurno` LDT ON LDT.`capo_turno` = L.`CF`
		JOIN `SvolgimentoTurno` ST ON ST.`lavoratore` = L.`CF`
		JOIN `Turno` T ON (T.`giorno` = ST.`giorno` AND T.`ora_inizio` = ST.`ora_inizio` AND T.`ora_fine` = ST.`ora_fine`) 
					   OR (T.`giorno` = LDT.`giorno` AND T.`ora_inizio` = LDT.`ora_inizio` AND T.`ora_fine` = LDT.`ora_fine`)
		WHERE LPE.`tipologia` = 'Ristrutturazione dopo' + _calamita + '%'  -- prende solamente i lavori che comprendono una ristrutturazione
		GROUP BY L.`CF`, AG.`ID`
	)
    , costoManodopera AS (
		SELECT OLP.AreaGeografica, SUM(costoManodoperaGiornaliera(OLP.minutiLavorati, L.`retribuzione_oraria`)) AS costoManodopera
		FROM oreLavorateProgetto OLP
		JOIN Lavoratore L ON L.`CF` = OLP.AreaGeografica
		GROUP BY OLP.AreaGeografica
    ) -- calcolo del costo totale dei materiali per ogni progetto
    , costoMateriali AS (
		SELECT AG.`ID` AS AreaGeografica, SUM(M.`costo` * MU.`quantita`) as costoMateriali
		FROM `ProgettoEdilizio` PE
		JOIN `Edificio` E ON E.`ID` = PE.`codice`
		JOIN `AreaGeografica` AG ON AG.`ID` = E.`area_geografica`
		JOIN `StadioDiAvanzamento` SDA ON SDA.`progetto_edilizio` = PE.`codice`
		JOIN `LavoroProgettoEdilizio` LPE ON LPE.`stadio` = SDA.`ID`
        JOIN `MaterialeUtilizzato` MU ON MU.`lavoro` = LPE.`ID`
        JOIN `Materiale` M ON M.`ID` = MU.`materiale`
		WHERE LPE.`tipologia` = 'Ristrutturazione dopo' + _calamita + '%' -- prende solamente i lavori che comprendono una ristrutturazione dopo una calamità
        GROUP BY AG.`ID`
    )
	, costoArea AS (
    	SELECT CMA.AreaGeografica, CM.costoManodopera + CMA.costoMateriali AS costo
    	FROM costoManodopera CM
    	JOIN costoMateriali CMA ON CMA.AreaGeografica = CM.AreaGeografica
	)
	SELECT CA.AreaGeografica, CA.costo
	FROM costoArea CA
	WHERE CA.costo = (SELECT MAX(CA2.costo) FROM costArea CA2);
END $$
DELIMITER ;
-- =============================================================================================================== --
-- 												 FINE OPERAZIONI        		  								   --
-- =============================================================================================================== --