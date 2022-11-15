# File per popolare il database

USE SmartBuildings;

-- Popolamento areagreografica
INSERT INTO `AreaGeografica` (`nome`) VALUES
('Garfagna-Lunigiana'),
('Chianti'),
('Salento'),
('Alto Adige'),
('Porto Cervo');

-- Popolamento turno
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

-- Popolamento calamità
INSERT INTO `Calamita`(`tipo`) VALUES 
('Incendio'),
('Terremoto'),
('Inondazione'),
('Uragano'),
('Eruzione vulcanica'),
('Frana');

-- Popolamento alveolatura
INSERT INTO `Alveolatura` (`nome`, `descrizione`, `materiale_riempimento`) VALUES
('Alveotherm MO 390', '17 file di camere', NULL),
('Alveotherm A250 07', '7 file di camere', NULL),
('Excelsior SE160', 'Blocco da Solaio', NULL),
('Biopor 35', 'Certificato doppia posa', 'stucco'), -- isolante
('Forata F200', '4 file di camere', 'stucco'); -- isolante

-- Popolamento materiali generici
CALL valorizzazioneMateriale ('Sbarra di acciaio - sa1', 17892, 'SteelMaster', 120, 10, 6, 'robusta, resistente', 0.70, 'kg', CURRENT_DATE(), 82, 'grigio');
CALL valorizzazioneMateriale ('Sbarra di acciaio - sa2', 17897, 'SteelMaster', 180, 12, 8, 'robusta, resistente', 0.90, 'kg', CURRENT_DATE(), 76, 'grigio');
CALL valorizzazioneMateriale ('Marmo B', 18462, 'CarraiaMarble', 20, 20, 3, 'lucida, resistente', 50.25, 'mq', CURRENT_DATE(), 90, 'bianco');
CALL valorizzazioneMateriale ('Marmo Botticino', 18471, 'CarraiaMarble', 30, 25, 3, 'lucida, resistente', 60.35, 'mq', CURRENT_DATE(), 78, 'bianco');
CALL valorizzazioneMateriale ('Marmo N', 18489, 'CarraiaMarble', 35, 35, 3, 'lucida, resistente', 75.80, 'mq', CURRENT_DATE(), 110, 'nero');
CALL valorizzazioneMateriale ('Granito levigato G', 12709, 'GranitePro', 120, 10, 6, 'resistente', 47.90, 'mq', CURRENT_DATE(), 120, 'grigio');
CALL valorizzazioneMateriale ('Granito levigato N', 12719, 'GranitePro', 120, 10, 6, 'opaco, resistente', 51.20, 'mq', CURRENT_DATE(), 132, 'nero');
CALL valorizzazioneMateriale ('Granito liscio', 12729, 'GranitePro', 120, 10, 6, 'lucido, resistente', 80.10, 'mq', CURRENT_DATE(), 107, 'rosa');
CALL valorizzazioneMateriale ('Cemento a presa rapida', 11091, 'CemexMaker', 0, 0, 0, 'polvere', 0.20, 'kg', CURRENT_DATE(), 190, 'grigio');
CALL valorizzazioneMateriale ('Cemento bianco', 11092, 'CemexMaker', 0, 0, 0, 'polvere', 0.35, 'kg', CURRENT_DATE(), 110, 'bianco');

-- Popolamento mattoni
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

-- Popolamento pietre
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

-- Popolamento intonaco
CALL valorizzazioneMateriale ('Intonaco C', 14117, 'PlasterPros', 0, 0, 0, 'liscio', 14, 'mq', CURRENT_DATE(), 285, 'bianco');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Intonaco C'; 
INSERT INTO `Intonaco` VALUES (@id, 0.6, 'civile');

CALL valorizzazioneMateriale ('Intonaco D-1', 14118, 'PlasterPros', 0, 0, 0, 'liscio', 18, 'mq', CURRENT_DATE(), 170, 'rosso');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Intonaco D-1'; 
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

-- Popolamento parquet
CALL valorizzazioneMateriale ('Legno massello', 15001, 'WoodMasters', 7, 42, 1, 'resistente', 30, 'mq', CURRENT_DATE(), 90, 'marrone');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Legno massello'; 
INSERT INTO `Parquet` VALUES (@id, 'lisca di pesce');

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

-- Popolamento piastrelle
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

-- Popolamento lavoratori
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

