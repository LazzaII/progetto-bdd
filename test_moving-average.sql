USE SmartBuildings;

SELECT * FROM Misurazione; 

SELECT M.id_sensore, M.`timestamp`, M.valoreX, M.valoreY, M.valoreZ, 
			  ROUND((SELECT IF(M2.valoreY IS NOT NULL, SUM(SQRT(POWER(M2.valoreX, 2) + POWER(M2.valoreY, 2) + POWER(M2.valoreZ, 2))), SUM(M2.valoreX)) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 0 AND 1
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '1dayMA', 
              ROUND((SELECT IF(M2.valoreY IS NOT NULL, SUM(SQRT(POWER(M2.valoreX, 2) + POWER(M2.valoreY, 2) + POWER(M2.valoreZ, 2))), SUM(M2.valoreX)) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 0 AND 7
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '7daysMA',
              ROUND((SELECT IF(M2.valoreY IS NOT NULL, SUM(SQRT(POWER(M2.valoreX, 2) + POWER(M2.valoreY, 2) + POWER(M2.valoreZ, 2))), SUM(M2.valoreX)) / COUNT(M2.valoreX)
                FROM Misurazione M2
                WHERE DATEDIFF(M.timestamp, M2.timestamp) BETWEEN 0 AND 30
                AND M.id_sensore = M2.id_sensore
              ), 2) AS '30daysMA'
FROM Misurazione M;