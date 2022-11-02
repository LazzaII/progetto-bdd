# File per popolare il database

USE SmartBuildings;

INSERT INTO `AreaGeografica` (`nome`) VALUES
('Garfagna-Lunigiana'),
('Chianti'),
('Salento'),
('Alto Adige'),
('Porto Cervo');

INSERT INTO `Turno`(`ora_inizio`, `ora_fine`, `giorno`, `mansione`) VALUES 
('09:00:00', '13:00:00', '2022-08-01', 'Imbiancamento parete'),
('14:00:00', '18:00:00', '2022-08-01', 'Installazione porte e finestre'),
('08:00:00', '14:00:00', '2022-08-02', 'Demolizione muro'),
('15:00:00', '18:00:00', '2022-08-02', 'Posatura piastrelle'),
('09:00:00', '13:00:00', '2022-08-03', 'Posatura parquet'),
('14:00:00', '19:00:00', '2022-08-03', 'Posa delle fondamenta'),
('08:00:00', '12:00:00', '2022-08-04', 'Costruzione balcone'),
('13:00:00', '17:30:00', '2022-08-04', 'Costruzione balcone'),
('09:30:00', '13:30:00', '2022-08-05', 'Rifacimento tetto'),
('14:00:00', '18:00:00', '2022-08-05', 'Installazione lucernari');

INSERT INTO `Calamita`(`tipo`) VALUES 
('Incendio'),
('Terremoto'),
('Inondazione'),
('Uragano'),
('Eruzione vulcanica'),
('Frana');

INSERT INTO `Balcone`(`lunghezza`, `larghezza`, `altezza`, `altezza_ringhiera`) VALUES
(90, 230, 10, 110),
(95, 240, 8, 100),
(120, 190, 8, 90),
(110, 220, 9, 95),
(100, 170, 10, 115),
(95, 200, 8, 100),
(80, 210, 10, 95),
(85, 160, 9, 100),
(100, 200, 9, 115),
(250, 180, 8, 100),
(240, 230, 8, 95),
(200, 170, 9, 105),
(190, 160, 8, 90),
(180, 150, 9, 105),
(230, 180, 9, 110),
(125, 300, 12, 80);

INSERT INTO `Alveolatura` (`nome`, `descrizione`, `materiale_riempimento`) VALUES
('Alveotherm MO 390', '17 file di camere', NULL),
('Alveotherm A250 07', '7 file di camere', NULL),
('Excelsior SE160', 'Blocco da Solaio', NULL),
('Biopor 35', 'Certificato doppia posa', 'stucco'), -- isolante
('Forata F200', '4 file di camere', 'stucco'); -- isolante

-- Inserimento materiali generici
CALL valorizzazioneMateriale ('Sbarra di acciaio - sa1', 17892, 'SteelMaster', 120, 10, 6, 'robusta, resistente', 0.70, 'k', CURRENT_DATE(), 82, 'grigio');
CALL valorizzazioneMateriale ('Sbarra di acciaio - sa2', 17897, 'SteelMaster', 180, 12, 8, 'robusta, resistente', 0.90, 'k', CURRENT_DATE(), 76, 'grigio');
CALL valorizzazioneMateriale ('Marmo B', 18462, 'CarraiaMarble', 20, 20, 3, 'lucida, resistente', 50.25, 'mq', CURRENT_DATE(), 90, 'bianco');
CALL valorizzazioneMateriale ('Marmo Botticino', 18471, 'CarraiaMarble', 30, 25, 3, 'lucida, resistente', 60.35, 'mq', CURRENT_DATE(), 78, 'bianco');
CALL valorizzazioneMateriale ('Marmo N', 18489, 'CarraiaMarble', 35, 35, 3, 'lucida, resistente', 75.80, 'mq', CURRENT_DATE(), 110, 'nero');
CALL valorizzazioneMateriale ('Granito levigato G', 12709, 'GranitePro', 120, 10, 6, 'resistente', 47.90, 'mq', CURRENT_DATE(), 120, 'grigio');
CALL valorizzazioneMateriale ('Granito levigato N', 12719, 'GranitePro', 120, 10, 6, 'opaco, resistente', 51.20, 'mq', CURRENT_DATE(), 132, 'nero');
CALL valorizzazioneMateriale ('Granito liscio', 12729, 'GranitePro', 120, 10, 6, 'lucido, resistente', 80.10, 'mq', CURRENT_DATE(), 107, 'rosa');
CALL valorizzazioneMateriale ('Cemento a presa rapida', 11091, 'CemexMaker', 0, 0, 0, 'polvere', 0.20, 'kg', CURRENT_DATE(), 190, 'grigio');
CALL valorizzazioneMateriale ('Cemento bianco', 11092, 'CemexMaker', 0, 0, 0, 'polvere', 0.35, 'kg', CURRENT_DATE(), 110, 'bianco');