-- Popolamento rischi 
INSERT INTO `Rischio` (`area_geografica`, `tipo`, `coefficiente_rischio`) VALUES 
(1, 'Terremoto', 8),
(1, 'Frana', 10),
(5, 'Tromba d aria', 9),
(5, 'Incendio', 2),
(2, 'Frana', 8),
(3, 'Incendio', 9),
(4, 'Terremoto', 6); 

-- Popolamento edifici
INSERT INTO `Edificio` (`tipologia`, `stato`, `area_geografica`) VALUES 
('Palazzo', 100, 4),
('Villetta a schiera', 75, 4);

-- Popolamento piani 
INSERT INTO `Piano` (`numero`, `altezza`, `inclinazione`, `altezza_min`, `edificio`) VALUES 
(1, 360, NULL, NULL, 1),
(2, 360, NULL, NULL, 1),
(3, 380, 60, 320, 1),
(1, 380, NULL, NULL, 2),
(2, 380, NULL, NULL, 2),
(3, 410, 70, 360, 2);

-- Popolamento vani
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

-- Popolamento pareti
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

-- Popolamento balcone
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

-- Popolamento balcone vano
INSERT INTO `BalconeVano` (`balcone`, `vano`) VALUES 
(1, 2),
(2, 5),
(3, 8),
(3, 9),
(12, 11),
(16, 15);

CALL inserimentoAltezzaBalconi();

-- Popolamento punti di accesso
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

-- Popolamento finestre 
INSERT INTO `Finestra` (`lunghezza`, `larghezza`, `altezza`, `distanza_da_sx`, `altezza_da_pavimento`, `parete`) VALUES 
(40, 8, 45, 30, 175, 1),
(60, 10, 40, 40, 185, 7), 
(50, 9, 45, 120, 175, 45), 
(45, 10, 30, 80, 160, 23), 
(45, 9, 30, 70, 165, 20),
(80, 7, 80, 30, 175, 57),
(60, 10, 30, 40, 185, 39), 
(70, 9, 40, 120, 175, 25), 
(50, 8, 60, 80, 160, 16), 
(45, 9, 30, 70, 165, 48); 

-- Popolamento progetti edilizi
INSERT INTO `ProgettoEdilizio` (`codice`, `tipologia`, `data_presentazione`, `data_approvazione`, `data_inizio`, `data_stima_fine`, `data_fine_effettiva`, `edificio`) VALUES 
(02112022, 'Ristrutturazione', CURRENT_DATE() - INTERVAL 7 DAY, CURRENT_DATE(), CURRENT_DATE() + INTERVAL 12 DAY, CURRENT_DATE() + INTERVAL 30 DAY, CURRENT_DATE() + INTERVAL 30 DAY, 2), -- ristrutturazione bagno
(01112022, 'Ristrutturazione', CURRENT_DATE() - INTERVAL 14 DAY, CURRENT_DATE() - INTERVAL 7 DAY, CURRENT_DATE(),  CURRENT_DATE() + INTERVAL 14 DAY, CURRENT_DATE() + INTERVAL 18 DAY, 1), -- ristrutturazione bagno
(29102022, 'Ristrutturazione', CURRENT_DATE() - INTERVAL 21 DAY, CURRENT_DATE() - INTERVAL 12 DAY, CURRENT_DATE() - INTERVAL 5 DAY, CURRENT_DATE() + INTERVAL 4 DAY, CURRENT_DATE() + INTERVAL 7 DAY, 2); -- cappotto, ripavimentazione

