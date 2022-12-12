USE SmartBuildings;

# Per disabilitare "ONLY_FULL_GROUP_BY"
SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- =============================================================================================================== --
-- 									Area analisi del rischio e monitoraggio danni       		  	               --
-- =============================================================================================================== --	

-- ===================
-- STATO DELL'EDIFICIO
-- ===================

-- =========
-- struttura 
-- =========
DROP PROCEDURE IF EXISTS checkStruttura;
DELIMITER $$
CREATE PROCEDURE checkStruttura(IN _idEdificio INT, OUT punteggio_ DOUBLE)
BEGIN 
	# VAR
	DECLARE id_sensore, sensore_prec, finito, nMedie INT DEFAULT 0;
    DECLARE modulo, mediaMax, soglia, mediaTot DOUBLE DEFAULT 0;
	
	# CURSOR
	DECLARE cur_struttura CURSOR FOR 
	SELECT M.`id_sensore`, ROUND(SQRT(POWER(M.`valoreX`, 2) + POWER(M.`valoreY`, 2) + POWER(M.`valoreZ`, 2)), 2) as modulo, S.`soglia`
	FROM `Misurazione` M
	JOIN `Sensore` S ON S.`ID` = M.`id_sensore`
	JOIN `Vano` V ON S.`vano` = V.`ID`
	WHERE V.`edificio` = _idEdificio AND S.`tipo` = 'accelerometro'
	ORDER BY M.`id_sensore`, M.`timestamp`;
    
    # HANDLER
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

	# MAIN
    OPEN cur_struttura;
    
    WHILE finito = 0 DO
		FETCH cur_struttura INTO id_sensore, modulo, soglia;
        
        IF id_sensore <> sensore_prec 
        THEN 
			WITH ModuloMisurazioniAccelerometri AS (
				SELECT M.`id_sensore`, M.`timestamp`, ROUND(SQRT(POWER(M.`valoreX`, 2) + POWER(M.`valoreY`, 2) + POWER(M.`valoreZ`, 2)), 2) as modulo
				FROM `Misurazione` M
				WHERE M.`id_sensore` = id_sensore
			)
			SELECT ROUND(AVG(MMA.modulo), 2) INTO mediaMAX
			FROM ModuloMisurazioniAccelerometri MMA
			JOIN (
					SELECT ROUND(SQRT(POWER(M.`valoreX`, 2) + POWER(M.`valoreY`, 2) + POWER(M.`valoreZ`, 2)), 2) as modulo
					FROM `Misurazione` M
					WHERE M.`id_sensore` = id_sensore 
					ORDER BY modulo
					LIMIT 50
				) as test ON test.modulo = MMA.modulo;
        END IF;
        
        IF sensore_prec = 0 OR sensore_prec <> id_sensore
		THEN 
			SET sensore_prec = id_sensore;
            SET mediaTot = mediaTot + mediaMax;
            SET nMedie = nMedie + 1;
        END IF;
    END WHILE;
    
    CLOSE cur_struttura;
    
    IF mediaTot/nMedie < soglia 
    THEN
		SET punteggio_ = ROUND(((mediaTot/nMedie)/soglia)*100, 2);
	ELSE 
		SET punteggio_ = 100;
    END IF;
END $$ 
DELIMITER ;