-- Inserimento mattoni
CALL valorizzazioneMateriale ('Mattone - L', 12781, 'SuperBricks', 20, 8, 12, 'versatile, resistente', 30, 'mq', CURRENT_DATE(), 120, 'rosso');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Mattone - L';
INSERT INTO `Mattone` VALUES (@id, 'Laterizio', NULL);

CALL valorizzazioneMateriale ('Mattone - C', 12782, 'SuperBricks', 20, 8, 12, 'versatile, resistente', 32, 'mq', CURRENT_DATE(), 128, 'grigio');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Mattone - C';
INSERT INTO `Mattone` VALUES (@id, 'Calcestruzzo', 3);

CALL valorizzazioneMateriale ('Mattone - FL', 12783, 'SuperBricks', 20, 8, 12, 'versatile, resistente, forato', 36, 'mq', CURRENT_DATE(), 100, 'rosso');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Mattone - FL'; -- forato 
INSERT INTO `Mattone` VALUES (@id, 'Laterizio', 5);

CALL valorizzazioneMateriale ('Mattone paramano', 12784, 'SuperBricks', 20, 8, 12, 'versatile, resistente', 48, 'mq', CURRENT_DATE(), 87, 'rosso');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Mattone paramano'; 
INSERT INTO `Mattone` VALUES (@id, 'Laterizio', NULL);

CALL valorizzazioneMateriale ('Blocco di cemento', 12785, 'SuperBricks', 20, 8, 12, 'versatile, resistente, forato', 38, 'mq', CURRENT_DATE(), 210, 'grigio');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Blocco di cemento'; 
INSERT INTO `Mattone` VALUES (@id, 'Cemento', 4);

CALL valorizzazioneMateriale ('Mattone semipieno', 12786, 'SuperBricks', 20, 8, 12, 'versatile, resistente', 35, 'mq', CURRENT_DATE(), 98, 'rosso');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Mattone semipieno';  
INSERT INTO `Mattone` VALUES (@id, 'Laterizio', 1);

CALL valorizzazioneMateriale ('Mattone estruso', 12787, 'SuperBricks', 20, 8, 12, 'versatile, resistente, forato', 40, 'mq', CURRENT_DATE(), 90, 'rosso');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Mattone estruso';  
INSERT INTO `Mattone` VALUES (@id, 'Laterizio', 2);

CALL valorizzazioneMateriale ('Mattone vetrocemento', 12788, 'SuperBricks', 20, 8, 12, 'versatile, estetico, trasparente', 50, 'mq', CURRENT_DATE(), 86, 'trasparente');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Mattone vetrocemento'; 
INSERT INTO `Mattone` VALUES (@id, 'Vetro', NULL);