-- Popolamento stadi di avanzamento
INSERT INTO `StadioDiAvanzamento` (`data_inizio`, `data_stima_fine`, `data_fine_effettiva`, `descrizione`, `progetto_edilizio`) VALUES 
(CURRENT_DATE() + INTERVAL 30 DAY, CURRENT_DATE() + INTERVAL 32 DAY, CURRENT_DATE() + INTERVAL 32 DAY, 'Preparazione', 1),
(CURRENT_DATE() + INTERVAL 33 DAY, CURRENT_DATE() + INTERVAL 35 DAY, CURRENT_DATE() + INTERVAL 35 DAY, 'Inizio', 1),
(CURRENT_DATE() + INTERVAL 36 DAY, CURRENT_DATE() + INTERVAL 38 DAY, CURRENT_DATE() + INTERVAL 38 DAY, 'Medio termine ', 1),
(CURRENT_DATE() - INTERVAL 5 DAY, CURRENT_DATE() - INTERVAL 4 DAY, CURRENT_DATE() - INTERVAL 3 DAY, 'Preparazione', 3),
(CURRENT_DATE() - INTERVAL 2 DAY, CURRENT_DATE(), CURRENT_DATE(), 'Inizio', 3),
(CURRENT_DATE() + INTERVAL 1 DAY, CURRENT_DATE() + INTERVAL 3 DAY, CURRENT_DATE() + INTERVAL 3 DAY, 'Medio termine', 3),
(CURRENT_DATE() + INTERVAL 4 DAY, CURRENT_DATE() + INTERVAL 8 DAY, CURRENT_DATE + INTERVAL 7 DAY, 'Conclusione', 3),
(CURRENT_DATE() + INTERVAL 8 DAY, CURRENT_DATE() + INTERVAL 12 DAY, CURRENT_DATE + INTERVAL 13 DAY, 'Controllo', 3),
(CURRENT_DATE(), CURRENT_DATE() + INTERVAL 3 DAY, CURRENT_DATE() + INTERVAL 5 DAY, 'Preparazione', 2),
(CURRENT_DATE() + INTERVAL 5 DAY, CURRENT_DATE() + INTERVAL 7 DAY, CURRENT_DATE() + INTERVAL 7 DAY, 'Inizio', 2);

-- Popolamento lavori progetto edilizio
INSERT INTO `LavoroProgettoEdilizio` (`tipologia`, `isCompleto`, `stadio`) VALUES 
('Sopralluogo e raccoglimento materiale', 0, 1),
('Sopralluogo e raccoglimento materiale', 1, 2),
('Sopralluogo e raccoglimento materiale', 0, 3), 
('Ristrutturazione dopo terremoto', 0, 1), 
('Ristrutturazione dopo terremoto', 1, 1),
('Ristrutturazione dopo terremoto', 0, 1),
('Posizionamento piastrelle e sanitari', 0, 1),
('Posizionamento tasselli e collante', 1, 3), 
('Posizionamento pannelli isolanti', 0, 3), 
('Rimozione pavimento', 0, 3),
('Rifacimento solaio', 1, 3), 
('Applicazione adesivo rasante', 0, 3), 
('Rivestimento facciata', 0, 3), 
('Controllo della qualità del solaio', 1, 3), 
('Controllo efficienza cappotto', 0, 3), 
('Sopralluogo e raccoglimento materiale', 0, 2), 
('Sopralluogo e raccoglimento materiale', 1, 2); 

-- Popolamento partecipazione lavoratore a lavoro progetto edilizio
INSERT INTO `PartecipazioneLavoratoreLavoro` (`lavoratore`, `lavoro`) VALUES 
('MRORSI97M09D612B', 1),
('MRORSI97M09D612B', 2),
('MRORSI97M09D612B', 3),
('VRILII99D612I', 2),
('VRILII99D612I', 3),
('VRILII99D612I', 5),
('FACGAL85P600D', 1),
('FACGAL85P600D', 4),
('FACGAL85P600D', 12),
('MRANRI92L611P', 14),
('MRANRI92L611P', 5),
('UGOAAN94K032L', 16),
('UGOAAN94K032L', 15),
('UBRBLU456D612D', 17),
('UBRBLU456D612D', 11),
('RMOMRO643S102H', 13),
('RMOMRO643S102H', 14);

-- Popolamento per supervisione lavoro
INSERT INTO `SupervisioneLavoro` (`lavoratore`, `lavoro`) VALUES
('FACGAL85P600D', 1),
('FACGAL85P600D', 5),
('FACGAL85P600D', 8),
('VOATRH89S612P', 7),
('VOATRH89S612P', 9),
('VOATRH89S612P', 12),
('MRANRI92L611P', 2),
('MRANRI92L611P', 3),
('MRANRI92L611P', 4),
('UBRBLU456D612D', 6),
('UBRBLU456D612D', 10),
('UBRBLU456D612D', 11),
('UBRBLU456D612D', 13);

