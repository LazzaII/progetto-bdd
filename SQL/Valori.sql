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
('Biopor 35', 'Certificato doppia posa', 'stucco'),
('Forato F200', '4 file di camere', 'stucco');

# nome, cod_lotto, fornitore, larghezza, lunghezza, altezza, costituzione, costo, unita, data_acquisto, quantita, colore
CALL aggiornamentoMateriale ('Sbarra di acciaio - sa1', 17892, 'SteelMaster', 120, 10, 6, 'robusta, resistente', 0.70, 'k', CURRENT_DATE(), 82, 'grigio');
CALL aggiornamentoMateriale ('Sbarra di acciaio - sa2', 17897, 'SteelMaster', 180, 12, 8, 'robusta, resistente', 0.90, 'k', CURRENT_DATE(), 76, 'grigio');
CALL aggiornamentoMateriale ('Marmo B', 18462, 'CarraiaMarble', 20, 20, 3, 'lucida, resistente', 50.25, 'mq', CURRENT_DATE(), 90, 'bianco');
CALL aggiornamentoMateriale ('Marmo Botticino', 18471, 'CarraiaMarble', 30, 25, 3, 'lucida, resistente', 60.35, 'mq', CURRENT_DATE(), 78, 'bianco');
CALL aggiornamentoMateriale ('Marmo N', 18489, 'CarraiaMarble', 35, 35, 3, 'lucida, resistente', 75.80, 'mq', CURRENT_DATE(), 110, 'nero');
CALL aggiornamentoMateriale ('Granito levigato G', 12709, 'GranitePro', 120, 10, 6, 'resistente', 47.90, 'mq', CURRENT_DATE(), 120, 'grigio');
CALL aggiornamentoMateriale ('Granito levigato N', 12719, 'GranitePro', 120, 10, 6, 'opaco, resistente', 51.20, 'mq', CURRENT_DATE(), 132, 'nero');
CALL aggiornamentoMateriale ('Granito liscio', 12729, 'GranitePro', 120, 10, 6, 'lucido, resistente', 80.10, 'mq', CURRENT_DATE(), 107, 'rosa');
CALL aggiornamentoMateriale ('Cemento a presa rapida', 11091, 'CemexMaker', 0, 0, 0, 'polvere', 0.20, 'kg', CURRENT_DATE(), 190, 'grigio');
CALL aggiornamentoMateriale ('Cemento bianco', 11092, 'CemexMaker', 0, 0, 0, 'polvere', 0.35, 'kg', CURRENT_DATE(), 110, 'grigio');

CALL aggiornamentoMateriale ('Mattone - L', 12781, 'SuperBricks', 20, 8, 12, 'versatile, resistente', 30, 'mq', CURRENT_DATE(), 120, 'rosso');

# capire perché non funziona con @id e senza sì
/*
SELECT @id = M.`ID`
FROM Materiale M
WHERE M.`nome` = 'Mattone - L';

SELECT * FROM Materiale;
INSERT INTO `Mattone` VALUES (@id, 'Laterizio', NULL);
*/
INSERT INTO `Mattone` VALUES (5, 'Laterizio', NULL);

CALL aggiornamentoMateriale ('Mattone - C', 12782, 'SuperBricks', 20, 8, 12, 'versatile, resistente', 32, 'mq', CURRENT_DATE(), 128, 'grigio');
INSERT INTO `Mattone` VALUES (6, 'Calcestruzzo', 3);

CALL aggiornamentoMateriale ('Mattone - FL', 12783, 'SuperBricks', 20, 8, 12, 'versatile, resistente, forato', 36, 'mq', CURRENT_DATE(), 100, 'rosso');
INSERT INTO `Mattone` VALUES (7, 'Laterizio', 5);