-- Inserimento pietre
CALL valorizzazioneMateriale ('Cubo in porfido', 14111, 'PorphyryErs', 4, 6, 6, 'ruvido', 14, 'mq', CURRENT_DATE(), 92, 'marrone-grigio');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Cubo in porfido'; 
INSERT INTO `Pietra` VALUES (@id, '4/6', 0.19, 24, 'ventaglio');

CALL valorizzazioneMateriale ('Cubo in luserna', 14112, 'LusernErs', 12, 12, 4, 'ruvido', 22, 'mq', CURRENT_DATE(), 102, 'marrone-grigio');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Cubo in luserna'; 
INSERT INTO `Pietra` VALUES (@id, '12/12', 0.23, 144, 'posa lineare - fila dritta');

CALL valorizzazioneMateriale ('Blocco in arenaria', 14113, 'SandstonErs', 40, 40, 1, 'levigato', 139, 'mq', CURRENT_DATE(), 73, 'grigio');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Blocco in arenaria'; 
INSERT INTO `Pietra` VALUES (@id, 'pietra serena - grana fine', 0.22, 160, 'mista - casuale');

-- Inserimento intonaco
CALL valorizzazioneMateriale ('Intonaco C', 14117, 'PlasterPros', 0, 0, 0, 'liscio', 14, 'mq', CURRENT_DATE(), 285, 'bianco');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Intonaco civile'; 
INSERT INTO `Intonaco` VALUES (@id, 0.6, 'civile');

CALL valorizzazioneMateriale ('Intonaco D-1', 14118, 'PlasterPros', 0, 0, 0, 'liscio', 18, 'mq', CURRENT_DATE(), 170, 'rosso');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Intonaco  D'; 
INSERT INTO `Intonaco` VALUES (@id, 0.5, 'decorativo');

CALL valorizzazioneMateriale ('Intonaco R', 14119, 'PlasterPros', 0, 0, 0, 'scanalato, resistente', 18, 'mq', CURRENT_DATE(), 165, 'giallo');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Intonaco R'; 
INSERT INTO `Intonaco` VALUES (@id, 0.5, 'rustico');

CALL valorizzazioneMateriale ('Intonaco P', 14120, 'PlasterPros', 0, 0, 0, 'liscio, versatile', 16, 'mq', CURRENT_DATE(), 200, 'bianco');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Intonaco P'; 
INSERT INTO `Intonaco` VALUES (@id, 0.3, 'per piastrelle');

CALL valorizzazioneMateriale ('Intonaco T', 14120, 'PlasterPros', 0, 0, 0, 'ruvido', 14, 'mq', CURRENT_DATE(), 90, 'bianco');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Intonaco T'; 
INSERT INTO `Intonaco` VALUES (@id, 0.3, 'per tappezzeria');

-- Inserimento parquet
CALL valorizzazioneMateriale ('Legno massello', 15001, 'WoodMasters', 7, 42, 1, 'resistente', 30, 'mq', CURRENT_DATE(), 90, 'marrone');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Legno massello'; 
INSERT INTO `Parquet` VALUES (@id, 'spina di pesce');

CALL valorizzazioneMateriale ('Legno di quercia', 15002, 'WoodMasters', 6.5, 40, 1, 'resistente', 42, 'mq', CURRENT_DATE(), 90, 'marrone');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Legno di quercia'; 
INSERT INTO `Parquet` VALUES (@id, 'parallela');

CALL valorizzazioneMateriale ('Legno di noce', 15003, 'WoodMasters', 6.5, 45, 1, 'resistente', 38, 'mq', CURRENT_DATE(), 110, 'marrone');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Legno di noce'; 
INSERT INTO `Parquet` VALUES (@id, 'parallela sfalsata');

CALL valorizzazioneMateriale ('Legno di rovere', 15004, 'WoodMasters', 7, 39, 1, 'resistente', 36, 'mq', CURRENT_DATE(), 64, 'marrone');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Legno di rovere'; 
INSERT INTO `Parquet` VALUES (@id, 'ungherese chiusa');

