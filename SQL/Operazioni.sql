# Naturalmente il file è ancora vuoto ma almeno è pronto su github [sembra che con operazioni si intenda solo procedure e funzioni ma informiamoci]
# [mi sono basato sui progetti vecchi]
USE SmartBuildings;

-- ============================================================================================================== --
-- OPERATION 1                                    							  									  --
-- Inserimento materiale utilizzato in un lavoro, in caso il materiale non sia presente nel database viene creato --		
-- ============================================================================================================== --

# secondo me dobbiamo cambiare i not null dentro i materiali, perchè cosi possiamo fare questa operation, che almeno lo crea lui e poi 
# gli mettiamo dopo una procedure per aggiornare il materiale sempre nella stessa operation
DROP PROCEDURE IF EXISTS inserimentoMateriale;
DELIMITER $$
CREATE PROCEDURE inserimentoMateriale(IN _nome VARCHAR(45), IN _quantita INT UNSIGNED, IN _IDlavoro INT)
BEGIN
    # VAR
    DECLARE idMateriale INT DEFAULT NULL;
    DECLARE idLAvoro INT DEFAULT NULL;
    
    # MAIN
    -- Cerchiamo se il materiale è presente
    SELECT M.`ID` INTO idMateriale
    FROM `Materiale` M WHERE M.`nome` = _nome;
    
    IF idMateriale IS NULL
	THEN 
		-- In questo caso l'operazione continua, sotto con un'altra procedura per aggiornare il nuovo materiale appena inserito
		INSERT INTO `Materiale` VALUES(_nome);	
		
        -- Salviamo l'id del materiale appena creato
		SELECT M.`ID` INTO idMateriale
		FROM `Materiale` M WHERE M.`nome` = _nome;
	END IF;
    
    -- Cerchiamo se il lavoro è presente
	SELECT LPE.`ID` INTO idLavoro
	FROM `LavoroProgettoEdilizio` LPE WHERE LPE.`nome` = _nome;
	
	IF idLavoro IS NULL
	THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Il LavoroProgettoEdilizio inserito non è valido';
	ELSE
		INSERT INTO `LavoroProgettoEdilizio` VALUES (_IDlavoro, idMateriale, _quantita);
	END IF;
	
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS aggiornamentoMateriale;
DELIMITER $$
CREATE PROCEDURE aggiornamentoMateriale(IN _idMateriale INT, IN _quantita INT UNSIGNED, IN _costo INT, IN unita INT, IN _larghezza INT, IN _lunghezza INT,
										IN _altezza INT, IN _costituzione INT, IN _colore VARCHAR(45), IN _fornitore VARCHAR(45), IN _dataAcquisto DATE )
BEGIN
		
        DECLARE idMateriale INT DEFAULT NULL;
        
        SELECT M.`ID` INTO idMateriale
		FROM `Materiale` M WHERE M.`nome` = _nome;
		
		IF idMateriale IS NULL
		THEN
			SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = '[ERROR] Il materiale inserito non è presente';
		ELSE 
			INSERT INTO `Materiale` VALUES(_nome);	# da finire, messo così sennò dava errore
        END IF;
        
END $$
DELIMITER ;

-- ================================================================================ --
--                                   OPERATION 2                                    --
-- ================================================================================ --

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