-- =======
-- umidità
-- =======
DROP PROCEDURE IF EXISTS checkUmidita;
DELIMITER $$
CREATE PROCEDURE checkUmidita(IN _idEdificio INT, IN tipo VARCHAR(9), OUT punteggi_ TEXT, OUT ids_ TEXT, OUT contatore_ INT)
BEGIN 
    # VAR
    DECLARE finito, id_sensore, idParete_o_vano, sensore_precedente, salto, parete_precedente INT DEFAULT 0;
    DECLARE valX, soglia, _1ma, _7ma, _30ma, startVal, confirmVal, valore DOUBLE DEFAULT 0;
    DECLARE ts, startTs, confirmTs TIMESTAMP DEFAULT NULL;

    # CURSOR
    -- cursore per analizzare i muri
	DECLARE ma_muro CURSOR FOR 
    SELECT M.`id_sensore`, M.`timestamp`, M.`valoreX`, S.`soglia`, P.`id_parete_vano`,
			  ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 1 AND 2
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '1dayMA', 
              ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 7 AND 14
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '7daysMA',
              ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 30 AND 60
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '30daysMA'
	FROM Misurazione M
    JOIN Sensore S ON S.`ID` = M.`id_sensore`
    JOIN Parete P ON P.`ID` = S.`parete`
    JOIN Vano V ON V.`ID` = P.`vano`
    WHERE S.`tipo`= 'igrometro' AND V.`edificio` = _idEdificio
	ORDER BY M.`id_sensore`, M.`timestamp`;

    -- cursore per analizzare i pavimenti (parquet)
    DECLARE ma_pavimento CURSOR FOR 
    SELECT M.`id_sensore`, M.`timestamp`, M.`valoreX`, S.`soglia`, V.`ID`,
			  ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 1 AND 2
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '1dayMA', 
              ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 7 AND 14
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '7daysMA',
              ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 30 AND 60
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '30daysMA'
	FROM Misurazione M
    JOIN Sensore S ON S.`ID` = M.`id_sensore`
    JOIN Vano V ON V.`ID` = S.`vano`
    WHERE S.`tipo`= 'igrometro' AND V.`parquet` IS NOT NULL AND V.`edificio` = _idEdificio 
	ORDER BY M.`id_sensore`, M.`timestamp`;

	# HANDLER
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET finito = 1;
    
    # MAIN
    SET punteggi_ = '';
    SET ids_ = '';
    SET contatore_ = 0;
    CASE
        WHEN tipo = 'MURO' THEN
        BEGIN
            OPEN ma_muro;
            ciclo: LOOP
                IF finito = 1
                THEN 
                    LEAVE ciclo;
                END IF;

                FETCH ma_muro INTO id_sensore, ts, valX, soglia, idParete_o_vano, _1ma, _7ma, _30ma;
                                
                -- controllo se cambia il sensore, nel caso ci salviamo tutti i dati necessari
                IF sensore_precedente <> id_sensore AND sensore_precedente <> 0
                THEN
                    -- calcolo della rapidità con cui inizia il trend e avviene la conferma, 
                    -- si trova la retta tra i due punti e si salva la "m" dell'equazione
                    -- il primo punto  avrà coordinata 0 mentre il secondo la differenza dei giorni
                    IF valore <> 100
                    THEN
                        SET valore = (confirmVal - startVal) / DATEDIFF(confirmTs, startTs);
                    END IF;

                    SET punteggi_ = CONCAT(punteggi_, valore, ',');
                    SET ids_ = CONCAT(ids_, parete_precedente, '-', sensore_precedente, ',');
                    SET contatore_ = contatore_ + 1;
                    SET salto = 0; SET parete_precedente = 0; SET sensore_precedente = 0; SET startTs = NULL; SET startVal = 0;
                END IF; 
                
				--  se è stata imposta l'impostazione di salto si controlla di arrivare al nuovo sensore per reimpostarla.
                IF salto = 1 AND sensore_precedente = id_sensore AND valX < soglia
                THEN 
                    ITERATE ciclo;
                ELSE 
                    SET salto = 0;
                END IF;
                
                IF valX > soglia
                THEN
                    SET valore = 100;
                    SET salto = 1;
                ELSEIF _30ma IS NOT NULL AND salto = 0
                THEN
                    IF startTs IS NULL AND startVal = 0
                    THEN    
                        SET startTs = ts;
                        SET startVal = valX;
                        SET sensore_precedente = id_sensore;
                        SET parete_precedente = idParete_o_vano;
					END IF;
                    IF _30ma > _1ma AND _30ma > _7ma
                    THEN
                        IF _1ma >= _7ma 
                        THEN
                            SET startTs = ts;
                            SET startVal = valX;
                            SET sensore_precedente = id_sensore;
                            SET parete_precedente = idParete_o_vano;
                        END IF;
                    ELSEIF _30ma <= _1ma AND _30ma <= _7ma AND _1ma >= _7ma 
					THEN
                        SET confirmTs = ts;
                        SET confirmVal = valX;
                        SET salto = 1;
                        SET sensore_precedente = id_sensore;
                        SET parete_precedente = idParete_o_vano;
                    ELSEIF startTs IS NULL AND _1ma >= _7ma 
                    THEN
                        SET confirmTs = ts;
                        SET confirmVal = valX;
                        SET salto = 1;
                        SET sensore_precedente = id_sensore;
                        SET parete_precedente = idParete_o_vano;
                    END IF;
				END IF;
            END LOOP;
            CLOSE ma_muro;  
        END;

        WHEN tipo = 'PAVIMENTO' THEN
        BEGIN
            OPEN ma_pavimento;
            ciclo: LOOP
                IF finito = 1
                THEN 
                    LEAVE ciclo;
                END IF;

                FETCH ma_pavimento INTO id_sensore, ts, valX, soglia, idParete_o_vano, _1ma, _7ma, _30ma;
                
                -- controllo se cambia il sensore, nel caso ci salviamo tutti i dati necessari
                IF sensore_precedente <> id_sensore AND sensore_precedente <> 0
                THEN
                    -- calcolo della rapidità con cui inizia il trend e avviene la conferma, 
                    -- si trova la retta tra i due punti e si salva la "m" dell'equazione
                    -- il primo punto  avrà coordinata 0 mentre il secondo la differenza dei giorni
                    IF valore <> 100
                    THEN
                        SET valore = (confirmVal - startVal) / DATEDIFF(confirmTs, startTs);
                    END IF;

                    SET punteggi_ = CONCAT(punteggi_, valore, ',');
                    SET ids_ = CONCAT(ids_, parete_precedente, '-', sensore_precedente, ',');
                    SET contatore_ = contatore_ + 1;
                    SET salto = 0; SET parete_precedente = 0; SET sensore_precedente = 0; SET startTs = NULL; SET startVal = 0;
                END IF; 

                --  se è stata imposta l'impostazione di salto si controlla di arrivare al nuovo sensore per reimpostarla.
                IF salto = 1 AND sensore_precedente = id_sensore AND valX < soglia
                THEN 
                    ITERATE ciclo;
                ELSE 
                    SET salto = 0;
                END IF;
                
                IF valX > soglia
                THEN
                    SET valore = 100;
                    SET salto = 1;
                ELSEIF _30ma IS NOT NULL
                THEN
                    IF startTs IS NULL AND startVal = 0
                    THEN    
                        SET startTs = ts;
                        SET startVal = valX;
                        SET sensore_precedente = id_sensore;
                        SET parete_precedente = idParete_o_vano;
					END IF;
                    IF _30ma > _1ma AND _30ma > _7ma
                    THEN
                        IF _1ma >= _7ma 
                        THEN
                            SET startTs = ts;
                            SET startVal = valX;
                            SET sensore_precedente = id_sensore;
                            SET parete_precedente = idParete_o_vano;
                        END IF;
                    ELSEIF _30ma <= _1ma AND _30ma <= _7ma AND _1ma >= _7ma
                    THEN
                        SET confirmTs = ts;
                        SET confirmVal = valX;
                        SET salto = 1;
                        SET sensore_precedente = id_sensore;
                        SET parete_precedente = idParete_o_vano;
                    ELSEIF startTs IS NULL AND _1ma >= _7ma
                    THEN
                        SET confirmTs = ts;
                        SET confirmVal = valX;
                        SET salto = 1;
                        SET sensore_precedente = id_sensore;
                        SET parete_precedente = idParete_o_vano;
                    END IF;
                END IF;
            END LOOP;
            CLOSE ma_pavimento;
        END;
    END CASE;