-- Inserimento piastrelle
CALL valorizzazioneMateriale ('Piastrelle zephyr', 15015, 'NovoCeram', 30, 30, 6, 'fragile', 9, 'mq', CURRENT_DATE(), 118, 'oro');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Piastrelle zephyr'; 
INSERT INTO `Piastrella` VALUES (@id, 0.5, 'Colori misti', 0);

CALL valorizzazioneMateriale ('Piastrelle osmose', 15016, 'NovoCeram', 30, 60, 8, 'fragile', 12, 'mq', CURRENT_DATE(), 100, 'grigio-oro-bianco');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Piastrelle osmose'; 
INSERT INTO `Piastrella` VALUES (@id, 0.4, 'Esagoni con colori misti', 1);

CALL valorizzazioneMateriale ('Piastrelle bloom', 15017, 'NovoCeram', 30, 60, 4, 'fragile', 11, 'mq', CURRENT_DATE(), 97, 'rosso-verde-blu-giallo');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Piastrelle bloom'; 
INSERT INTO `Piastrella` VALUES (@id, 0.4, 'Motivo floreale con colori misti', 1);

CALL valorizzazioneMateriale ('Piastrelle performance', 15018, 'NovoCeram', 30, 30, 6, 'fragile', 8, 'mq', CURRENT_DATE(), 81, 'beige');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Piastrelle performance'; 
INSERT INTO `Piastrella` VALUES (@id, 0.5, 'Colore unico', 0);

-- Inserimento lavoratori
INSERT INTO `Lavoratore` (`CF`, `nome`, `cognome`, `retribuzione_oraria`, `tipo`) VALUES 
('MRORSI97M09D612B', 'Mario', 'Rossi', 8.7, 'semplice'),
('VRILII99D612I', 'Luigi', 'Verdi', 8.4, 'semplice'),
('FACGAL85P600D', 'Franco', 'Gialli', 10.9, 'responsabile'),
('VOATRH89S612P', 'Viola', 'Turchesi', 12.4, 'capo cantiere'),
('MRANRI92L611P', 'Marta', 'Neri', 11.9, 'capo cantiere'),
('AABACI99Z475A', 'Ada', 'Bianchi', 8.2, 'semplice'),
('AVRRSI82P098M', 'Alvaro', 'Rosi', 9.0, 'semplice'),
('UGOAAN94K032L', 'Ugo', 'Arancioni', 8.7, 'semplice'),
('RMOMRO643S102H', 'Romano', 'Marroni', 8.1, 'semplice'),
('UBRBLU456D612D', 'Umberto', 'Blu', 11.6, 'responsabile');

-- Inserimento rischi
INSERT INTO `Rischio` (`area_geografica`, `tipo`, `coefficiente_rischio`) VALUES 
(1, `Terremoto`, 8),
(1, 'Frana', 10),
(5, 'Tromba aria', 9),
(5, 'Incendio', 2),
(2, 'Frana', 8),
(3, 'Incendio', 9),
(4, 'Alluvione', 6);

-- Inserimento edifici
INSERT INTO `Edificio` (`isFinito`, `tipologia`, `stato`, `area_geografica`) VALUES 
(1, 'Palazzo', 100, 1),
(0, 'Villetta a schiera', 75, 5);

-- Inserimento piani 
INSERT INTO `Piano` (`numero`, `altezza`, `inclinazione`, `altezza_min`, `edificio`) VALUES 
(1, 360, NULL, NULL, 1),
(2, 360, NULL, NULL, 1),
(3, 380, 60, 320, 1),
(1, 380, NULL, NULL, 2),
(2, 380, NULL, NULL, 2),
(3, 410, 70, 360, 2);

