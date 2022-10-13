-- Le misure come distanze, lunghezze, larghezze, e altezze sono espresse in cm

DROP DATABASE IF EXISTS SmartBuildings;
CREATE SCHEMA SmartBuildings DEFAULT CHARACTER SET utf8;
USE SmartBuildings;

SET FOREIGN_KEY_CHECKS = 0; -- per togliere il controllo sulla creazione delle FK iniziale (1 = controllo, 0 = non controllo)
SET GLOBAL EVENT_SCHEDULER = ON; -- per avviare lo schedule dei trigger

CREATE TABLE IF NOT EXISTS `Edificio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `esiste` TINYINT NOT NULL CHECK(`esiste` IN (0, 1)) DEFAULT 0, -- di base è in costruzione quindi se è un nuovo edificio sicuramente ancora non è finito
  `tipologia` VARCHAR(45) NOT NULL,
  `stato`VARCHAR(10) NOT NULL CHECK(`stato` IN ('demolire', 'critico', 'buone', 'ottimo')), --  critico = grosse ristrutturazioni, buone = piccole ristrutturazioni
  `area_geografica` INT NOT NULL, -- FK a area geografica
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`area_geografica`) REFERENCES `AreaGeografica` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Piano` (
  `numero` SMALLINT NOT NULL, -- il numero del piano
  `altezza` SMALLINT NOT NULL,
  `inclinazione` TINYINT DEFAULT NULL, -- indica l'angolo di inclinazione del soffitto, se è NULL signfica che non è mansardato [TINYINT perchè più di 90 gradi non può essere]
  `altezza_min` SMALLINT DEFAULT NULL,
  `edificio` INT NOT NULL, -- FK a edificio
  PRIMARY KEY (`numero` , `edificio`),
  FOREIGN KEY (`edificio`) REFERENCES `Edificio` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Vano` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `funzione` VARCHAR(45) NOT NULL,
  `lunghezza` SMALLINT NOT NULL,
  `larghezza` SMALLINT NOT NULL,
  `altezza` SMALLINT NOT NULL,
  `piano` SMALLINT NOT NULL, -- FK a piano
  `edificio` INT NOT NULL, 
  `parquet` INT NOT NULL, -- FK a parquet
  `piastrella` INT NOT NULL, -- FK a piastrella
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`piano`, `edificio`) REFERENCES `Piano` (`numero`, `edificio`),
  FOREIGN KEY (`parquet`) REFERENCES `Parquet` (`ID`),
  FOREIGN KEY (`piastrella`) REFERENCES `Piastrella` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PuntoDiAccesso` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` SMALLINT NOT NULL,
  `larghezza` SMALLINT NOT NULL,
  `altezza` SMALLINT NOT NULL,
  `distanza_da_sx` SMALLINT NOT NULL, -- distanza da sinistra
  `tipo` VARCHAR(45) NOT NULL,
  `apertura` TINYINT NULL CHECK (`apertura` IN(0, 1, 2)) DEFAULT NULL, -- 0 per interna 1 per esterna 2 per a scorrimento
  `altezza_chiave` SMALLINT DEFAULT NULL,
  `angolo_curvatura` TINYINT DEFAULT NULL,
  `parete` INT NOT NULL, -- FK a parete
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Balcone` ( -- i balconi possono essere in comune a + vani
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` SMALLINT NOT NULL,
  `larghezza` SMALLINT NOT NULL,
  `altezza` SMALLINT NOT NULL,
  `altezza_ringhiera` TINYINT NOT NULL,
  `altezza_da_terra` SMALLINT NOT NULL, -- RIDONDANZA (DA VALUTARE SE TENERE) (tenere conto che è una ridondanza che non viene mai aggiornata => ridondandte solo il valore)
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `BalconeVano` ( 
  `balcone` INT NOT NULL,
  `vano` INT NOT NULL,
  PRIMARY KEY (`balcone`, `vano`),
  FOREIGN KEY (`vano`) REFERENCES `Vano` (`ID`),
  FOREIGN KEY (`balcone`) REFERENCES `Balcone` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Finestra` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `larghezza` SMALLINT NOT NULL,
  `lunghezza` SMALLINT NOT NULL,
  `altezza` SMALLINT NOT NULL,
  `distanza_da_sx` SMALLINT NOT NULL,
  `altezza__da_pavimento` SMALLINT NOT NULL,
  `orientamento` VARCHAR(2) NOT NULL CHECK (`orientamento` IN ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),
  `parete` INT NOT NULL, -- FK a parete
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `AreaGeografica` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `nome` INT NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Rischio` (
  `area_geografica` INT NOT NULL,
  `tipo` VARCHAR(45) NOT NULL,
  `coefficiente_ rischio` INT NOT NULL CHECK (`coefficiente_ rischio` BETWEEN 1 AND 10),
  PRIMARY KEY (`area_geografica`, `tipo`),
  FOREIGN KEY (`area_geografica`) REFERENCES `AreaGeografica` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Calamita` (
  `tipo` VARCHAR(45) NOT NULL,
  `data` TIMESTAMP NOT NULL CHECK (`data` <= "2022-08-17 15:25:36"), -- non si può inserire una calamità che non è ancora avvenuta 
	-- HO MESSO UNA TIMESTAMP PERCHÉ AVVIANDOLO DAVA ERRORE DICENDO CHE NON SI POTEVA USARE CURRENT_TIMESTAMP COME FUNZIONE NEL CHECK
	-- Error Code: 3814. An expression of a check constraint 'calamita_chk_1' contains disallowed function: now.
  `gravita` INT NOT NULL CHECK (`gravita` BETWEEN 1 AND 10),
  PRIMARY KEY (`tipo`, `data`)
) ENGINE = InnoDB;
 
CREATE TABLE IF NOT EXISTS `AreaColpita` (
    `area` INT NOT NULL, -- FK a area geografica
    `calamita` INT NOT NULL, -- FK a calamità
    `data`TIMESTAMP NOT NULL, -- FK a calamità
	PRIMARY KEY (`area`, `calamita`, `data`),
    FOREIGN KEY (`area`) REFERENCES `AreaGeografica` (`tipo`),
    FOREIGN KEY (`data`) REFERENCES `AreaGeografica` (`data`),
    FOREIGN KEY (`calamita`) REFERENCES `Calamita` (`ID`)
) ENGINE = InnoDB;


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
  FOREIGN KEY (`pietra`) REFERENCES `Pietra` (`ID`),
  FOREIGN KEY (`mattone`) REFERENCES `Mattone` (`ID`),
  FOREIGN KEY (`vano`) REFERENCES `Vano` (`ID`),
  UNIQUE (`id_parete_vano`, `vano`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Pietra` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `tipo` VARCHAR(45) NOT NULL,
    `peso_medio` INT DEFAULT 0, 
    `superfiecie_media` INT DEFAULT 0,
    `disposizione` TEXT NOT NULL,
    PRIMARY KEY (`ID`)
    FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Mattone` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `materiale_realizzazione` INT DEFAULT 0, 
    `alveolatura` INT DEFAULT NULL, -- FK a alveolatura (se null allora è pieno)
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`alveolatura`) REFERENCES `Alveolatura` (`ID`),
    FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Alveolatura` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `materiale_riempimento` VARCHAR(45) NOT NULL,
    `nome` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Intonaco` (
	`ID`INT NOT NULL AUTO_INCREMENT,
    `colore` VARCHAR(45) NOT NULL,
    `spessore` INT NOT NULL, 
    `tipo` VARCHAR(45) DEFAULT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `StratoIntonaco` (
	`strato` INT NOT NULL, -- numero dello strato dell'intonaco
	`parete` INT NOT NULL,
    `intonaco` INT NOT NULL,
    PRIMARY KEY (`parete`, `intonaco`, `strato`),
    FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`),
    FOREIGN KEY (`intonaco`) REFERENCES `Intonaco` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Parquet`(
  `ID` INT NOT NULL,
  `tipo_legno` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Piastrella`(
  `ID` INT NOT NULL,
  `forma` VARCHAR(30) NOT NULL,
  `larghezza_fuga` INT NOT NULL,
  `motivo`VARCHAR(45) NOT NULL,
  `isStampato` TINYINT DEFAULT 0 CHECK (`isStampato` IN (0,1)), -- 0 non stampato 1 stampato
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`ID`) REFERENCES `Materiale`(`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ProgettoEdilizio` (
    `codice` INT NOT NULL, 
    `tipologia` VARCHAR(45) NOT NULL, -- potremmo mettere un check con i tipi di lavori possibili
    `data_presentazione` DATETIME NOT NULL,
    `data_approvazione` DATETIME NOT NULL,
    `data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
    `costo` INT NOT NULL,
    `edificio` INT NOT NULL, -- FK a edificio
	PRIMARY KEY (`codice`),
    FOREIGN KEY (`edificio`) REFERENCES `Edificio` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `StadioDiAvanzamento` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
    `descrizione` TEXT NOT NULL,
    `progetto_edilizio` INT NOT NULL, -- Fk progetto edilizio
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`progetto_edilizio`) REFERENCES `ProgettoEdilizio` (`codice`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `LavoroProgettoEdilizio` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`tipologia` VARCHAR(45) NOT NULL,
    `isCompleto` TINYINT NOT NULL CHECK(`isCompleto` IN (0, 1)) DEFAULT 0, -- 0 non completo 1 completato
    `stadio` INT NOT NULL, -- FK allo stadio di avanzamento
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`stadio`) REFERENCES `StadioDiAvanzamento` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Materiale` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`nome` VARCHAR(45) NOT NULL, 
    `cod_lotto` INT NOT NULL,
    `fornitore` VARCHAR(45) NOT NULL,
    `largheza` INT NOT NULL,
    `lunghezza` INT NOT NULL,
    `altezza` INT NOT NULL,
    `costituzione` VARCHAR(45) NOT NULL,
    `costo` DOUBLE NOT NULL,
    `unita` VARCHAR(2) NOT NULL, -- unità di misura (costo per kg, hg, g, mq, mc, ecc)
    `data_acquisto` DATETIME NOT NULL,
    `quantita` INT NOT NULL,
	PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `MaterialeUtilizzato` (
	`lavoro` INT NOT NULL, -- FK lavoroProgettoEdilizio
    `materiale` INT NOT NULL, -- FK a materiale
	PRIMARY KEY (`lavoro`, `materiale`),
    FOREIGN KEY (`lavoro`) REFERENCES `LavoroProgettoEdilizio` (`ID`),
    FOREIGN KEY (`materiale`) REFERENCES `Materiale` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Lavoratore` (
    `CF` VARCHAR(16) NOT NULL, 
	`nome` VARCHAR(45) NOT NULL,
    `cognome` VARCHAR(45) NOT NULL, 
    `retribuzione_oraria` INT NOT NULL,
    `tipo` VARCHAR(13) NOT NULL CHECK(`tipo` IN ('semplice', 'responsabile', 'capo cantiere')),
	PRIMARY KEY (`CF`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PartecipazioneLavoratoreProgetto` (
	`lavoratore` INT NOT NULL, -- FK lavoratore
    `progetto` INT NOT NULL, -- FK a progettoEdilizio
	PRIMARY KEY (`lavoratore`, `progetto`),
    FOREIGN KEY (`lavoratore`) REFERENCES `Lavoratore` (`CF`),
    FOREIGN KEY (`progetto`) REFERENCES `ProgettoEdilizio` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SupervisioneLavoro` (
	`lavoratore` INT NOT NULL, -- FK lavoratore
    `lavoro` INT NOT NULL, -- FK a lavoroProgettoEdilizio
	PRIMARY KEY (`lavoratore`, `lavoro`),
    FOREIGN KEY (`lavoratore`) REFERENCES `Lavoratore` (`CF`),
    FOREIGN KEY (`lavoro`) REFERENCES `LavoroProgettoEdilizio` (`ID`),
    UNIQUE (`lavoratore`, `lavoro`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Turno` (
	`ora_inizio` TIME NOT NULL,
    `ora_fine` TIME NOT NULL, -- check per vedere che l'ora di fine sia maggiore di quella di inizio? (=> trigger?)
	`giorno` DATE NOT NULL,
	PRIMARY KEY (`ora_inizio`, `ora_fine`, `giorno`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `LavoratoreDirigeTurno` ( -- il turno può avere più capi cantiere [per aumentare il numero di lavoratori contemporanei]
	`capo_turno` INT NOT NULL, -- FK lavoratore
    `ora_inizio` TIME NOT NULL, -- FK a turno
	`ora_fine` TIME NOT NULL,
	`giorno` DATE NOT NULL,
    `num_lavoratori_monitorabili` INT NOT NULL,
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`capo_cantiere`) REFERENCES `Lavoratore` (`ID`),
    FOREIGN KEY (`ora_inizio`) REFERENCES `Turno` (`ora_inizio`),
    FOREIGN KEY (`ora_fine`) REFERENCES `Turno` (`ora_fine`),
    FOREIGN KEY (`giorno`) REFERENCES `Turno` (`giorno`),
    UNIQUE (`capo_turno`, `ora_inizio`, `ora_fine`, `giorno`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SvolgimentoTurno` ( 
	`lavoratore` INT NOT NULL, -- FK lavoratore
    `ora_inizio` TIME NOT NULL, -- FK a turno
	`ora_fine` TIME NOT NULL,
	`giorno` DATE NOT NULL,
	PRIMARY KEY (`lavoratore`, `ora_inizio`, `ora_fine`, `giorno`),
    FOREIGN KEY (`lavoratore`) REFERENCES `Lavoratore` (`ID`),
    FOREIGN KEY (`ora_inizio`) REFERENCES `Turno` (`ora_inizio`),
    FOREIGN KEY (`ora_fine`) REFERENCES `Turno` (`ora_fine`),
    FOREIGN KEY (`giorno`) REFERENCES `Turno` (`giorno`),
    UNIQUE (`lavoratore`, `ora_inizio`, `ora_fine`, `giorno`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Mansione` (
	`ID` INT NOT NULL, 
	`mansione` VARCHAR(45) NOT NULL,
	PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `MansioneCompiutaTurno` (
	`mansione` INT NOT NULL,
	`ora_inizio` TIME NOT NULL,
	`ora_fine` TIME NOT NULL,
	`giorno` DATE NOT NULL,
	`ore` INT NOT NULL,
	PRIMARY KEY (`mansione`, `ora_inizio`, `ora_fine`, `giorno`),
	FOREIGN KEY (`mansione`) REFERENCES `Mansione` (`ID`),
	FOREIGN KEY (`ora_inizio`) REFERENCES `Turno` (`ora_inizio`),
	FOREIGN KEY (`ora_fine`) REFERENCES `Turno` (`ora_fine`),
	FOREIGN KEY (`giorno`) REFERENCES `Turno` (`giorno`),
	UNIQUE (`mansione`, `ora_inizio`, `ora_fine`, `giorno`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Sensore` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`distanza_da_sx` DOUBLE NOT NULL, 
	`altezza_da_terra` DOUBLE NOT NULL,
	`isEsterno` TINYINT NOT NULL CHECK(`isEsterno` IN (0, 1)),
	`soglia` DOUBLE NOT NULL, 
	`parete` INT NOT NULL, -- FK parete
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Misurazione` (
	`id_sensore` INT NOT NULL,
	`timestamp` TIMESTAMP NOT NULL, 
	`isAlert` TINYINT NOT NULL CHECK(`isEsterno` IN (0, 1)),
	`unità_di_misura` VARCHAR(5) NOT NULL, 
	`valoreX` DOUBLE NOT NULL, -- se y e z sono null x diventa il valore misurato
    `valoreY` DOUBLE,
    `valoreZ` DOUBLE,
	PRIMARY KEY (`id_sensore`, `timestamp`),
    FOREIGN KEY (`id_sensore`) REFERENCES `Sensore` (`ID`)
) ENGINE = InnoDB;