END $$
DELIMITER ;

-- ======
-- crepe
-- ======
DROP PROCEDURE IF EXISTS checkCrepe;
DELIMITER $$
CREATE PROCEDURE checkCrepe(IN _idEdificio INT, OUT punteggi_ TEXT, OUT ids_ TEXT, OUT contatore_ INT)
BEGIN 
    # VAR
    DECLARE finito, id_sensore, id_parete_vano, salto, parete_precedente, sensore_precedente INT DEFAULT 0;
    DECLARE valX, soglia, _1ma, _7ma, _30ma, startVal, confirmVal, valore DOUBLE DEFAULT 0;
    DECLARE ts, startTs, confirmTs TIMESTAMP DEFAULT NULL;
 
    # CURSOR
    -- cursore per analizzare i muri
    DECLARE ma_muro_crepe CURSOR FOR 
    SELECT M.`id_sensore`, M.`timestamp`, M.`valoreX`, S.`soglia`, P.`id_parete_vano`,
            ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 1 AND 2
                AND M.id_sensore = M2.id_sensore
            ), 2) AS '1dayMA', 
            ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 7 AND 14
                AND M.id_sensore = M2.id_sensore
            ), 2) AS '7daysMA',
            ROUND((SELECT SUM(M2.valoreX) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 30 AND 60
                AND M.id_sensore = M2.id_sensore
            ), 2) AS '30daysMA'
    FROM Misurazione M
    JOIN Sensore S ON S.`ID` = M.`id_sensore`
    JOIN Parete P ON P.`ID` = S.`parete`
    JOIN Vano V ON V.`ID` = P.`vano`
    WHERE S.`tipo`= 'fessurimetro' AND V.`edificio` = _idEdificio
    ORDER BY M.`id_sensore`, M.`timestamp`;

    # HANDLER
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET finito = 1;

    # MAIN 
    SET punteggi_ = '';
    SET ids_ = '';
    SET contatore_ = 0;
    OPEN ma_muro_crepe;
    ciclo: LOOP
        IF finito = 1
        THEN 
            LEAVE ciclo;
        END IF;

        FETCH ma_muro_crepe INTO id_sensore, ts, valX, soglia, id_parete_vano, _1ma, _7ma, _30ma;
                
        -- controllo se cambia il sensore, nel caso ci salviamo tutti i dati necessari
        IF sensore_precedente <> id_sensore AND sensore_precedente <> 0
        THEN
            -- calcolo della rapidità con cui inizia il trend e avviene la conferma, 
            -- si trova la retta tra i due punti e si salva la "m" dell'equazione
            -- il primo punto  avrà coordinata 0 mentre il secondo la differenza dei giorni
            IF valore <> 100
            THEN
                SET valore = (confirmVal - startVal) / DATEDIFF(confirmTs, startTs);
            END IF;

			SET punteggi_ = CONCAT(punteggi_, valore, ',');
            SET ids_ = CONCAT(ids_, parete_precedente, '-', sensore_precedente, ',');
            SET contatore_ = contatore_ + 1;
            SET salto = 0; SET parete_precedente = 0; SET sensore_precedente = 0; SET startTs = NULL; SET  startVal = 0;
        END IF; 

        --  se è stata imposta l'impostazione di salto si controlla di arrivare al nuovo sensore per reimpostarla.
        IF salto = 1 AND sensore_precedente = id_sensore AND valX < soglia
        THEN 
            ITERATE ciclo;
        ELSEIF sensore_precedente <> id_sensore 
        THEN
            SET salto = 0;
        END IF;
        
        IF valX > soglia
        THEN
            SET valore = 100;
            SET salto = 1;
        ELSEIF _30ma IS NOT NULL AND salto = 0
        THEN
            IF startTs IS NULL AND startVal = 0
            THEN    
                SET startTs = ts;
                SET startVal = valX;
                SET sensore_precedente = id_sensore;
                SET parete_precedente = id_parete_vano;
			END IF;
            IF _30ma > _1ma AND _30ma > _7ma
            THEN
                IF _1ma > _7ma 
                THEN
                    SET startTs = ts;
                    SET startVal = valX;
                    SET sensore_precedente = id_sensore;
                    SET parete_precedente = id_parete_vano;
                END IF;
            ELSEIF _30ma <= _1ma AND _30ma <= _7ma AND _1ma >= _7ma
            THEN
                SET confirmTs = ts;
                SET confirmVal = valX;
                SET salto = 1;
                SET sensore_precedente = id_sensore;
                SET parete_precedente = id_parete_vano;
            ELSEIF startTs IS NULL AND _1ma >= _7ma
            THEN
                SET confirmTs = ts;
                SET confirmVal = valX;
                SET salto = 1;
                SET sensore_precedente = id_sensore;
                SET parete_precedente = id_parete_vano;
            END IF;
        END IF;
    END LOOP;
    CLOSE ma_muro_crepe;
