/*

SELECT  DB_NAME(DB_ID()) AS DBName, t.name, p.data_compression_desc
FROM    sys.partitions p inner join sys.tables t
ON p.object_id = t.object_id
WHERE p.data_compression <> 0

*/

CREATE TABLE #TempTable
(
	DBName VARCHAR(128),
	TableName  VARCHAR(128),
    PageCompression VARCHAR(128)
)


DECLARE @command VARCHAR(4000)
DECLARE @DatabaseName VARCHAR(128)

DECLARE DatabaseCursor CURSOR  FOR  
SELECT name
FROM master.sys.databases d
WHERE state_desc = 'ONLINE'
AND database_id > 4
AND name NOT LIKE 'ReportsServer%'
ORDER BY name
					

OPEN DatabaseCursor

FETCH NEXT FROM DatabaseCursor INTO @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN		

	SELECT @command = 'USE [' + @DatabaseName + ']

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	INSERT #TempTable (DBName, TableName, PageCompression)
	SELECT  DB_NAME(DB_ID()) AS DBName, t.name, p.data_compression_desc
	FROM    sys.partitions p inner join sys.tables t
	ON p.object_id = t.object_id
	WHERE p.data_compression <> 0
	'

--PRINT @command

	EXEC(@command)
	
	FETCH NEXT FROM DatabaseCursor INTO @DatabaseName
END

CLOSE DatabaseCursor
DEALLOCATE DatabaseCursor		

SELECT * FROM #TempTable
ORDER BY DBName, TableName

SELECT name
FROM master.sys.databases d
WHERE state_desc = 'ONLINE'
AND database_id > 4
AND name NOT LIKE 'ReportsServer%'
AND name NOT IN (
SELECT DISTINCT Dbname FROM #TempTable
)
ORDER BY name


--DROP TABLE #TempTable




--EXEC sp_estimate_data_compression_savings 'dbo', 'ICS_RTE', NULL, NULL, 'ROW' ;
--GO  
--EXEC sp_estimate_data_compression_savings 'dbo', 'ICS_RTE', NULL, NULL, 'PAGE' ;
--GO  
