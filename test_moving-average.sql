USE SmartBuildings;

# Per disabilitare "ONLY_FULL_GROUP_BY"
# SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
# SELECT @@sql_mode;

CREATE TABLE MovingAverages (
	sensore INT, 
	ma1 DOUBLE,
    ma7 DOUBLE,
    ma30 DOUBLE
);

DELIMITER $$
CREATE PROCEDURE ciao()
BEGIN 
	
    DECLARE finito, sensore INT default 0;
    DECLARE _1ma, _7ma, _30ma DOUBLE DEFAULT 0;
    
    DECLARE cur CURSOR FOR 
    SELECT M.`id_sensore`, 
			  ROUND((SELECT IF(M2.valoreY IS NOT NULL, SUM(SQRT(POWER(M2.valoreX, 2) + POWER(M2.valoreY, 2) + POWER(M2.valoreZ, 2))), SUM(M2.valoreX)) 
				/ COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 1 AND 2
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '1dayMA', 
              ROUND((SELECT IF(M2.valoreY IS NOT NULL, SUM(SQRT(POWER(M2.valoreX, 2) + POWER(M2.valoreY, 2) + POWER(M2.valoreZ, 2))), SUM(M2.valoreX)) 
               / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 7 AND 14
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '7daysMA',
              ROUND((SELECT IF(M2.valoreY IS NOT NULL, SUM(SQRT(POWER(M2.valoreX, 2) + POWER(M2.valoreY, 2) + POWER(M2.valoreZ, 2))), SUM(M2.valoreX)) 
               / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 30 AND 60
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '30daysMA'
	FROM Misurazione M
	JOIN Sensore S ON M.id_sensore = S.ID
	WHERE M.id_sensore = 1 AND M.valoreX > soglia
	ORDER BY M.`id_sensore`, M.`timestamp`;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    OPEN cur;
    WHILE finito = 0 DO 
		FETCH cur into sensore, _1ma, _7ma, _30ma;
        SELECT sensore, _1ma, _7ma, _30ma;
    END WHILE;

END $$
DELIMITER ;