END $$
DELIMITER ;

-- ===============
-- stato effettivo
-- ===============

DROP PROCEDURE IF EXISTS calcolaStatoEdificio;
DELIMITER $$
CREATE PROCEDURE calcolaStatoEdificio(IN _idEdificio INT, OUT stato_ INT, OUT descrizione_ TEXT)
BEGIN 
	# VAR
	DECLARE statoTmp, idsPareti TEXT DEFAULT '';
    DECLARE contatore, punteggioTotale INT DEFAULT 0;
    DECLARE statoStruttura DOUBLE DEFAULT 0;
    # var di appoggio
    DECLARE idTotali, idParete, idSensore, punteggio TEXT DEFAULT '';
    DECLARE tmpContatore INT DEFAULT 0;
    
	# MAIN
    SET stato_ = 0;
    -- punteggio pareti
    CALL checkCrepe(_idEdificio, statoTmp, idsPareti, contatore);
    SET tmpContatore = contatore;
    ciclo: LOOP
		IF contatore = 0
		THEN 
            LEAVE ciclo;
        END IF;
        
        SET punteggio = SUBSTR(statoTmp, 1, POSITION(',' IN statoTmp));
        SET punteggio = SUBSTR(punteggio, 1, LENGTH(punteggio) - 1); -- rimozione virgola finale
        
        SET punteggioTotale = punteggioTotale + CAST(punteggio AS UNSIGNED);

        -- preparzione del prossimo ciclo
        SET statoTmp = SUBSTR(statoTmp, POSITION(',' IN statoTmp) + 1, LENGTH(statoTmp));
		SET contatore = contatore - 1;
    END LOOP;

   IF tmpContatore <> 0 -- se è uguale a 0 niente fa alert quindi non gli viene sommato nulla
    THEN
		-- calcolo dell'impatto al 35%
		SET stato_ = stato_ + (punteggioTotale/tmpContatore) * 0.35; 
    END IF;

    -- punteggio ambiente da muri
    CALL checkUmidita(_idEdificio, 'MURO', statoTmp, idsPareti, contatore);
    SET tmpContatore = contatore;
    ciclo: LOOP
		IF contatore = 0
		THEN 
            LEAVE ciclo;
        END IF;
        
        SET punteggio = SUBSTR(statoTmp, 1, POSITION(',' IN statoTmp));
        SET punteggio = SUBSTR(punteggio, 1, LENGTH(punteggio) - 1); -- rimozione virgola finale
        
        -- preparzione del prossimo ciclo
        SET statoTmp = SUBSTR(statoTmp, POSITION(',' IN statoTmp)+1, LENGTH(statoTmp));
		SET contatore = contatore - 1;
    END LOOP;

    IF tmpContatore <> 0 -- se è uguale a 0 niente fa alert quindi non gli viene sommato nulla
    THEN
		-- calcolo dell'impatto al 10%
		SET stato_ = stato_ + (punteggioTotale/tmpContatore) * 0.1; 
    END IF;

    -- punteggio ambiente da pavimento
    CALL checkUmidita(_idEdificio, 'PAVIMENTO', statoTmp, idsPareti, contatore);
    SET tmpContatore = contatore;
    ciclo: LOOP
		IF contatore = 0
		THEN 
            LEAVE ciclo;
        END IF;
        	
        SET punteggio = SUBSTR(statoTmp, 1, POSITION(',' IN statoTmp));
        SET punteggio = SUBSTR(punteggio, 1, LENGTH(punteggio) - 1); -- rimozione virgola finale
        
        -- preparzione del prossimo ciclo
        SET statoTmp = SUBSTR(statoTmp, POSITION(',' IN statoTmp)+1, LENGTH(statoTmp));
		SET contatore = contatore - 1;
    END LOOP;

	IF tmpContatore <> 0 -- se è uguale a 0 niente fa alert quindi non gli viene sommato nulla
    THEN
		-- calcolo dell'impatto al 10%
		SET stato_ = stato_ + (punteggioTotale/tmpContatore) * 0.1; 
    END IF;

    -- punteggio struttura
    CALL checkStruttura(_idEdificio, statoStruttura);
    -- calcolo dell'impatto al 45%
    SET stato_ = stato_ + statoStruttura * 0.45 ;
    
	-- si sottrae 100 perchè lo stato va da 0 a 100 mentre lo stato calcolato fino a questo punto andrebbe da 100 a 0
	SET stato_ = 100 - stato_ ;
    
	CASE
		WHEN stato_ >= 75 
        THEN 
			SET descrizione_ = 'L edificio inserito si trova in ottime condizioni'; 
		
        WHEN stato_ BETWEEN 50 AND 74
        THEN 
			SET descrizione_ = 'L edificio inserito si trova in buone condizioni'; 
            
		WHEN stato_ BETWEEN 25 AND 49
        THEN 
			SET descrizione_ = 'L edificio inserito si trova in pessime condizioni'; 
            
		WHEN stato_ <= 24
        THEN 
			SET descrizione_ = 'L edificio inserito si trova in condizioni critiche'; 
    END CASE;
    
    -- e lo aggiorna nel database oltre a renderlo come output
    UPDATE `Edificio` E SET E.`stato`= stato_ WHERE E.`ID` = _idEdificio;
