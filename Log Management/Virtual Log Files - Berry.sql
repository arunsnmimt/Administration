-- Get VLF Counts for all databases on the instance (Query 18) (VLF Counts)
-- High VLF counts can affect write performance 
-- and they can make database restores and recovery take much longer


DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)

IF @SQLServerProductVersion <11
BEGIN
	CREATE TABLE #VLFInfo (FileID  int,
						   FileSize bigint, StartOffset bigint,
						   FSeqNo      bigint, [Status]    bigint,
						   Parity      bigint, CreateLSN   numeric(38))
END
--ELSE
--BEGIN
	--CREATE TABLE #VLFInfo (RecoveryUnitID  int,
	--					   FileSize bigint, StartOffset bigint,
	--					   FSeqNo      bigint, [Status]    bigint,
	--					   Parity      bigint, CreateLSN   numeric(38))
--END

CREATE TABLE #VLFCountResults(DatabaseName sysname, VLFCount int)

	 
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM #VLFInfo; 

				TRUNCATE TABLE #VLFInfo;'
	 
SELECT DatabaseName, VLFCount  
FROM #VLFCountResults
ORDER BY VLFCount DESC;
	 
DROP TABLE #VLFInfo;
DROP TABLE #VLFCountResults;