-- Inserimento vani
INSERT INTO `Vano` (`edificio`, `piano`, `lunghezza`, `larghezza`, `funzione`, `parquet`, `piastrella`) VALUES 
(1, 1, 400, 300, 'Cucina', NULL, 4),
(1, 1, 290, 350, 'Sala da pranzo', NULL, 4),
(1, 1, 430, 200, 'Soggiorno', NULL, 2),
(1, 1, 390, 400, 'Camera da letto', NULL, 1),
(1, 1, 400, 360, 'Camera da letto', 3, NULL),
(1, 2, 350, 400, 'Cucina', NULL, 4),
(1, 2, 450, 350, 'Sala da pranzo', 2, NULL),
(1, 2, 360, 380, 'Soggiorno', 2, NULL),
(1, 2, 420, 410, 'Camera da letto', NULL, 1),
(1, 2, 320, 380, 'Soggiorno', 3, NULL),
(1, 3, 400, 360, 'Cucina', NULL, 4),
(1, 3, 330, 400, 'Sala da pranzo', 2, NULL),
(1, 3, 390, 390, 'Soggiorno', 3, NULL),
(1, 3, 420, 400, 'Camera da letto', NULL, 1),
(1, 3, 315, 310, 'Camera da letto', 3, NULL),
(2, 1, 350, 280, 'Cucina', NULL, 2),
(2, 1, 400, 330, 'Sala da pranzo', NULL, 2),
(2, 1, 400, 220, 'Cucina', NULL, 3),
(2, 1, 410, 410, 'Camera da letto', NULL, 1),
(2, 1, 400, 360, 'Camera da letto', 4, NULL),
(2, 2, 350, 400, 'Cucina', NULL, 4),
(2, 2, 380, 350, 'Sala da pranzo', 3, NULL),
(2, 2, 360, 380, 'Soggiorno', 1, NULL),
(2, 2, 360, 340, 'Camera da letto', NULL, 1),
(2, 2, 300, 270, 'Soggiorno', 2, NULL),
(2, 3, 370, 320, 'Cucina', NULL, 1),
(2, 3, 330, 400, 'Sala da pranzo', 4, NULL),
(2, 3, 390, 390, 'Camera da letto', 3, NULL),
(2, 3, 405, 410, 'Camera da letto', NULL, 2),
(2, 3, 315, 310, 'Soggiorno', 2, NULL);

-- Inserimento pareti
INSERT INTO `Parete` (`orientamento`, `angolo`, `id_parete_vano`, `mattone`, `vano`, `pietra`, `lunghezza`) VALUES 
('N', '90', 1, 2, 1, NULL, 300),
('E', '90', 2, 2, 1, NULL, 220),
('S', '90', 3, 2, 1, NULL, 300),
('W', '90', 4, 2, 1, NULL, 220),
(NULL, NULL, 5, 5, 1, 1, NULL),

('N', '90', 1, 3, 2, NULL, 280),
('E', '90', 2, 3, 2, NULL, 260),
('S', '90', 3, 3, 2, NULL, 280),
('W', '90', 4, 3, 2, NULL, 260),
(NULL, NULL, 5, 5, 2, NULL, NULL),

('N', '90', 1, 2, 3, NULL, 310),
('E', '90', 2, 2, 3, NULL, 320),
('S', '90', 3, 2, 3, NULL, 310),
('W', '90', 4, 2, 3, NULL, 320),
(NULL, NULL, 5, 2, 3, 1, NULL),

('N', '90', 1, 2, 4, NULL, 400),
('E', '90', 2, 2, 4, 2, 270),
('S', '90', 3, 2, 4, NULL, 400),
('W', '90', 4, 2, 4, NULL, 270),
(NULL, NULL, 5, 2, 4, 3, NULL),

('N', '90', 1, 2, 5, NULL, 220),
('E', '90', 2, 2, 5, 1, 230),
('S', '90', 3, 2, 5, NULL, 220),
('W', '90', 4, 2, 5, NULL, 230),
(NULL, NULL, 5, 2, 5, NULL, NULL),