END $$
DELIMITER ;

-- TEST
-- CALL calcolaStatoEdificio(1, @stato, @descrizione);
-- SELECT @stato, @descrizione;

-- ===================
-- CALAMITÀ
-- ===================

DROP PROCEDURE IF EXISTS InserisciGravita;
DELIMITER $$
CREATE PROCEDURE InserisciGravita()
BEGIN 
  # VAR
  DECLARE gravita DOUBLE DEFAULT 0;
  DECLARE ag INT DEFAULT 0;
  DECLARE calamita INT DEFAULT 0; 
  DECLARE ts TIMESTAMP;
  DECLARE distanza DOUBLE DEFAULT 0;
  DECLARE finito INT DEFAULT 0;
  DECLARE tipoCalamita VARCHAR(45) DEFAULT '';

  # MAIN  
  DECLARE cur CURSOR FOR 
  SELECT AC.`area`, AC.`calamita`, AC.`timestamp`, AC.`distanza_epicentro` 
  FROM `AreaColpita` AC;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
  
  OPEN cur;
  WHILE finito = 0 DO 
    FETCH cur INTO ag, calamita, ts, distanza;
    
    SELECT C.`tipo` INTO tipoCalamita
    FROM `Calamita` C 
    WHERE C.`ID` = calamita;

    -- calcolo la gravità
    IF tipoCalamita = 'Terremoto' OR tipoCalamita = 'Frana' THEN
        SELECT ROUND(SUM(SQRT(POWER(M.`valoreX`, 2) + POWER(M.`valoreY`, 2) + POWER(M.`valoreZ`, 2)))/COUNT(M.`valoreX`)*R.`coefficiente_rischio`/(distanza + 1), 2) INTO gravita
        FROM AreaGeografica AG 
        JOIN Rischio R ON R.`area_geografica` = AG.ID AND R.tipo = tipoCalamita 
        JOIN Edificio E ON E.area_geografica = AG.ID
        JOIN Piano P ON P.edificio = E.ID
        JOIN Vano V ON V.edificio = P.edificio AND V.piano = P.numero
        JOIN Parete PA ON PA.vano = V.ID
        JOIN Sensore S ON S.vano = V.ID OR S.Parete = PA.ID
        JOIN Misurazione M ON M.id_sensore = S.ID
        WHERE 
            AG.ID = ag
            AND 
            S.tipo = 'accelerometro'
            AND 
            DATEDIFF(M.timestamp, ts) BETWEEN 0 AND 1
            AND 
            SQRT(POWER(M.`valoreX`, 2) + POWER(M.`valoreY`, 2) + POWER(M.`valoreZ`, 2)) IN (
                SELECT MAX(SQRT(POWER(M.`valoreX`, 2) + POWER(M.`valoreY`, 2) + POWER(M.`valoreZ`, 2)))
                FROM Misurazione M2
                WHERE DATEDIFF(M2.timestamp, ts) BETWEEN 0 AND 1 AND M2.id_sensore = S.ID
            );
    
        UPDATE AreaColpita AC SET AC.gravita = gravita WHERE AC.`timestamp` = ts AND AC.`area` = ag AND AC.calamita = calamita;
    END IF;

    IF tipoCalamita = 'Incendio' THEN
        SELECT ROUND(SUM(M.`valoreX`)/COUNT(M.`valoreX`)*R.`coefficiente_rischio`/(distanza + 1), 2) INTO gravita
        FROM `AreaGeografica` AG 
        JOIN `Rischio` R ON R.`area_geografica` = AG.`ID` AND R.`tipo` = tipoCalamita 
        JOIN Edificio E ON E.`area_geografica` = AG.`ID`
        JOIN Piano P ON P.`edificio` = E.`ID`
        JOIN Vano V ON V.`edificio` = P.`edificio` AND V.`piano` = P.`numero`
        JOIN Parete PA ON PA.`vano` = V.ID
        JOIN Sensore S ON S.`vano` = V.ID OR S.`parete` = PA.`ID`
        JOIN Misurazione M ON M.`id_sensore` = S.`ID`
        WHERE 
            AG.`ID` = ag
            AND 
            S.tipo = 'termometro'
            AND 
            DATEDIFF(M.`timestamp`, ts) BETWEEN 0 AND 1
            AND 
            M.`valoreX` IN (
                SELECT MAX(SQRT(POWER(M.`valoreX`, 2) + POWER(M.`valoreY`, 2) + POWER(M.`valoreZ`, 2)))
                FROM Misurazione M2
                WHERE DATEDIFF(M2.`timestamp`, ts) BETWEEN 0 AND 1 AND M2.`id_sensore` = S.ID
            );
    
        UPDATE AreaColpita AC SET AC.`gravita` = gravita WHERE AC.`timestamp` = ts AND AC.`area` = ag AND AC.`calamita` = calamita;
    END IF;
	END WHILE;
    CLOSE cur;