-- Popolamento lavoratore svolgimento turno
INSERT INTO `SvolgimentoTurno` (`lavoratore`, `ora_inizio`, `ora_fine`, `giorno`) VALUES 
(1, '09:00:00', '13:00:00', '2022-08-01'),
(1, '14:00:00', '18:00:00', '2022-08-01'),
(2, '08:00:00', '14:00:00', '2022-08-02'),
(2, '15:00:00', '18:00:00', '2022-08-02'),
(6, '14:00:00', '19:00:00', '2022-08-03'),
(6, '09:30:00', '13:30:00', '2022-08-05'),
(7, '14:00:00', '19:00:00', '2022-08-03'),
(7, '09:30:00', '13:30:00', '2022-08-05'),
(8, '14:00:00', '19:00:00', '2022-08-03'),
(8, '09:30:00', '13:30:00', '2022-08-05'),
(10, '09:00:00', '13:00:00', '2022-08-03'),
(10, '09:30:00', '13:30:00', '2022-08-05'),
(5, '13:00:00', '17:30:00', '2022-08-04'),
(5, '14:00:00', '18:00:00', '2022-08-05'); 

-- Popolamento lavoratore dirige turno
INSERT INTO `LavoratoreDirigeTurno` (`capo_turno`, `ora_inizio`, `ora_fine`, `giorno`, `num_lavoratori_monitorabili`) VALUES
('VOATRH89S612P', '09:00:00', '13:00:00', '2022-08-01', 5),
('VOATRH89S612P', '14:00:00', '18:00:00', '2022-08-01', 5),
('UBRBLU456D612D', '08:00:00', '14:00:00', '2022-08-02', 7),
('MRANRI92L611P', '15:00:00', '18:00:00', '2022-08-02', 5),
('MRANRI92L611P', '14:00:00', '19:00:00', '2022-08-03', 5),
('FACGAL85P600D', '09:30:00', '13:30:00', '2022-08-05', 6);

-- Popolamento strato intonaco
-- intonaco 22-26
INSERT INTO `StratoIntonaco` (`strato`, `parete`, `intonaco`) VALUES 
(1, 1, 22),
(2, 1, 22),
(3, 1, 22),
(1, 2, 25),
(2, 2, 25),
(3, 2, 25),
(1, 13, 22),
(2, 13, 22),
(3, 13, 22),
(1, 47, 22),
(2, 47, 24),
(3, 47, 24),
(1, 71, 22),
(2, 71, 24),
(3, 71, 26),
(1, 26, 23),
(2, 26, 23),
(3, 26, 25);

-- Popolamento sensori 
INSERT INTO `Sensore` (`distanza_da_sx`, `altezza_da_pavimento`, `isEsterno`, `tipo`, `soglia`, `unita_di_misura`, `parete`, `vano`) VALUES 
(40, 180, 0, 'fessurimetro', 50, 'mm', 1, NULL), 
(30, 0, 0, 'accelerometro', 10, 'mm/s^2', NULL, 1), 
(20, 15, 0, 'giroscopio', 10, 'Nmm', NULL, 1), 
(60, 175, 0, 'termometro', 55, '°C', 2, NULL), 
(70, 180, 0, 'termometro', -10, '°C', 7, NULL), 
(40, 200, 0, 'igrometro', 150, '%', 4, NULL), 
(30, 210, 1, 'pluviometro', 300, 'mm', NULL, NULL), 
(70, 200, 1, 'pluviometro', 280, 'mm', NULL, NULL), 
(35, 190, 0, 'igrometro', 120, '%', 6, NULL), 
(45, 220, 1, 'pluviometro', 310, 'mm', NULL, NULL), 
(60, 5, 1, 'igrometro', 120, '%', 7, NULL), 
(40, 10, 1, 'igrometro', 110, '%', 10, NULL), 
(30, 185, 0, 'fessurimetro', 50, 'mm', 8, NULL), 
(30, 140, 0, 'giroscopio', 15, 'Nmm', NULL, 3), 
(40, 100, 0, 'giroscopio', 10, 'Nmm', NULL, 4), 
(20, 10, 0, 'accelerometro', 15, 'mm/s^2', NULL, 4), 
(20, 175, 0, 'fessurimetro', 45, 'mm', 3, NULL), 
(35, 120, 1, 'termometro', -15, '°C', 21, NULL), 
(45, 175, 0, 'fessurimetro', 40, 'mm', 4, NULL), 
(50, 160, 1, 'termometro', 60, '°C', 14, NULL);

