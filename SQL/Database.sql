-- Le misure come distanze, lunghezze, larghezze, e altezze sono espresse in cm

DROP DATABASE IF EXISTS SmartBuildings;
CREATE SCHEMA SmartBuildings DEFAULT CHARACTER SET utf8;
USE SmartBuildings;

SET FOREIGN_KEY_CHECKS = 0; -- per togliere il controllo sulla creazione delle FK iniziale (1 = controllo, 0 = non controllo)
SET GLOBAL EVENT_SCHEDULER = ON; -- per avviare lo schedule dei trigger

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Edificio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `isFinito` TINYINT NOT NULL CHECK (`isFinito` IN (0, 1)) DEFAULT 0, -- 1 finito, 0 no
  `tipologia` VARCHAR(45) NOT NULL,
  `stato` DOUBLE NOT NULL CHECK(`stato` BETWEEN 1 AND 100), --  critico = grosse ristrutturazioni, buone = piccole ristrutturazioni
  `area_geografica` INT NOT NULL, -- FK a area geografica
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`area_geografica`) REFERENCES `AreaGeografica` (`ID`) 
		ON UPDATE CASCADE 
		ON DELETE NO ACTION -- area geografica rimossa
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_area_geografica1` ON `Edificio` (`area_geografica`);

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

CREATE UNIQUE INDEX `index_edificio1` ON `Piano` (`edificio`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Vano` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `funzione` VARCHAR(45) NOT NULL,
  `lunghezza` SMALLINT UNSIGNED NOT NULL,
  `larghezza` SMALLINT UNSIGNED NOT NULL,
  `altezza` SMALLINT UNSIGNED NOT NULL,
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

