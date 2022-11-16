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
	
	# CURSOR
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
CREATE PROCEDURE checkUmidita(IN _idEdificio INT, IN tipo VARCHAR(9), OUT valori TEXT)
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
    SET valori = '';
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

                    SET valori = CONCAT(valori, ' ', valore, ' ', parete_precedente, ' ', sensore_precedente);
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
                    -- stato = CONCAT('Necessari lavori urgenti sulla parete: ', idParete_o_vano, '. Misurazione rilevata dal sensore: ', id_sensore);
                    -- da usare dopo   
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

                    SET valori = CONCAT(valori, ' ', valore, parete_precedente, sensore_precedente);
                    SET salto = 0; SET parete_precedente = 0; SET sensore_precedente = 0; SET startTs = NULL; SET  startVal = 0;
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
                    -- stato = concat('Necessari lavori urgenti sulla parete: ', idParete_o_vano, '. Misurazione rilevata dal sensore: ', id_sensore);
                    -- da usare dopo   
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
CREATE PROCEDURE checkCrepe(IN _idEdificio INT, OUT valori TEXT)
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
    SET valori = '';
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

            SET valori = CONCAT(valori, ' ', valore, ' ', parete_precedente, ' ', sensore_precedente);
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
            -- stato = CONCAT('Necessari lavori urgenti sulla parete: ', idParete_o_vano, '. Misurazione rilevata dal sensore: ', id_sensore);
            -- da usare dopo   
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
CREATE PROCEDURE calcolaStatoEdificio(IN _idEdificio INT, OUT stato_ VARCHAR(11))
BEGIN 
	# VAR
	DECLARE statoPareti TEXT DEFAULT '';
    DECLARE statoAmbienteMuro TEXT DEFAULT '';
    DECLARE statoAmbientePavimento TEXT DEFAULT '';
    DECLARE statoStruttura TEXT DEFAULT '';
    
	# MAIN
    SET stato_ = '';
    CALL checkCrepe(_idEdificio, statoPareti);
    CALL checkUmidita(_idEdificio, 'MURO', statoAmbienteMuro);
    CALL checkUmidita(_idEdificio, 'PAVIMENTO', statoAmbientePavimento);
    CALL checkStruttura(_idEdificio, statoStruttura);
    
    
END $$
DELIMITER ;

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

-- TABELLA CON 
# ACCELEROSCOPI -> oscillazioni struttura (vento simile terremoto)
# UMIDITÀ, CREPE NEI MURI FATTO
# SOLAI vedere l abbassamento (abbassamento = freccia) stimare la freccia del solaio
# INFILTRAZIONI dal tetto (anche questa è più visiva)

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
	#UTILS
	DROP TABLE IF EXISTS interventi; 
    CREATE TEMPORARY TABLE interventi (
        intervento TEXT NOT NULL,
        rischio INT NOT NULL,
        PRIMARY KEY(intervento)
    ); 
    
	
END $$
DELIMITER ;