END $$

-- ==========
-- ANALYTICS
-- ==========

-- ======================
-- consigli di intervento
-- =======================
DROP PROCEDURE IF EXISTS consigliIntervento;
DELIMITER $$
CREATE PROCEDURE consigliIntervento(IN _idEdificio INT)
BEGIN
	# VAR
	DECLARE statoTmp, idsPareti TEXT DEFAULT '';
    DECLARE contatore, punteggioTotale INT DEFAULT 0;
    DECLARE media, statoStruttura DOUBLE DEFAULT 0;
    # var di appoggio
    DECLARE idTotali, idParete, idSensore, punteggio TEXT DEFAULT '';

	#UTILS
	DROP TABLE IF EXISTS interventi; 
    CREATE TEMPORARY TABLE interventi (
        intervento TEXT NOT NULL,
        rischio INT NOT NULL,
        priorita INT NOT NULL CHECK(priorita BETWEEN 1 AND 5)
    ); 
    
	# MAIN
    -- punteggio crepe
    CALL checkCrepe(_idEdificio, statoTmp, idsPareti, contatore);
    ciclo: LOOP
        IF contatore = 0
        THEN 
            LEAVE ciclo; 
        END IF;
    
		SET idTotali = SUBSTR(idsPareti, 1, POSITION(',' IN idsPareti));
        SET idParete = SUBSTR(idTotali, 1, POSITION('-' IN idTotali) - 1);
        SET idSensore = SUBSTR(idTotali, POSITION('-' IN idTotali) + 1, LENGTH(idTotali));
        SET idSensore = SUBSTR(idSensore, 1, LENGTH(idSensore) - 1); -- rimozione virgola finale
        SET punteggio = SUBSTR(statoTmp, 1, POSITION(',' IN statoTmp));
        SET punteggio = SUBSTR(punteggio, 1, LENGTH(punteggio) - 1); -- rimozione virgola finale

        CASE 
            -- sotto a 26 non necessita interventi
            WHEN punteggio BETWEEN 26 AND 65
            THEN
                INSERT INTO interventi VALUES (CONCAT('le misurazioni del sensore: ', idSensore, ' indicano che la parete: ', idParete, ' necessita la riparazione della crepa'), punteggio, 4);
            
            WHEN punteggio >= 66
            THEN
                INSERT INTO interventi VALUES (CONCAT('le misurazioni del sensore: ', idSensore, ' indicano che la parete: ', idParete, ' necessita un rifacimento totale a causa dell allargamento eccessivo della crepa'), punteggio, 2);
        END CASE;

        -- preparzione del prossimo ciclo
        SET idsPareti = SUBSTR(idsPareti, POSITION(',' IN idsPareti)+1, LENGTH(idsPareti));
        SET statoTmp = SUBSTR(statoTmp, POSITION(',' IN statoTmp)+1, LENGTH(statoTmp));
		SET contatore = contatore - 1;
    END LOOP;

    -- punteggio ambiente da muri
    CALL checkUmidita(_idEdificio, 'MURO', statoTmp, idsPareti, contatore);
    ciclo: LOOP
		IF contatore = 0
		THEN 
            LEAVE ciclo;
        END IF;
		
        SET idTotali = SUBSTR(idsPareti, 1, POSITION(',' IN idsPareti));
        SET idParete = SUBSTR(idTotali, 1, POSITION('-' IN idTotali) - 1);
        SET idSensore = SUBSTR(idTotali, POSITION('-' IN idTotali) + 1, LENGTH(idTotali));
        SET idSensore = SUBSTR(idSensore, 1, LENGTH(idSensore) - 1); -- rimozione virgola finale
        SET punteggio = SUBSTR(statoTmp, 1, POSITION(',' IN statoTmp));
        SET punteggio = SUBSTR(punteggio, 1, LENGTH(punteggio) - 1); -- rimozione virgola finale

        CASE 
            -- sotto a 41 non necessita interventi
            WHEN punteggio BETWEEN 41 AND 75
            THEN
                INSERT INTO interventi VALUES (CONCAT('le misurazioni del sensore: ', idSensore, ' indicano che la parete: ', idParete, 
                                                      ' necessita la rimozione superficiale dello strato di intonaco dove è presente l umidità 
                                                      e l applicazione di un composto di anti-muffa ed acqua'), punteggio, 4);
            
            WHEN punteggio >= 76
            THEN
                INSERT INTO interventi VALUES (CONCAT('le misurazioni del sensore: ', idSensore, ' indicano che la parete: ', idParete, ' necessita un rifacimento totale a causa della troppa umidità'), punteggio, 3);
        END CASE;
        
        -- preparzione del prossimo ciclo
        SET idsPareti = SUBSTR(idsPareti, POSITION(',' IN idsPareti)+1, LENGTH(idsPareti));
        SET statoTmp = SUBSTR(statoTmp, POSITION(',' IN statoTmp)+1, LENGTH(statoTmp));
		SET contatore = contatore - 1;
    END LOOP;

    -- punteggio ambiente da pavimento
    CALL checkUmidita(_idEdificio, 'PAVIMENTO', statoTmp, idsPareti, contatore);
    ciclo: LOOP
		IF contatore = 0
		THEN 
            LEAVE ciclo;
        END IF;
        
		SET idTotali = SUBSTR(idsPareti, 1, POSITION(',' IN idsPareti));
        SET idParete = SUBSTR(idTotali, 1, POSITION('-' IN idTotali) - 1);
        SET idSensore = SUBSTR(idTotali, POSITION('-' IN idTotali) + 1, LENGTH(idTotali));
        SET idSensore = SUBSTR(idSensore, 1, LENGTH(idSensore) - 1); -- rimozione virgola finale
        SET punteggio = SUBSTR(statoTmp, 1, POSITION(',' IN statoTmp));
        SET punteggio = SUBSTR(punteggio, 1, LENGTH(punteggio) - 1); -- rimozione virgola finale

        CASE 
            -- sotto a 21 non necessita di interventi
            WHEN punteggio BETWEEN 21 AND 65
            THEN
                INSERT INTO interventi VALUES (CONCAT('le misurazioni del sensore: ', idSensore, ' indicano che il parquet: ', idParete, 
                                                      ' necessita l applicazione di un composto di acqua e bicarbonato'), punteggio, 5);
            
            WHEN punteggio >= 66
            THEN
                INSERT INTO interventi VALUES (CONCAT('le misurazioni del sensore: ', idSensore, ' indicano che il parquet: ', idParete, ' necessita la sostituzione delle assi'), punteggio, 4);
        END CASE;
        
        -- preparzione del prossimo ciclo
        SET idsPareti = SUBSTR(idsPareti, POSITION(',' IN idsPareti)+1, LENGTH(idsPareti));
        SET statoTmp = SUBSTR(statoTmp, POSITION(',' IN statoTmp)+1, LENGTH(statoTmp));
		SET contatore = contatore - 1;
    END LOOP;

    -- punteggio struttura
    CALL checkStruttura(_idEdificio, statoStruttura);
    CASE 
        -- sotto 10 non necessita interventi
        WHEN punteggio BETWEEN 11 AND 30
        THEN
            INSERT INTO interventi VALUES (CONCAT('in seguito alle misurazioni degli accelerometri si è concluso che la struttura necessita un consolidamento'), punteggio, 3);
        
        WHEN punteggio >= 31
        THEN
            INSERT INTO interventi VALUES (CONCAT('in seguito alle misurazioni degli accelerometri si è concluso che è necessario e urgente un consolidamento della struttura'), punteggio, 1);
    END CASE;
    
    SELECT *
    FROM interventi
    ORDER BY priorita, rischio;
END $$
DELIMITER ;

-- TEST
-- CALL consigliIntervento(1);

-- ===============
-- stima dei danni
-- ===============

-- prendere le misurazioni delle crepe (40) e accelerometri (60) fino a 1 giorno dopo calamita terremoto e fare la media

DROP PROCEDURE IF EXISTS stimaDanni;
DELIMITER $$
CREATE PROCEDURE stimaDanni(IN _idEdificio INT, IN _gravita INT)
BEGIN 
    # VAR 
    DECLARE areaGeografica, finito, contatore INT DEFAULT 0; 
    DECLARE gravita, totValAttesi, mediaAttesaCrepe, mediaAttesaAccelerazioni, mediaSogliaFessurimetri, mediaSogliaAccelerometri DOUBLE DEFAULT 0;
    DECLARE tsCalamita TIMESTAMP DEFAULT NULL;
    DECLARE output TEXT DEFAULT '';

    # CURSOR 
    -- cursore per lo scorrimento delle calamità
	DECLARE cur_calamita CURSOR FOR 
    SELECT AC.`timestamp`, AC.`gravita`
    FROM `AreaColpita` AC 
    JOIN `Calamita` C ON C.`ID` = AC.`calamita`
    WHERE AC.`area` = areaGeografica AND C.`tipo` = 'Terremoto'
    ORDER BY AC.`timestamp`;

    # HANDLER
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    # MAIN
    -- recupero l'area geografica dell'edificio
    SELECT E.`area_geografica` INTO areaGeografica
    FROM `Edificio` E
    WHERE E.`ID` = _idEdificio;    
    
    OPEN cur_calamita;
    
    WHILE finito = 0 DO 
		FETCH cur_calamita INTO tsCalamita, gravita;
    
		SET totValAttesi = totValAttesi + (
			SELECT ROUND(AVG(M.`valoreX`)*_gravita/gravita, 2)
			FROM `Misurazione` M 
			JOIN `Sensore` S ON S.`ID` = M.`id_sensore` 
			JOIN `Parete` P ON P.`ID` = S.`parete`
			JOIN `Vano` V ON V.`ID` = P.`vano`
			WHERE V.`edificio` = _idEdificio AND S.`tipo` = 'fessurimetro' AND DATEDIFF(M.`timestamp`, tsCalamita) BETWEEN 0 AND 1
		); 
        
        SET contatore = contatore + 1;
    END WHILE;
    
    SELECT ROUND(AVG(S.`soglia`), 2) INTO mediaSogliaFessurimetri
    FROM `Misurazione` M 
	JOIN `Sensore` S ON S.`ID` = M.`id_sensore`  
	JOIN `Parete` P ON P.`ID` = S.`parete`
	JOIN `Vano` V ON V.`ID` = P.`vano`
	WHERE V.`edificio` = _idEdificio AND S.`tipo` = 'fessurimetro' AND DATEDIFF(M.`timestamp`, tsCalamita) BETWEEN 0 AND 1;
	
    CLOSE cur_calamita;
    
	SET mediaAttesaCrepe = totValAttesi/contatore;
    SET finito = 0; SET contatore = 0; SET totValAttesi = 0;
    
    OPEN cur_calamita; 
    
    WHILE finito = 0 DO 
		FETCH cur_calamita INTO tsCalamita, gravita;
		
		SET totValAttesi = totValAttesi + (
			SELECT ROUND(AVG(SQRT(POWER(M.`valoreX`, 2) + POWER(M.`valoreY`, 2) + POWER(M.`valoreZ`, 2)))*_gravita/gravita, 2)
			FROM `Misurazione` M 
			JOIN `Sensore` S ON S.`ID` = M.`id_sensore` 
			JOIN `Vano` V ON V.`ID` = S.`vano`
			WHERE V.`edificio` = _idEdificio AND S.`tipo` = 'accelerometro' AND DATEDIFF(M.`timestamp`, tsCalamita) BETWEEN 0 AND 1
		); 
        
        SET contatore = contatore + 1;
    END WHILE;
    
    SELECT ROUND(AVG(S.`soglia`), 2) INTO mediaSogliaAccelerometri
    FROM `Misurazione` M 
	JOIN `Sensore` S ON S.`ID` = M.`id_sensore`  
	JOIN `Vano` V ON V.`ID` = S.`vano`
	WHERE V.`edificio` = _idEdificio AND S.`tipo` = 'accelerometro' AND DATEDIFF(M.`timestamp`, tsCalamita) BETWEEN 0 AND 1;
    
    CLOSE cur_calamita;
    
    SET mediaAttesaAccelerazioni = totValAttesi/contatore;
    
    CASE 
		-- crepe e pareti
		WHEN mediaAttesaCrepe/mediaSogliaFessurimetri <= 0.4
        THEN
			SET output = CONCAT(output, 'In seguito alle stime effettuate potrebbero formerarsi delle crepe che non necessiteranno una riparazione immediata');
            
		WHEN mediaAttesaCrepe/mediaSogliaFessurimetri >= 0.41 AND mediaAttesaCrepe/mediaSogliaFessurimetri <= 0.75
		THEN 
			SET output = CONCAT(output, 'In seguito alle stime effettuate ci si aspetta che si formeranno delle crepe che necessiteranno una riparazione');
            
		WHEN mediaAttesaCrepe/mediaSogliaFessurimetri >= 0.76
		THEN 
			SET output = CONCAT(output, 'In seguito alle stime effettuate ci si aspetta che i danni porteranno alla necessità di ricostruire interamente alcune pareti');
    END CASE;
    
    CASE 
		-- struttura
		WHEN mediaAttesaAccelerazioni/mediaSogliaAccelerometri <= 0.3
        THEN
			SET output = CONCAT(output, ' e ', 'la struttura potrebbe subire danneggiamenti che non necessiteranno una riparazione immediata');
            
		WHEN mediaAttesaAccelerazioni/mediaSogliaAccelerometri >= 0.5 AND mediaAttesaAccelerazioni/mediaSogliaAccelerometri <= 0.65
		THEN 
			SET output = CONCAT(output, ' e ', 'la struttura subirà dei danni che necessiteranno un consolidamento');
            
		WHEN mediaAttesaAccelerazioni/mediaSogliaAccelerometri >= 0.65
		THEN 
			SET output = CONCAT(output, ' e', 'che i danni subiti dalla struttura saranno molto gravi e sarà necessario un rapido consolidamento');
    END CASE;
    
    SELECT output;
END $$
DELIMITER ;

-- TEST
-- CALL stimaDanni(1, 3);