('N', '90', 1, 2, 6, NULL, 2800),
('E', '90', 2, 2, 6, NULL, 220),
('S', '90', 3, 2, 6, NULL, 280),
('W', '90', 4, 2, 6, 3, 220),
(NULL, NULL, 5, 2, 6, 1, NULL),

('N', '90', 1, 2, 7, NULL, 340),
('E', '90', 2, 2, 7, 2, 200),
('S', '90', 3, 2, 7, NULL, 340),
('W', '90', 4, 2, 7, NULL, 200),
(NULL, NULL, 5, 2, 7, NULL, NULL),

('N', '90', 1, 2, 8, NULL, 180),
('E', '90', 2, 2, 8, NULL, 220),
('S', '90', 3, 2, 8, NULL, 180),
('W', '90', 4, 2, 8, NULL, 220),
(NULL, NULL, 5, 2, 8, NULL, NULL),

('N', '90', 1, 2, 9, NULL, 280),
('E', '90', 2, 2, 9, NULL, 280),
('S', '90', 3, 2, 9, 3, 280),
('W', '90', 4, 2, 9, NULL, 280),
(NULL, NULL, 5, 2, 9, NULL, NULL),

('N', '90', 1, 2, 10, 1, 330),
('E', '90', 2, 2, 10, NULL, 250),
('S', '90', 3, 2, 10, NULL, 330),
('W', '90', 4, 2, 10, NULL, 250),
(NULL, NULL, 5, 2, 10, NULL, NULL),

('N', '90', 1, 2, 11, NULL, 310),
('E', '90', 2, 2, 11, NULL, 310),
('S', '90', 3, 2, 11, 2, 310),
('W', '90', 4, 2, 11, NULL, 310),
(NULL, NULL, 5, 2, 11, NULL, NULL),

('N', '90', 1, 2, 12, NULL, 290),
('E', '90', 2, 2, 12, NULL, 310),
('S', '90', 3, 2, 12, NULL, 290),
('W', '90', 4, 2, 12, NULL, 310),
(NULL, NULL, 5, 2, 12, NULL, NULL),

('N', '90', 1, 2, 13, NULL, 300),
('E', '90', 2, 2, 13, NULL, 300),
('S', '90', 3, 2, 13, NULL, 300),
('W', '90', 4, 2, 13, NULL, 300),
(NULL, NULL, 5, 2, 13, NULL, NULL),

('N', '90', 1, 2, 14, NULL, 190),
('E', '90', 2, 2, 14, NULL, 200),
('S', '90', 3, 2, 14, NULL, 190),
('W', '90', 4, 2, 14, NULL, 200),
(NULL, NULL, 5, 2, 14, NULL, NULL),

('N', '90', 1, 2, 15, NULL, 180),
('E', '90', 2, 2, 15, NULL, 200),
('S', '90', 3, 2, 15, NULL, 180),
('W', '90', 4, 2, 15, NULL, 200),
(NULL, NULL, 5, 2, 15, NULL, NULL);

-- Inserimenti balcone-vano
INSERT INTO `BalconeVano` (`balcone`, `vano`) VALUES 
(1, 2),
(2, 5),
(3, 8),
(3, 9),
(12, 11),
(16, 15);

-- Inserimenti aree colpita
INSERT INTO `AreaColpita` (`area`, `calamita`, `timestamp`, `gravita`) VALUES 
(1, 1, CURRENT_TIMESTAMP(), 6),
(3, 1, CURRENT_TIMESTAMP(), 2),
(4, 2, CURRENT_TIMESTAMP(), 8),
(1, 6, CURRENT_TIMESTAMP, 1),
(2, 4, CURRENT_TIMESTAMP(), 7),
(5, 3, CURRENT_TIMESTAMP(), 6),
(2, 5, CURRENT_TIMESTAMP(), 2),
(5, 3, CURRENT_TIMESTAMP(), 10),
(4, 5, CURRENT_TIMESTAMP, 5),
(3, 6, CURRENT_TIMESTAMP(), 4);

