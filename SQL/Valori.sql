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
-- nome, cod_lotto, fornitore, larghezza, lunghezza, altezza, costituzione, costo, unita, data_acquisto, quantita, colore
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
WHERE M.`nome` = 'Parquet'; 
INSERT INTO `Parquet` VALUES (@id, 'spina di pesce');

CALL valorizzazioneMateriale ('Legno di quercia', 15002, 'WoodMasters', 6.5, 40, 1, 'resistente', 42, 'mq', CURRENT_DATE(), 90, 'marrone');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Parquet'; 
INSERT INTO `Parquet` VALUES (@id, 'parallela');

CALL valorizzazioneMateriale ('Legno di noce', 15003, 'WoodMasters', 6.5, 45, 1, 'resistente', 38, 'mq', CURRENT_DATE(), 110, 'marrone');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Parquet'; 
INSERT INTO `Parquet` VALUES (@id, 'parallela sfalsata');

CALL valorizzazioneMateriale ('Legno di rovere', 15004, 'WoodMasters', 7, 39, 1, 'resistente', 36, 'mq', CURRENT_DATE(), 64, 'marrone');
SELECT M.`ID` INTO @id
FROM Materiale M
WHERE M.`nome` = 'Parquet'; 
INSERT INTO `Parquet` VALUES (@id, 'ungherese chiusa');