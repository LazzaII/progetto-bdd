# File per popolare il database

INSERT INTO `AreaGeografica` (`nome`) VALUES
('Garfagna-Lunigiana'),
('Chianti'),
('Salento'),
('Alto Adige'),
('Porto Cervo');

INSERT INTO `Turno`(`ora_inizio`, `ora_fine`, `giorno`, `mansione`) VALUES 
('09:00:00', '13:00:00', '2022-08-01', 'Imbiancamento parete')
('14:00:00', '18:00:00', '2022-08-01', 'Installazione porte e finestre')
('08:00:00', '14:00:00', '2022-08-02', 'Demolizione muro')
('15:00:00', '18:00:00', '2022-08-02', 'Posatura piastrelle')
('09:00:00', '13:00:00', '2022-08-03', 'Posatura parquet')
('14:00:00', '19:00:00', '2022-08-03', 'Posa delle fondamenta')
('08:00:00', '12:00:00', '2022-08-04', 'Costruzione balcone')
('13:00:00', '17:30:00', '2022-08-04', 'Costruzione balcone')
('09:30:00', '13:30:00', '2022-08-05', 'Rifacimento tetto')
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
(125, 300, 12, 80s);

INSERT INTO `Alveolatura` (`nome`, `descrizione`) VALUES
('Alveotherm MO 390", "17 file di camere'),
('Alveotherm A250 07", "7 file di camere'),
('Biopor 35", "Certificato doppia posa: Orizzontale e Verticale - Classe P600'),
('Forato F200", "4 file di camere'),
('Excelsior SE160", "Blocco da Solaio');