/*
	Genera una misura relativamente ad un sensore.
*/
DROP PROCEDURE IF EXISTS generaMisura; 
DELIMITER $$
CREATE PROCEDURE generaMisura (_sensore INT)
BEGIN
	DECLARE ts TIMESTAMP DEFAULT NULL;
    DECLARE tipo TEXT DEFAULT '';
    DECLARE soglia DOUBLE DEFAULT 0;
    DECLARE val1 DOUBLE DEFAULT 0;
    DECLARE val2 DOUBLE DEFAULT NULL;
    DECLARE val3 DOUBLE DEFAULT NULL;
    DECLARE percentualeLivello DOUBLE DEFAULT 0;
    DECLARE livello VARCHAR(2) DEFAULT 'L0';

	-- controllo se il sensore è presente
	IF NOT EXISTS (SELECT 1 FROM `Sensore` S WHERE S.`ID` = _sensore)
	THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = '[ERROR] Sensore non presente';
	END IF;
    
    SELECT S.`tipo`, S.`soglia` INTO tipo, soglia
    FROM `Sensore` S
    WHERE S.`ID` = _sensore;
    
    IF(tipo = 'accelerometro' OR tipo = 'giroscopio') 
    THEN 
		-- genera un numero random tra soglia(max) e 0(min)
		SELECT ROUND(RAND()*(soglia*1.1/3+1), 2) INTO val1;
        SELECT ROUND(RAND()*(soglia*1.1/3+1), 2) INTO val2;
        SELECT ROUND(RAND()*(soglia*1.1/3+1), 2) INTO val3;

        SET percentualeLivello = ROUND(SQRT(val1*val1+val2*val2+val3*val3)/soglia, 2)*100;
	ELSE 
		SELECT ROUND(RAND()*(soglia*1.1+1), 2) INTO val1;

        SET percentualeLivello = ROUND(val1/soglia, 2)*100;
	END IF;
    
    -- creo un timestamp "randomico"
    -- converte la data iniziale in un timestamp unix e aggiunge un valore random tra 0 secondi e +2 mesi poi lo converte nuovamente in timestamp
    SET ts = FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))); 

    -- identifico il livello
    IF (percentualeLivello >= 100) THEN
        SET livello = 'L4';
    ELSEIF (percentualeLivello < 100 AND percentualeLivello >= 75) THEN
        SET livello = 'L3';
    ELSEIF (percentualeLivello < 75 AND percentualeLivello >= 50) THEN
        SET livello = 'L2';
    ELSEIF (percentualeLivello < 50 AND percentualeLivello >= 25) THEN
        SET livello = 'L1';
    ELSE 
        SET livello = 'L0';
    END IF;
    
    INSERT INTO `Misurazione` (`id_sensore`, `timestamp`, `livello`, `valoreX`, `valoreY`, `valoreZ`) VALUES (_sensore, ts, livello, val1, val2, val3);
END $$ 
DELIMITER ;

-- Popolamento misurazioni
DROP PROCEDURE IF EXISTS inserisciMisurazioni;
DELIMITER $$
CREATE PROCEDURE inserisciMisurazioni()
BEGIN 
    DECLARE finito INT DEFAULT 0;
    DECLARE sensore INT DEFAULT 0;
    DECLARE contatore INT DEFAULT 0;

    DECLARE cur_sensori CURSOR FOR 
    SELECT S.`ID`
    FROM Sensore S;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    OPEN cur_sensori;
    WHILE finito = 0 DO
        FETCH cur_sensori INTO sensore;
        WHILE contatore < 200 DO
            CALL generaMisura(sensore);
            SET contatore = contatore + 1;
        END WHILE;
        SET contatore = 0;
    END WHILE; 
    CLOSE cur_sensori;
END $$ 
DELIMITER ;
CALL inserisciMisurazioni();

-- Popolamento area colpita
INSERT INTO `AreaColpita` (`area`, `calamita`, `timestamp`, `distanza_epicentro`) VALUES 
(1, 1, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 40),
(3, 1, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 20),
(4, 2, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 12),
(1, 6, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 30),
(2, 4, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 35),
(5, 3, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 5),
(2, 5, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 25),
(5, 4, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 10),
(4, 5, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 20),
(3, 6, FROM_UNIXTIME(UNIX_TIMESTAMP('2014-12-25 00:00:00') + FLOOR(0 + (RAND() * 63072000/12))), 15);

CALL inserisciGravita();