CREATE UNIQUE INDEX `index_piano` ON `Vano` (`piano`);
CREATE UNIQUE INDEX `index_edificio2` ON `Vano` (`edificio`);
CREATE UNIQUE INDEX `index_parquet` ON `Vano` (`parquet`);
CREATE UNIQUE INDEX `index_piastrella` ON `Vano` (`piastrella`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `PuntoDiAccesso` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` SMALLINT UNSIGNED NOT NULL,
  `larghezza` SMALLINT UNSIGNED NOT NULL,
  `altezza` SMALLINT UNSIGNED NOT NULL,
  `distanza_da_sx` SMALLINT UNSIGNED NOT NULL, -- distanza da sinistra
  `tipo` VARCHAR(45) NOT NULL,
  `apertura` TINYINT NULL CHECK (`apertura` IN(0, 1, 2)) DEFAULT NULL, -- 0 per interna 1 per esterna 2 per a scorrimento
  `altezza_chiave` SMALLINT UNSIGNED DEFAULT NULL ,
  `angolo_curvatura` TINYINT UNSIGNED DEFAULT NULL,
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
  `lunghezza` SMALLINT UNSIGNED NOT NULL,
  `larghezza` SMALLINT UNSIGNED NOT NULL,
  `altezza` SMALLINT UNSIGNED NOT NULL,
  `altezza_ringhiera` TINYINT UNSIGNED NOT NULL,
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

CREATE UNIQUE INDEX `index_vano1` ON `BalconeVano` (`vano`);
CREATE UNIQUE INDEX `index_balcone` ON `BalconeVano` (`balcone`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Finestra` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `larghezza` SMALLINT UNSIGNED NOT NULL,
  `lunghezza` SMALLINT UNSIGNED NOT NULL,
  `altezza` SMALLINT UNSIGNED NOT NULL,
  `distanza_da_sx` SMALLINT UNSIGNED NOT NULL ,
  `altezza_da_pavimento` SMALLINT UNSIGNED NOT NULL,
  `orientamento` VARCHAR(2) NOT NULL CHECK (`orientamento` IN ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),
  `parete` INT NOT NULL, -- FK a parete
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_finestra` ON `Finestra` (`parete`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `AreaGeografica` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `nome` INT NOT NULL,
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

CREATE UNIQUE INDEX `index_area_geografica2` ON `Rischio` (`area_geografica`);

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
    `gravita` INT NOT NULL CHECK (`gravita` BETWEEN 1 AND 10),
	PRIMARY KEY (`area`, `calamita`, `timestamp`),
    FOREIGN KEY (`area`) REFERENCES `AreaGeografica` (`ID`)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
    FOREIGN KEY (`calamita`) REFERENCES `Calamita` (`ID`)
			ON UPDATE CASCADE
			ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_area_geografica3` ON `AreaColpita` (`area`);
CREATE UNIQUE INDEX `index_calamita` ON `AreaColpita` (`calamita`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Parete` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `orientamento` VARCHAR(2) NOT NULL CHECK (`orientamento` IN ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),
  `isRicopertoPietra` TINYINT NOT NULL CHECK (`isRicopertoPietra` IN (0, 1)) DEFAULT 0,
  `angolo` INT NOT NULL CHECK (`angolo` BETWEEN 1 AND 359 AND `angolo` <> 180), -- l'angolo in questione è quello tra la parete del
										-- record e quella con l'id successivo, nel caso dell'ultima parete sarà tra l'ultima e la prima
  `id_parete_vano` INT NOT NULL, -- serve per identificare a quale parete si fa riferimento all'interno del vano.
				 -- 1 è pavimento, il max è il soffitto, gli altri sono in ordine crescente a partire dalla parete a nord e continuando verso est
  `mattone` INT NOT NULL, -- FK al tipo di mattone
  `vano` INT NOT NULL, -- FK al vano
  `pietra` INT DEFAULT NULL, -- FK a pietra (non tutti sono per forza rivestite in pietra)
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

CREATE UNIQUE INDEX `index_pietra` ON `Parete` (`pietra`);
CREATE UNIQUE INDEX `index_mattone` ON `Parete` (`mattone`);
CREATE UNIQUE INDEX `index_vano2` ON `Parete` (`vano`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Materiale` (
	`ID` INT NOT NULL AUTO_INCREMENT, -- Quando viene inserito un mattone, pietra, ecc si inserisce prima un materiale e si crea
                                      -- l'associazione alla foreign key
	`nome` VARCHAR(45) NOT NULL, 
    `cod_lotto` INT NOT NULL DEFAULT 0,
    `fornitore` VARCHAR(45) NOT NULL DEFAULT "",
    `larghezza` INT UNSIGNED NOT NULL DEFAULT 0,
    `lunghezza` INT UNSIGNED NOT NULL DEFAULT 0,
    `altezza` INT UNSIGNED NOT NULL DEFAULT 0,
    `costituzione` VARCHAR(45), -- NULL nel caso di materiali già definiti (pietra, mattone, ecc)
    `costo` DOUBLE UNSIGNED NOT NULL DEFAULT 0, -- costo ad unità
    `unita` VARCHAR(4) NOT NULL, -- unità di misura (costo per kg, hg, g, mq, mc, ecc)
    `data_acquisto` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `quantita` INT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (`ID`),
    UNIQUE(`nome`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Pietra` (
	`ID` INT NOT NULL, -- FK a materiale
    `tipo` VARCHAR(45) NOT NULL,
    `peso_medio` INT UNSIGNED NOT NULL, 
    `superficie_media` INT UNSIGNED NOT NULL,
    `disposizione` TEXT NOT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_materiale1` ON `Pietra` (`ID`);

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

CREATE UNIQUE INDEX `index_alveolatura` ON `Mattone` (`alveolatura`);
CREATE UNIQUE INDEX `index_materiale2` ON `Mattone` (`ID`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Alveolatura` (
	`ID` INT NOT NULL,
    `materiale_riempimento` VARCHAR(45) NOT NULL,
    `nome` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`ID`),
    UNIQUE(`nome`, `materiale_riempimento`)
) ENGINE = InnoDB;

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Intonaco` (
	`ID` INT NOT NULL, -- FK a materiale
    `colore` VARCHAR(45) NOT NULL,
    `spessore` INT UNSIGNED NOT NULL, 
    `tipo` VARCHAR(45) DEFAULT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_materiale3` ON `Intonaco` (`ID`);

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

CREATE UNIQUE INDEX `index_parete2` ON `StratoIntonaco` (`parete`);
CREATE UNIQUE INDEX `index_intonaco` ON `StratoIntonaco` (`intonaco`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Parquet`(
  `ID` INT NOT NULL, -- FK a materiale
  `tipo_legno` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE,
  UNIQUE (`tipo_legno`)
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_materiale4` ON `Parquet` (`ID`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Piastrella`(
  `ID` INT NOT NULL, -- FK a materiale
  `forma` VARCHAR(30) NOT NULL,
  `larghezza_fuga` INT UNSIGNED NOT NULL,
  `motivo`VARCHAR(45) NOT NULL,
  `isStampato` TINYINT DEFAULT 0 CHECK (`isStampato` IN (0,1)), -- 0 non stampato 1 stampato
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
		ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_materiale5` ON `Piastrella` (`ID`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ProgettoEdilizio` (
    `codice` INT NOT NULL, 
    `tipologia` VARCHAR(45) NOT NULL, -- potremmo mettere un check con i tipi di lavori possibili
    `data_presentazione` DATETIME NOT NULL,
    `data_approvazione` DATETIME NOT NULL,
    `data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
    `data_fine_effettiva` DATETIME,
    `costo` INT UNSIGNED NOT NULL,
    `edificio` INT NOT NULL, -- FK a edificio
	PRIMARY KEY (`codice`),
    FOREIGN KEY (`edificio`) REFERENCES `Edificio` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_edificio3` ON `ProgettoEdilizio` (`edificio`);

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

CREATE UNIQUE INDEX `index_progetto_edilizio1` ON `StadioDiAvanzamento` (`progetto_edilizio`);

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

CREATE UNIQUE INDEX `index_stadio` ON `LavoroProgettoEdilizio` (`stadio`);

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

CREATE UNIQUE INDEX `index_lavoro1` ON `MaterialeUtilizzato` (`lavoro`);
CREATE UNIQUE INDEX `index_materiale6` ON `MaterialeUtilizzato` (`materiale`);

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

CREATE UNIQUE INDEX `index_lavoratore1` ON `PartecipazioneLavoratoreLavoro` (`lavoratore`);
CREATE UNIQUE INDEX `index_lavoro2` ON `PartecipazioneLavoratoreLavoro` (`lavoro`);

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

CREATE UNIQUE INDEX `index_lavoratore2` ON `SupervisioneLavoro` (`lavoratore`);
CREATE UNIQUE INDEX `index_lavoro3` ON `SupervisioneLavoro` (`lavoro`);

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

CREATE UNIQUE INDEX `index_ora_inizio1` ON `LavoratoreDirigeTurno` (`ora_inizio`);
CREATE UNIQUE INDEX `index_ora_fine1` ON `LavoratoreDirigeTurno` (`ora_fine`);
CREATE UNIQUE INDEX `index_giorno1` ON `LavoratoreDirigeTurno` (`giorno`);

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

CREATE UNIQUE INDEX `index_ora_inizio2` ON `SvolgimentoTurno` (`ora_inizio`);
CREATE UNIQUE INDEX `index_ora_fine2` ON `SvolgimentoTurno` (`ora_fine`);
CREATE UNIQUE INDEX `index_giorno2` ON `SvolgimentoTurno` (`giorno`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Sensore` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`distanza_da_sx` DOUBLE UNSIGNED NOT NULL, 
	`isEsterno` TINYINT NOT NULL CHECK(`isEsterno` IN (0, 1)),
	`soglia` DOUBLE NOT NULL, 
	`parete` INT NOT NULL, -- FK parete
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_parete3` ON `Sensore` (`parete`);

-- ------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `Misurazione` (
	`id_sensore` INT NOT NULL,
	`timestamp` TIMESTAMP NOT NULL, 
	`isAlert` TINYINT NOT NULL CHECK(`isAlert` IN (0, 1)),
	`unita_di_misura` VARCHAR(5) NOT NULL, 
	`valoreX` DOUBLE NOT NULL, -- se y e z sono null x diventa il valore misurato
    `valoreY` DOUBLE,
    `valoreZ` DOUBLE,
	PRIMARY KEY (`id_sensore`, `timestamp`),
    FOREIGN KEY (`id_sensore`) REFERENCES `Sensore` (`ID`)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE = InnoDB;

CREATE UNIQUE INDEX `index_id_sensore` ON `Misurazione` (`id_sensore`);

-- ------------------------------------------------------------------------------------------