-- Inserimenti punti di accesso
INSERT INTO `PuntoDiAccesso` (`lunghezza`, `larghezza`, `altezza`, `distanza_da_sx`, `tipo`, `apertura`, `altezza_chiave`, `parete`) VALUES
(65, 8, 200, 15, 'Porta', 1, NULL, 22),
(70, 10, 210, 50, 'Porta', 1, NULL, 13),
(68, 9, 200, 30, 'Porta', 2, NULL, 44),
(75, 12, 220, 28, 'Porta', 1, NULL, 19),
(62, 8, 210, 40, 'Porta', 2, NULL, 60),
(65, 8, 200, 5, 'Porta', 1, NULL, 20),
(82, 11, 230, 20, 'Porta', 0, NULL, 45),
(70, 8, 210, 40, 'Porta', 0, NULL, 36),
(65, 9, 200, 15, 'Porta', 1, NULL, 7),
(80, 10, 220, 70, 'Porta', 2, NULL, 14),
(80, 14, 200, 5, 'Apertura senza serramenti', NULL, NULL, 18),
(90, 15, 230, 20, 'Apertura senza serramenti', NULL, NULL, 27),
(75, 11, 210, 40, 'Apertura senza serramenti', NULL, NULL, 42),
(92, 12, 200, 15, 'Apertura senza serramenti', NULL, NULL, 39),
(78, 10, 220, 70, 'Apertura senza serramenti', NULL, NULL, 31),
(110, 14, 250, 10, 'Arco', NULL, NULL, 2),
(130, 13, 260, 15, 'Arco', NULL, NULL, 17),
(115, 13, 260, 10, 'Arco', NULL, NULL, 25);

-- Inserimento finestre 
INSERT INTO `Finestra` (`lunghezza`, `larghezza`, `altezza`, `distanza_da_sx`, `altezza_da_pavimento`, `orientamento`, `parete`) VALUES 
(40, 8, 45, 30, 175, 'N', 1),
(60, 10, 40, 40, 185, 'W', 7), 
(50, 9, 45, 120, 175, 'SW', 45), 
(45, 10, 30, 80, 160, 'NE', 23), 
(45, 9, 30, 70, 165, 'S', 20),
(80, 7, 80, 30, 175, 'S', 57),
(60, 10, 30, 40, 185, 'SE', 39), 
(70, 9, 40, 120, 175, 'W', 25), 
(50, 8, 60, 80, 160, 'NW', 16), 
(45, 9, 30, 70, 165, 'N', 48); 

-- Inserimento progetti edilizi
INSERT INTO `ProgettoEdilizio` (`codice`, `tipologia`, `data_presentazione`, `data_approvazione`, `data_inizio`, `data_stima_fine`, `data_fine_effettiva`, `edificio`) VALUES 
(02112022, 'Ristrutturazione', CURRENT_DATE() - INTERVAL 7 DAY, CURRENT_DATE(), CURRENT_DATE() + INTERVAL 12 DAY, CURRENT_DATE() + INTERVAL 30 DAY, CURRENT_DATE() + INTERVAL 30 DAY, 2), 
(01112022, 'Ristrutturazione', CURRENT_DATE() - INTERVAL 14 DAY, CURRENT_DATE() - INTERVAL 7 DAY, CURRENT_DATE(),  CURRENT_DATE() + INTERVAL 14 DAY, CURRENT_DATE() + INTERVAL 18 DAY, 1),
(29102022, 'Ristrutturazione', CURRENT_DATE() - INTERVAL 21 DAY, CURRENT_DATE() - INTERVAL 12 DAY, CURRENT_DATE() - INTERVAL 5 DAY, CURRENT_DATE() + INTERVAL 4 DAY, CURRENT_DATE() + INTERVAL 7 DAY, 2);