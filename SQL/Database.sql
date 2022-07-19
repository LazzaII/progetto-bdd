-- RICONTROLLARE LE FK
-- [Sicuramente vanno create le relazioni tra le tabelle]
-- Manca la parte dei sensori [verde] + manca da rivedere installazioneSenosre [blu] che è presente ma c'è ancora il mio commento su draw.io

DROP DATABASE IF EXISTS SmartBuildings;
CREATE SCHEMA SmartBuildings;
USE SmartBuildings;

SET FOREIGN_KEY_CHECKS = 1; -- per togliere il controllo sulla creazione delle FK iniziale
SET GLOBAL EVENT_SCHEDULER = ON; -- per avviare lo schedule dei trigger

CREATE TABLE IF NOT EXISTS `Edificio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `esiste` TINYINT NOT NULL CHECK(`esiste` IN (0, 1)) DEFAULT 0, -- di base è in costruzione quindi se è un nuovo edificio sicuramente ancora non è finito
  `tipologia` VARCHAR(45) NOT NULL,
  `topolgia` VARCHAR(45) NOT NULL,
  `area_geografica` INT NOT NULL, -- FK a area geografica
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `Piano` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `numero` INT NOT NULL, -- il numero del piano
  `largheza` INT NOT NULL,
  `lunghezza` INT NOT NULL,
  `altezza` INT NOT NULL,
  `isMansardato` TINYINT NOT NULL CHECK(`isMansardato` IN (0, 1)) DEFAULT 0, -- di base non è mansardato
  `inclinazione` INT DEFAULT NULL, -- indica l'angolo di inclinazione del soffitto
  `altezza_max` INT DEFAULT NULL,
  `altezza_min` INT DEFAULT NULL,
  PRIMARY KEY (`ID`)
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
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PuntoDiAccesso` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lunghezza` INT NOT NULL,
  `larghezza` INT NOT NULL,
  `altezza` INT NOT NULL,
  `dDaSx` INT NOT NULL, -- distanza da sinistra
  `da` INT NOT NULL, -- punto di parte
  `a` INT NOT NULL, -- punto di arrivo
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
  UNIQUE (`balcone`, `vano`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Finestra` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `larghezza` INT NOT NULL,
  `lunghezza` INT NOT NULL,
  `altezza` INT NOT NULL,
  `parete` INT NOT NULL, -- FK a parete
  `orientamento` VARCHAR(2) NOT NULL CHECK (`orientamento` IN ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `AreaGeografica` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `nome` INT NOT NULL,
  `rischio` INT NOT NULL, -- FK a rischio
  `coefficiente_ rischio` INT NOT NULL CHECK (`coefficiente_ rischio` BETWEEN 1 AND 10), -- dipende dal rischio ma può variare da zona a zona per questo è nell'area geografica
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Rischio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `tipo` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Calamita` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `tipo` VARCHAR(45) NOT NULL,
  `data` TIMESTAMP NOT NULL CHECK (`data` <= CURRENT_TIMESTAMP()), -- non si può inserire una calamità che non è ancora avvenuta
  `gravita` INT NOT NULL CHECK (`coefficiente_ rischio` BETWEEN 1 AND 10),
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `AreaColpita` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `area` INT NOT NULL, -- FK a area geografica
    `calamita` INT NOT NULL, -- FK a calamità
	PRIMARY KEY (`ID`),
    UNIQUE (`area`, `calamita`) -- Le due FK devono essere uniche
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Danno` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `entita` INT NOT NULL,
  `edificio` INT NOT NULL, -- sicuri che va messo qua? perchè sarebbe una fk all'edificio però non l'abbiamo collegata in nessun modo
  `tipo_danno` INT NOT NULL, -- FK
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `TipoDanno` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ParteCoinvoltaDanno` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `tipo` VARCHAR(45) NOT NULL,
  `parte_danneggiata` VARCHAR(45) NOT NULL,
  `danno` INT NOT NULL, -- FK a danno
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `LavoroPostDanno` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `tipo_di_lavoro` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `LavoriNecessari` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `lavoro` VARCHAR(45) NOT NULL, -- FK a lavoroPostDanno
  `parte_coinvolta` VARCHAR(45) NOT NULL, -- FK a parte coinvolta danno
  PRIMARY KEY (`ID`),
  UNIQUE (`lavoro`, `parte_coinvolta`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `InstallazioneSensore` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `data` DATETIME NOT NULL,
  `condizione_danno` VARCHAR(45) NOT NULL,
  `tipo_danno` INT NOT NULL, -- FK a tipo danno
  PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

-- lo schema logico arriva qua

CREATE TABLE IF NOT EXISTS `Parete` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `orientamento` VARCHAR(2) NOT NULL CHECK (`orientamento` IN ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),
  `isRicopertoPietra` TINYINT NOT NULL CHECK(`isRicopertoPietra` IN (0, 1)) DEFAULT 0,
  `intonaco` INT NOT NULL, -- FK a intonaco
  `pietra` INT DEFAULT NULL, -- FK a pietra
  `id_parete_vano` INT NOT NULL, -- serve per identificare a quale parete si fa riferimento all'interno del vano.
				 -- 1 è pavimento, il max è il soffitto, gli altri sono in ordine crescente a partire da sinistra dell'ingresso in senso orario
				 -- (DA RIVEDERE NUMERAZIONE, secondo me andrebbe fatta secondo i punti cardinali, se un vano ha più ingressi non si capisce)
  `mattone` INT NOT NULL, -- FK al tipo di mattone
  PRIMARY KEY (`ID`)
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
    PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Alveolatura` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `materiale_riempimento` VARCHAR(45) NOT NULL,
    `nome` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Intonaco` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `descrizione` VARCHAR(45) NOT NULL,
    `spessore1` INT NOT NULL, 
    `spessore2` INT DEFAULT NULL,
    `spessore3` INT DEFAULT NULL,
    PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Pavimentazione` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `forma` VARCHAR(45) NOT NULL,
    `tipo` VARCHAR(12) NOT NULL CHECK(`tipo` IN (`parquet`, `piastrellato`)),
    `colore` VARCHAR(45) NOT NULL,
    `materiale` VARCHAR(45) NOT NULL, -- tipo di materiale (ex. Acero per il parquet, Marmo di carrara per le piastrelle)
    `materiale_adesivo` VARCHAR(45) NOT NULL, -- con cosa sono attaccate
    `lunghezza` INT NOT NULL,
    `larghezza` INT NOT NULL, 
    `spessore` INT NOT NULL,
    `larghezza_ fuga` INT DEFAULT NULL, -- è presente solo se il tipo è piastrellato (=> trigger?)
    `motivo` INT DEFAULT NULL, -- FK a motivo è presente solo è piastrellato
    PRIMARY KEY (`ID`)
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
    `stadio_avanzamento` INT NOT NULL, -- FK a stadio avanzamento si aggiorna via via
    `edificio` INT NOT NULL, -- FK a edificio
	PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `StadioDiAvanzamento` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
	PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `StadioDiAvanzamento` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`data_inizio` DATETIME NOT NULL,
    `data_stima_fine` DATETIME NOT NULL,
	PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `LavoroProgettoEdilizio` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`tipologia` VARCHAR(45) NOT NULL,
    `costo` INT DEFAULT NULL,
    `isCompleto` TINYINT NOT NULL CHECK(`isCompleto` IN (0, 1)) DEFAULT 0, -- 0 non completo 1 completato
    `stadio` INT NOT NULL, -- FK allo stadio di avanzamento
	PRIMARY KEY (`ID`)
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
    `costo` INT NOT NULL,
    `unita_costo` INT NOT NULL, -- non trovo l'unità del costo unitario se non è presente quanto ne viene usato
    `data_acquisto` DATETIME NOT NULL,
	PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `MaterialeUtilizzato` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`lavoro` INT NOT NULL, -- FK lavoroProgettoEdilizio
    `materiale` INT NOT NULL, -- FK a materiale
	PRIMARY KEY (`ID`),
    UNIQUE (`lavoro`, `materiale`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Lavoratore` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`nome` VARCHAR(45) NOT NULL,
    `cognome` VARCHAR(45) NOT NULL, 
    `CF` VARCHAR(16) NOT NULL, 
    `retribuzione_oraria` INT NOT NULL,
    `isResponsabile` TINYINT NOT NULL CHECK(`isResponsabile` IN (0, 1)) DEFAULT 0, 
    -- nell'er avevamo messo numero lavoratori monitorabili ma secondo me va tolgo perchè il numero è fissato per legge,
    -- quindi possiamo aggiungerlo come controllo in inserimento del turno di un lavoratore
	PRIMARY KEY (`ID`),
    UNIQUE (`CF`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PartecipazioneLavoratoriProgetti` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`lavoratore` INT NOT NULL, -- FK lavoratore
    `progetto` INT NOT NULL, -- FK a progettoEdilizio
	PRIMARY KEY (`ID`),
    UNIQUE (`lavoratore`, `progetto`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SupervisioneLavori` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`lavoratore` INT NOT NULL, -- FK lavoratore
    `lavoro` INT NOT NULL, -- FK a lavoroProgettoEdilizio
	PRIMARY KEY (`ID`),
    UNIQUE (`lavoratore`, `lavoro`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Turno` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`ora_inizio` INT NOT NULL,
    `ora_fine` INT NOT NULL, -- check per vedere che l'ora di fine sia maggiore di quella di inizio? (trigger?)
	PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `TurniCapi` ( -- il turno può avere più capi cantiere [per aumentare il numero di lavoratori contemporanei]
	`ID` INT NOT NULL AUTO_INCREMENT,
	`capo_cantiere` INT NOT NULL, -- FK lavoratore
    `turno` INT NOT NULL, -- FK a turno
	`giorno` DATETIME NOT NULL,
	PRIMARY KEY (`ID`),
    UNIQUE (`capo_cantiere`, `progetto`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SvolgimentoTurno` ( -- il turno può avere più capi cantiere [per aumentare il numero di lavoratori contemporanei]
	`ID` INT NOT NULL AUTO_INCREMENT,
	`lavoratore` INT NOT NULL, -- FK lavoratore
    `turno` INT NOT NULL, -- FK a turno
    `mansione` VARCHAR(45) NOT NULL,
    `giorno` DATETIME NOT NULL,
    `ore_lavorate` INT NOT NULL, -- potrebbe lavorare meno ore per un permesso
	PRIMARY KEY (`ID`),
    UNIQUE (`capo_cantiere`, `progetto`)
) ENGINE = InnoDB;

-- mancano solo i sensori
















