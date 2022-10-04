-- Le misure come distanze, lunghezze, larghezze, e altezze sono espresse in cm

DROP DATABASE IF EXISTS SmartBuildings;
CREATE SCHEMA SmartBuildings;
USE SmartBuildings;

SET FOREIGN_KEY_CHECKS = 0; -- per togliere il controllo sulla creazione delle FK iniziale (1 = controllo, 0 = non controllo)
SET GLOBAL EVENT_SCHEDULER = ON; -- per avviare lo schedule dei trigger

CREATE TABLE IF NOT EXISTS `Edificio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `esiste` TINYINT NOT NULL CHECK(`esiste` IN (0, 1)) DEFAULT 0, -- di base è in costruzione quindi se è un nuovo edificio sicuramente ancora non è finito
  `tipologia` VARCHAR(45) NOT NULL,
  `topolgia` VARCHAR(45) NOT NULL,
  `area_geografica` INT NOT NULL, -- FK a area geografica
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`area_geografica`) REFERENCES `AreaGeografica` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Piano` (
  `numero` INT NOT NULL, -- il numero del piano
  `largheza` INT NOT NULL,
  `lunghezza` INT NOT NULL,
  `altezza` INT NOT NULL,
  `isMansardato` TINYINT NOT NULL CHECK(`isMansardato` IN (0, 1)) DEFAULT 0, -- di base non è mansardato
  `inclinazione` INT DEFAULT NULL, -- indica l'angolo di inclinazione del soffitto
  `altezza_max` INT DEFAULT NULL,
  `altezza_min` INT DEFAULT NULL,
  `edificio` INT NOT NULL, -- FK a edificio
  PRIMARY KEY (`edificio`, `numero`),
  FOREIGN KEY (`edificio`) REFERENCES `Edificio` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Vano` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `funzione` VARCHAR(45) NOT NULL,
  `forma` VARCHAR(45) NOT NULL, -- la forma del perimetro
  `lunghezza_max` INT NOT NULL,
  `altezza_max` INT NOT NULL,
  `larghezza_max` INT NOT NULL,
  `piano` INT NOT NULL, -- FK a piano
  `pavimentazione` INT NOT NULL, -- FK a pavimentazione
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`piano`) REFERENCES `Piano` (`ID`),
  FOREIGN KEY (`pavimentazione`) REFERENCES `Pavimentazione` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PuntoDiAccesso` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` INT NOT NULL,
  `larghezza` INT NOT NULL,
  `altezza` INT NOT NULL,
  `dDaSx` INT NOT NULL, -- distanza da sinistra
  `da` INT NOT NULL, -- punto di partenza (FK ad un vano?)
  `a` INT NOT NULL, -- punto di arrivo (FK ad un vano?)
  `tipologia` VARCHAR(45) NOT NULL,
  `apertura` TINYINT NULL CHECK (`apertura` IN(0, 1, 2)) DEFAULT NULL, -- 0 per interna 1 per esterna 2 per a scorrimento
  `altezza_chiave` INT DEFAULT NULL,
  `angolo_curvatura` INT DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Balcone` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` INT NOT NULL,
  `larghezza` INT NOT NULL,
  `altezza` INT NOT NULL,
  `altezza_ringhiera` INT NOT NULL,
  `altezza_da_terra` INT NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

-- può essere interessante un trigger per controllare l'adiacenza dei vani che hanno il/i balconi in comune
CREATE TABLE IF NOT EXISTS `BalconeVano` ( 
  `ID` INT NOT NULL AUTO_INCREMENT,
  `balcone` INT NOT NULL,
  `vano` INT NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`vano`) REFERENCES `Vano` (`ID`),
  FOREIGN KEY (`balcone`) REFERENCES `Balcone` (`ID`),
  UNIQUE (`balcone`, `vano`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Finestra` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `larghezza` INT NOT NULL,
  `lunghezza` INT NOT NULL,
  `altezza` INT NOT NULL,
  `parete` INT NOT NULL, -- FK a parete
  `orientamento` VARCHAR(2) NOT NULL CHECK (`orientamento` IN ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`parete`) REFERENCES `Parete` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `AreaGeografica` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `nome` INT NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`rischio`) REFERENCES `Rischio` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Rischio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `tipo` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `RischioArea` (
  `area` INT NOT NULL AUTO_INCREMENT,
  `rischio` VARCHAR(45) NOT NULL,
  `coefficiente_ rischio` INT NOT NULL CHECK (`coefficiente_ rischio` BETWEEN 1 AND 10),
  PRIMARY KEY (`area`, `rischio`),
  FOREIGN KEY (`area`) REFERENCES `AreaGeografica` (`ID`),
  FOREIGN KEY (`rischio`) REFERENCES `Rischio` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Calamita` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `tipo` VARCHAR(45) NOT NULL,
  `data` TIMESTAMP NOT NULL CHECK (`data` <= "2022-08-17 15:25:36"), -- non si può inserire una calamità che non è ancora avvenuta 
	-- HO MESSO UNA TIMESTAMP PERCHÉ AVVIANDOLO DAVA ERRORE DICENDO CHE NON SI POTEVA USARE CURRENT_TIMESTAMP COME FUNZIONE NEL CHECK
	-- Error Code: 3814. An expression of a check constraint 'calamita_chk_1' contains disallowed function: now.
  `gravita` INT NOT NULL CHECK (`gravita` BETWEEN 1 AND 10),
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;
 
CREATE TABLE IF NOT EXISTS `AreaColpita` (
    `area` INT NOT NULL, -- FK a area geografica
    `calamita` INT NOT NULL, -- FK a calamità
	PRIMARY KEY (`area`, `calamita`),
    FOREIGN KEY (`area`) REFERENCES `AreaGeografica` (`ID`),
    FOREIGN KEY (`calamita`) REFERENCES `Calamita` (`ID`)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `Parete` (
  `orientamento` VARCHAR(2) NOT NULL CHECK (`orientamento` IN ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),
  `isRicopertoPietra` TINYINT NOT NULL CHECK (`isRicopertoPietra` IN (0, 1)) DEFAULT 0,
  `angolo` INT NOT NULL CHECK (`angolo` BETWEEN 1 AND 359 AND `angolo` <> 180), -- l'angolo in questione è quello tra la parete del
										-- record e quella con l'id successivo, nel caso dell'ultima parete sarà tra l'ultima e la prima
  `intonaco` INT NOT NULL, -- FK a intonaco
  `pietra` INT DEFAULT NULL, -- FK a pietra
  `id_parete_vano` INT NOT NULL, -- serve per identificare a quale parete si fa riferimento all'interno del vano.
				 -- 1 è pavimento, il max è il soffitto, gli altri sono in ordine crescente a partire da sinistra dell'ingresso in senso orario
				 -- (DA RIVEDERE NUMERAZIONE, secondo me andrebbe fatta secondo i punti cardinali, se un vano ha più ingressi non si capisce)
  `mattone` INT NOT NULL, -- FK al tipo di mattone
  `vano` INT NOT NULL, -- FK al vano
  PRIMARY KEY (`id_parete_vano`, `vano`),
  FOREIGN KEY (`intonaco`) REFERENCES `Intonaco` (`ID`),
  FOREIGN KEY (`pietra`) REFERENCES `Pietra` (`ID`),
  FOREIGN KEY (`mattone`) REFERENCES `Mattone` (`ID`),
  FOREIGN KEY (`vano`) REFERENCES `Vano` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Pietra` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `tipo` VARCHAR(45) NOT NULL,
    `peso_medio` INT DEFAULT 0, 
    `superfiecie_media` INT DEFAULT 0,
    `disposizione` TINYINT NOT NULL CHECK(`disposizione` IN (0, 1)) DEFAULT 0, -- 0 verticale 1 orizzontale (non so se intendevi questo con disposizione)
									       -- Credo che la disposizione dovrebbe essere varchar (una breve descrizione)
									       -- ([...] pietre usate su quella parete, e qual è la loro disposizione)
    PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Mattone` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `isAlveolato` TINYINT NOT NULL CHECK(`isAlveolato` IN (0, 1)), -- 0 non è presente alveolatura quindi pieno 1 è alveolato
    `materiale_realizzazione` INT DEFAULT 0, 
    `alveolatura` INT DEFAULT NULL, -- FK a alveolatura
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`alveolatura`) REFERENCES `Alveolatura` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Alveolatura` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `materiale_riempimento` VARCHAR(45) NOT NULL,
    `nome` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Intonaco` (
	`id_intonaco_parete` INT NOT NULL,
    `colore` VARCHAR(45) NOT NULL,
    `spessore` INT NOT NULL, 
    `tipo` VARCHAR(45) DEFAULT NULL,
    `parete` INT NOT NULL,
    `vano` INT NOT NULL,
    PRIMARY KEY (`id_intonaco_parete`, `parete`, `vano`),    
    FOREIGN KEY (`parete`) REFERENCES `Parete` (`id_parete_vano`),
    FOREIGN KEY (`vano`) REFERENCES `Parete` (`vano`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Pavimentazione` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `forma` VARCHAR(45) NOT NULL,
    `tipo` VARCHAR(12) NOT NULL CHECK (`tipo` IN ('parquet', 'piastrellato')),
    `colore` VARCHAR(45) NOT NULL,
    `materiale` VARCHAR(45) NOT NULL, -- tipo di materiale (ex. Acero per il parquet, Marmo di carrara per le piastrelle)
    `materiale_adesivo` VARCHAR(45) NOT NULL, -- con cosa sono attaccate
    `lunghezza` INT NOT NULL,
    `larghezza` INT NOT NULL, 
    `spessore` INT NOT NULL,
    `larghezza_ fuga` INT DEFAULT NULL, -- è presente solo se il tipo è piastrellato (=> trigger?)
    `motivo` INT DEFAULT NULL, -- FK a motivo è presente solo è piastrellato
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`motivo`) REFERENCES `Motivo` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Motivo` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `motivo` VARCHAR(45) NOT NULL, -- descrizone del motivo
    `isStampato` TINYINT NOT NULL CHECK(`isStampato` IN (0, 1)),
	PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ProgettoEdilizio` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `codice` INT NOT NULL, 
    `tipologia` VARCHAR(45) NOT NULL, -- potremmo mettere un check con i tipi di lavori possibili
    `data_presentazione` DATETIME NOT NULL,
    `data_approvazione` DATETIME NOT NULL,
    `data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
    `edificio` INT NOT NULL, -- FK a edificio
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`edificio`) REFERENCES `Edificio` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `StadioDiAvanzamento` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
    `progetto_edilizio` INT NOT NULL,
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`progetto_edilizio`) REFERENCES `ProgettoEdilizio` (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `LavoroProgettoEdilizio` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`tipologia` VARCHAR(45) NOT NULL,
    `costo` INT DEFAULT NULL,
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
    `unita_costo` VARCHAR(2) NOT NULL, -- unità di misura (costo per kg, hg, g, mq, mc, ecc)
    `data_acquisto` DATETIME NOT NULL,
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
	`nome` VARCHAR(45) NOT NULL,
    `cognome` VARCHAR(45) NOT NULL, 
    `CF` VARCHAR(16) NOT NULL, 
    `retribuzione_oraria` INT NOT NULL,
    `tipo` VARCHAR(13) NOT NULL CHECK(`tipo` IN ('semplice', 'responsabile', 'capo cantiere')),
    -- nell'er avevamo messo numero lavoratori monitorabili ma secondo me va tolgo perchè il numero è fissato per legge,
    -- quindi possiamo aggiungerlo come controllo in inserimento del turno di un lavoratore
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
	`ora_inizio` INT NOT NULL,
    `ora_fine` INT NOT NULL, -- check per vedere che l'ora di fine sia maggiore di quella di inizio? (=> trigger?)
	PRIMARY KEY (`ora_inizio`, `ora_fine`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `TurnoCapo` ( -- il turno può avere più capi cantiere [per aumentare il numero di lavoratori contemporanei]
	`capo_cantiere` INT NOT NULL, -- FK lavoratore
    `turno` INT NOT NULL, -- FK a turno
	`giorno` DATETIME NOT NULL,
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`capo_cantiere`) REFERENCES `Lavoratore` (`ID`),
    FOREIGN KEY (`turno`) REFERENCES `Turno` (`ID`),
    UNIQUE (`capo_cantiere`, `turno`, `giorno`)
    
    -- DA RIVEDERE QUANDO FINIAMO TURNO
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SvolgimentoTurno` ( 
	`ID` INT NOT NULL AUTO_INCREMENT,
	`lavoratore` INT NOT NULL, -- FK lavoratore
    `turno` INT NOT NULL, -- FK a turno
    `mansione` VARCHAR(45) NOT NULL,
    `giorno` DATETIME NOT NULL,
    `ore_lavorate` INT NOT NULL,
	PRIMARY KEY (`ID`),
    FOREIGN KEY (`lavoratore`) REFERENCES `Lavoratore` (`ID`),
    FOREIGN KEY (`turno`) REFERENCES `Turno` (`ID`),
    UNIQUE (`lavoratore`, `turno`, `giorno`, `mansione`)
    
    -- DA RIVEDERE QUANDO FINIAMO TURNO
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
	`id_sensore` INT NOT NOT,
	`timestamp`TIMESTAMP NOT NULL, 
	`isAlert` TINYINT NOT NULL CHECK(`isEsterno` IN (0, 1)),
	`unità_di_misura` VARCHAR NOT NULL, 
	`valoreX` DOUBLE NOT NULL, -- se y e z sono null x diventa il valore misurato
    `valoreY` DOUBLE,
    `valoreZ` DOUBLE,
	PRIMARY KEY (`id_sensore`, `timestamp`),
    FOREIGN KEY (`id_sensore`) REFERENCES `Sensore` (`ID`)
) ENGINE = InnoDB;