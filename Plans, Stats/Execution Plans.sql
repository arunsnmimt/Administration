-- Total Cached Plans

SELECT COUNT(*) FROM sys.dm_exec_cached_plans

-- Overview of plan reuse

SELECT  MAX(CASE WHEN usecounts BETWEEN 10 AND 100 THEN '10-100'
                 WHEN usecounts BETWEEN 101 AND 1000 THEN '101-1000'
                 WHEN usecounts BETWEEN 1001 AND 5000 THEN '1001-5000'
                 WHEN usecounts BETWEEN 5001 AND 10000 THEN '5001-10000'
                 ELSE CAST(usecounts AS VARCHAR(100))
            END) AS usecounts ,
        COUNT(*) AS countInstance
FROM    sys.dm_exec_cached_plans
GROUP BY CASE WHEN usecounts BETWEEN 10 AND 100 THEN 50
              WHEN usecounts BETWEEN 101 AND 1000 THEN 500
              WHEN usecounts BETWEEN 1001 AND 5000 THEN 2500
              WHEN usecounts BETWEEN 5001 AND 10000 THEN 7500
              ELSE usecounts
         END
ORDER BY CASE WHEN usecounts BETWEEN 10 AND 100 THEN 50
              WHEN usecounts BETWEEN 101 AND 1000 THEN 500
              WHEN usecounts BETWEEN 1001 AND 5000 THEN 2500
              WHEN usecounts BETWEEN 5001 AND 10000 THEN 7500
              ELSE usecounts
         END DESC 
