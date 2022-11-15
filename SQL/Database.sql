-- Le misure come distanze, lunghezze, larghezze, e altezze sono espresse in cm
-- Il costo si indica in euro
-- Se l'unita di misura è "pz" il prezzo è al pezzo
-- I pesi sono espressi in kg

DROP DATABASE IF EXISTS SmartBuildings;
CREATE SCHEMA SmartBuildings DEFAULT CHARACTER SET utf8;
USE SmartBuildings;

SET FOREIGN_KEY_CHECKS = 0; -- per togliere il controllo sulla creazione delle FK iniziale (1 = controllo, 0 = non controllo)
SET GLOBAL EVENT_SCHEDULER = ON; -- per avviare lo schedule degli event

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Edificio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `tipologia` VARCHAR(45) NOT NULL,
  `stato` DOUBLE NOT NULL CHECK(`stato` BETWEEN 1 AND 100), --  critico = grosse ristrutturazioni, buone = piccole ristrutturazioni
  `area_geografica` INT NOT NULL, -- FK a area geografica
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`area_geografica`) REFERENCES `AreaGeografica` (`ID`) 
		ON UPDATE CASCADE 
		ON DELETE NO ACTION -- area geografica rimossa
) ENGINE = InnoDB;

CREATE INDEX `index_area_geografica1` ON `Edificio` (`area_geografica`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Piano` (
  `numero` SMALLINT NOT NULL, -- il numero del piano
  `altezza` SMALLINT UNSIGNED NOT NULL,
  `inclinazione` TINYINT UNSIGNED DEFAULT NULL, -- indica l'angolo di inclinazione del soffitto, se è NULL signfica che non è mansardato [TINYINT perchè più di 90 gradi non può essere]
  `altezza_min` SMALLINT UNSIGNED DEFAULT NULL,
  `edificio` INT NOT NULL, -- FK a edificio
  PRIMARY KEY (`numero` , `edificio`),
  FOREIGN KEY (`edificio`) REFERENCES `Edificio` (`ID`) 
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_edificio1` ON `Piano` (`edificio`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Vano` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `funzione` VARCHAR(45) NOT NULL,
  `lunghezza` DOUBLE UNSIGNED NOT NULL,
  `larghezza` DOUBLE UNSIGNED NOT NULL,
  `piano` SMALLINT NOT NULL, -- FK a piano
  `edificio` INT NOT NULL, -- FK a edificio
  `parquet` INT, -- FK a parquet
  `piastrella` INT, -- FK a piastrella
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`piano`, `edificio`) REFERENCES `Piano` (`numero`, `edificio`)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
  FOREIGN KEY (`parquet`) REFERENCES `Parquet` (`ID`)
		ON UPDATE CASCADE
		ON DELETE SET NULL, -- parquet rimosso
  FOREIGN KEY (`piastrella`) REFERENCES `Piastrella` (`ID`)
		ON UPDATE CASCADE
		ON DELETE SET NULL -- piastrella rimossa
) ENGINE = InnoDB;

CREATE INDEX `index_piano` ON `Vano` (`piano`);
CREATE INDEX `index_edificio2` ON `Vano` (`edificio`);
CREATE INDEX `index_parquet` ON `Vano` (`parquet`);
CREATE INDEX `index_piastrella` ON `Vano` (`piastrella`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `PuntoDiAccesso` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` DOUBLE UNSIGNED NOT NULL,
  `larghezza` DOUBLE UNSIGNED NOT NULL,
  `altezza` DOUBLE UNSIGNED NOT NULL,
  `distanza_da_sx` DOUBLE UNSIGNED NOT NULL, -- distanza da sinistra
  `tipo` VARCHAR(45) NOT NULL,
  `apertura` TINYINT NULL CHECK (`apertura` IN(0, 1, 2)) DEFAULT NULL, -- 0 per interna 1 per esterna 2 per a scorrimento
  `altezza_chiave` DOUBLE UNSIGNED DEFAULT NULL ,
  `parete` INT NOT NULL, -- FK a parete
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_parete1` ON `PuntoDiAccesso` (`parete`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Balcone` ( -- i balconi possono essere in comune a + vani
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` DOUBLE UNSIGNED NOT NULL,
  `larghezza` DOUBLE UNSIGNED NOT NULL,
  `altezza` DOUBLE UNSIGNED NOT NULL,
  `altezza_ringhiera` DOUBLE UNSIGNED NOT NULL,
  `altezza_da_terra` DOUBLE UNSIGNED DEFAULT 0,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `BalconeVano` ( 
  `balcone` INT NOT NULL, -- FK a balcone
  `vano` INT NOT NULL, -- FK a vano
  PRIMARY KEY (`balcone`, `vano`),
  FOREIGN KEY (`vano`) REFERENCES `Vano` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE,
  FOREIGN KEY (`balcone`) REFERENCES `Balcone` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_vano1` ON `BalconeVano` (`vano`);
CREATE INDEX `index_balcone` ON `BalconeVano` (`balcone`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Finestra` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` DOUBLE UNSIGNED NOT NULL,
  `larghezza` DOUBLE UNSIGNED NOT NULL,
  `altezza` DOUBLE UNSIGNED NOT NULL,
  `distanza_da_sx` SMALLINT UNSIGNED NOT NULL ,
  `altezza_da_pavimento` SMALLINT UNSIGNED NOT NULL,
  `parete` INT NOT NULL, -- FK a parete
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_finestra` ON `Finestra` (`parete`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `AreaGeografica` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE (`nome`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Rischio` (
  `area_geografica` INT NOT NULL, -- FK a area geografica
  `tipo` VARCHAR(45) NOT NULL,
  `coefficiente_rischio` INT NOT NULL CHECK (`coefficiente_rischio` BETWEEN 1 AND 10),
  PRIMARY KEY (`area_geografica`, `tipo`),
  FOREIGN KEY (`area_geografica`) REFERENCES `AreaGeografica` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_area_geografica2` ON `Rischio` (`area_geografica`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Calamita` (
  `ID` INT NOT NULL AUTO_INCREMENT, 
  `tipo` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------
 
CREATE TABLE IF NOT EXISTS `AreaColpita` (
    `area` INT NOT NULL, -- FK a area geografica
    `calamita` INT NOT NULL, -- FK a calamità
    `timestamp` TIMESTAMP NOT NULL,
    `gravita` DOUBLE UNSIGNED DEFAULT NULL,
    `distanza_epicentro` DOUBLE UNSIGNED NOT NULL, -- espressa in km
	PRIMARY KEY (`area`, `calamita`, `timestamp`),
    FOREIGN KEY (`area`) REFERENCES `AreaGeografica` (`ID`)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
    FOREIGN KEY (`calamita`) REFERENCES `Calamita` (`ID`)
			ON UPDATE CASCADE
			ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_area_geografica3` ON `AreaColpita` (`area`);
CREATE INDEX `index_calamita` ON `AreaColpita` (`calamita`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Parete` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `orientamento` VARCHAR(2) CHECK (`orientamento` IN ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),
  `angolo` INT CHECK (`angolo` BETWEEN 1 AND 359 AND `angolo` <> 180), -- l'angolo in questione è quello tra la parete del
										-- record e quella con l'id successivo, nel caso dell'ultima parete sarà tra l'ultima e la prima
  `id_parete_vano` INT NOT NULL, -- serve per identificare a quale parete si fa riferimento all'interno del vano.
				 -- il max è il soffitto, gli altri sono in ordine crescente a partire dalla parete a nord e continuando verso est
  `mattone` INT NOT NULL, -- FK al tipo di mattone
  `vano` INT NOT NULL, -- FK al vano
  `pietra` INT DEFAULT NULL, -- FK a pietra (non tutti sono per forza rivestite in pietra)
  `lunghezza` DOUBLE UNSIGNED,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`pietra`) REFERENCES `Pietra` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION, -- pietra rimossa
  FOREIGN KEY (`mattone`) REFERENCES `Mattone` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION, -- mattone rimosso
  FOREIGN KEY (`vano`) REFERENCES `Vano` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE,
  UNIQUE (`id_parete_vano`, `vano`)
) ENGINE = InnoDB;

CREATE INDEX `index_pietra` ON `Parete` (`pietra`);
CREATE INDEX `index_mattone` ON `Parete` (`mattone`);
CREATE INDEX `index_vano2` ON `Parete` (`vano`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Materiale` (
	`ID` INT NOT NULL AUTO_INCREMENT, -- Quando viene inserito un mattone, pietra, ecc si inserisce prima un materiale e si crea
                                      -- l'associazione alla foreign key
	`nome` VARCHAR(45) NOT NULL, 
    `cod_lotto` INT NOT NULL DEFAULT 0,
    `fornitore` VARCHAR(45) NOT NULL DEFAULT "",
    `larghezza` DOUBLE UNSIGNED NOT NULL DEFAULT 0,
    `lunghezza` DOUBLE UNSIGNED NOT NULL DEFAULT 0,
    `altezza` DOUBLE UNSIGNED NOT NULL DEFAULT 0,
    `costituzione` VARCHAR(45), -- NULL nel caso di materiali già definiti (pietra, mattone, ecc)
    `costo` DOUBLE UNSIGNED NOT NULL DEFAULT 0, -- costo ad unità
    `unita` VARCHAR(4) NOT NULL, -- unità di misura (costo per kg, hg, g, mq, mc, ecc)
    `data_acquisto` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `quantita` DOUBLE UNSIGNED NOT NULL DEFAULT 0,
    `colore` VARCHAR(25) DEFAULT "",
	PRIMARY KEY (`ID`),
    UNIQUE(`nome`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Pietra` (
	`ID` INT NOT NULL, -- FK a materiale
    `tipo` VARCHAR(45) NOT NULL,
    `peso_medio` DOUBLE UNSIGNED NOT NULL, 
    `superficie_media` DOUBLE UNSIGNED NOT NULL,
    `disposizione` TEXT NOT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_materiale1` ON `Pietra` (`ID`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Mattone` (
	`ID` INT NOT NULL, -- FK a materiale
    `materiale_realizzazione` VARCHAR(20) NOT NULL, 
    `alveolatura` INT DEFAULT NULL, -- FK a alveolatura (se null allora è pieno)
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`alveolatura`) REFERENCES `Alveolatura` (`ID`)
		ON UPDATE CASCADE
        ON DELETE SET NULL, -- alveolatura rimossa
    FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_alveolatura` ON `Mattone` (`alveolatura`);
CREATE INDEX `index_materiale2` ON `Mattone` (`ID`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Alveolatura` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `materiale_riempimento` VARCHAR(45),
    `nome` VARCHAR(45) NOT NULL,
    `descrizione` VARCHAR(45) DEFAULT NULL,
    PRIMARY KEY (`ID`),
    UNIQUE(`nome`, `materiale_riempimento`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Intonaco` (
	`ID` INT NOT NULL, -- FK a materiale
    `spessore` DOUBLE UNSIGNED NOT NULL, 
    `tipo` VARCHAR(45) DEFAULT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_materiale3` ON `Intonaco` (`ID`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `StratoIntonaco` (
	`strato` INT NOT NULL, -- numero dello strato dell'intonaco
	`parete` INT NOT NULL, -- FK a parete
    `intonaco` INT NOT NULL, -- FK a intonaco
    PRIMARY KEY (`parete`, `intonaco`, `strato`),
    FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (`intonaco`) REFERENCES `Intonaco` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_parete2` ON `StratoIntonaco` (`parete`);
CREATE INDEX `index_intonaco` ON `StratoIntonaco` (`intonaco`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Parquet`(
  `ID` INT NOT NULL, -- FK a materiale
  `disposizione` TEXT NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_materiale4` ON `Parquet` (`ID`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Piastrella`(
  `ID` INT NOT NULL, -- FK a materiale
  `larghezza_fuga` DOUBLE UNSIGNED NOT NULL,
  `motivo`VARCHAR(45) NOT NULL,
  `isStampato` TINYINT DEFAULT 0 CHECK (`isStampato` IN (0,1)), -- 0 non stampato 1 stampato
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX `index_materiale5` ON `Piastrella` (`ID`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ProgettoEdilizio` (
    `codice` INT NOT NULL, 
    `tipologia` VARCHAR(45) NOT NULL,
    `data_presentazione` DATETIME NOT NULL,
    `data_approvazione` DATETIME NOT NULL,
    `data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
    `data_fine_effettiva` DATETIME,
    `costo` INT UNSIGNED NOT NULL DEFAULT 0,
    `edificio` INT NOT NULL, -- FK a edificio
	PRIMARY KEY (`codice`),
    FOREIGN KEY (`edificio`) REFERENCES `Edificio` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE INDEX `index_edificio3` ON `ProgettoEdilizio` (`edificio`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `StadioDiAvanzamento` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
    `data_fine_effettiva` DATETIME,
    `descrizione` TEXT NOT NULL,
    `progetto_edilizio` INT NOT NULL, -- FK a progetto edilizio
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`progetto_edilizio`) REFERENCES `ProgettoEdilizio` (`codice`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE INDEX `index_progetto_edilizio1` ON `StadioDiAvanzamento` (`progetto_edilizio`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `LavoroProgettoEdilizio` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`tipologia` VARCHAR(45) NOT NULL,
    `isCompleto` TINYINT NOT NULL CHECK(`isCompleto` IN (0, 1)) DEFAULT 0, -- 0 non completo 1 completato
    `stadio` INT NOT NULL, -- FK a stadio di avanzamento
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`stadio`) REFERENCES `StadioDiAvanzamento` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE INDEX `index_stadio` ON `LavoroProgettoEdilizio` (`stadio`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `MaterialeUtilizzato` (
	`lavoro` INT NOT NULL, -- FK lavoroProgettoEdilizio
    `materiale` INT NOT NULL, -- FK a materiale
    `quantita` INT UNSIGNED NOT NULL, 
	PRIMARY KEY (`lavoro`, `materiale`),
    FOREIGN KEY (`lavoro`) REFERENCES `LavoroProgettoEdilizio` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (`materiale`) REFERENCES `Materiale` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION -- materiale rimosso ma comunque utilizzato quindi va tenuto il record
) ENGINE = InnoDB;

CREATE INDEX `index_lavoro1` ON `MaterialeUtilizzato` (`lavoro`);
CREATE INDEX `index_materiale6` ON `MaterialeUtilizzato` (`materiale`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Lavoratore` (
    `CF` VARCHAR(16) NOT NULL, 
	`nome` VARCHAR(45) NOT NULL,
    `cognome` VARCHAR(45) NOT NULL, 
    `retribuzione_oraria` DOUBLE UNSIGNED NOT NULL,
    `tipo` VARCHAR(13) NOT NULL CHECK(`tipo` IN ('semplice', 'responsabile', 'capo cantiere')),
	PRIMARY KEY (`CF`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `PartecipazioneLavoratoreLavoro` (
	`lavoratore` VARCHAR(16) NOT NULL, -- FK lavoratore
    `lavoro` INT NOT NULL, -- FK a lavoroProgettoEdilizio
	PRIMARY KEY (`lavoratore`, `lavoro`),
    FOREIGN KEY (`lavoratore`) REFERENCES `Lavoratore` (`CF`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (`lavoro`) REFERENCES `LavoroProgettoEdilizio` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE INDEX `index_lavoratore1` ON `PartecipazioneLavoratoreLavoro` (`lavoratore`);
CREATE INDEX `index_lavoro2` ON `PartecipazioneLavoratoreLavoro` (`lavoro`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `SupervisioneLavoro` (
	`lavoratore` VARCHAR(16) NOT NULL, -- FK lavoratore
    `lavoro` INT NOT NULL, -- FK a lavoroProgettoEdilizio
	PRIMARY KEY (`lavoratore`, `lavoro`),
    FOREIGN KEY (`lavoratore`) REFERENCES `Lavoratore` (`CF`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (`lavoro`) REFERENCES `LavoroProgettoEdilizio` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE INDEX `index_lavoratore2` ON `SupervisioneLavoro` (`lavoratore`);
CREATE INDEX `index_lavoro3` ON `SupervisioneLavoro` (`lavoro`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Turno` (
	`ora_inizio` TIME NOT NULL,
    `ora_fine` TIME NOT NULL,
	`giorno` DATE NOT NULL, -- serve perché altrimenti un lavoratore può svolgere un turno una sola volta
	`mansione` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`ora_inizio`, `ora_fine`, `giorno`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `LavoratoreDirigeTurno` ( -- il turno può avere più capi cantiere [per aumentare il numero di lavoratori contemporanei]
	`capo_turno` VARCHAR(16) NOT NULL, -- FK lavoratore
    `ora_inizio` TIME NOT NULL, -- FK a turno
	`ora_fine` TIME NOT NULL,
	`giorno` DATE NOT NULL,
    `num_lavoratori_monitorabili` INT NOT NULL, -- andava a creare troppi valori null inserendolo in lavoratore
    PRIMARY KEY (`capo_turno`, `ora_inizio`, `ora_fine`, `giorno`),
    FOREIGN KEY (`capo_turno`) REFERENCES `Lavoratore` (`CF`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (`ora_inizio`, `ora_fine`, `giorno`) REFERENCES `Turno` (`ora_inizio`, `ora_fine`, `giorno`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE INDEX `index_ora_inizio1` ON `LavoratoreDirigeTurno` (`ora_inizio`);
CREATE INDEX `index_ora_fine1` ON `LavoratoreDirigeTurno` (`ora_fine`);
CREATE INDEX `index_giorno1` ON `LavoratoreDirigeTurno` (`giorno`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `SvolgimentoTurno` ( 
	`lavoratore` VARCHAR(16) NOT NULL, -- FK lavoratore
    `ora_inizio` TIME NOT NULL, -- FK a turno
	`ora_fine` TIME NOT NULL,
	`giorno` DATE NOT NULL,
	PRIMARY KEY (`lavoratore`, `ora_inizio`, `ora_fine`, `giorno`),
    FOREIGN KEY (`lavoratore`) REFERENCES `Lavoratore` (`CF`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (`ora_inizio`, `ora_fine`, `giorno`) REFERENCES `Turno` (`ora_inizio`, `ora_fine`, `giorno`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE INDEX `index_ora_inizio2` ON `SvolgimentoTurno` (`ora_inizio`);
CREATE INDEX `index_ora_fine2` ON `SvolgimentoTurno` (`ora_fine`);
CREATE INDEX `index_giorno2` ON `SvolgimentoTurno` (`giorno`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Sensore` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`distanza_da_sx` DOUBLE UNSIGNED NOT NULL, 
    `altezza_da_pavimento` DOUBLE NOT NULL,
	`isEsterno` TINYINT NOT NULL CHECK(`isEsterno` IN (0, 1)),
    `tipo` VARCHAR(45) NOT NULL, 
	`soglia` DOUBLE NOT NULL, 
    `unita_di_misura` VARCHAR(6) NOT NULL, 
	`parete` INT, -- FK parete
    `vano` INT, -- FK vano
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`),
    FOREIGN KEY (`vano`) REFERENCES `Vano` (`ID`)
) ENGINE = InnoDB;

CREATE INDEX `index_parete3` ON `Sensore` (`parete`);
CREATE INDEX `index_vano3`ON `Sensore` (`vano`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Misurazione` (
	`id_sensore` INT NOT NULL,
	`timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(), 
	`livello` VARCHAR(2) CHECK(`livello` IN ('L0', 'L1', 'L2', 'L3', 'L4')), -- L0 misurazione che non impatta sullo stato dell'edificio
	`valoreX` DOUBLE NOT NULL, -- se y e z sono null x diventa il valore misurato
    `valoreY` DOUBLE,
    `valoreZ` DOUBLE,
	PRIMARY KEY (`id_sensore`, `timestamp`),
    FOREIGN KEY (`id_sensore`) REFERENCES `Sensore` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE INDEX `index_id_sensore` ON `Misurazione` (`id_sensore`);

-- ------------------------------------------------------------------------------------------