USE Master

DECLARE @command AS VARCHAR(4000)
DECLARE @BackupCommand AS VARCHAR(1000)
DECLARE @ShrinkCommand AS VARCHAR(1000)
DECLARE @SovHouse TINYINT
DECLARE @BackupPath AS VARCHAR(250)


DECLARE @LogResueNothingCount AS TINYINT
DECLARE @LogBackupRequired AS TINYINT
DECLARE @BackupActive AS TINYINT
DECLARE @NoOfAttempts		  AS SMALLINT = 0
DECLARE @LogShrunk AS BIT = 0
DECLARE @DatabaseName AS VARCHAR(128)

DECLARE @StartDateTime AS DATETIME
DECLARE @EndDateTime AS DATETIME
DECLARE @DelayLength CHAR(8)
DECLARE @Seconds INTEGER


IF OBJECT_ID('tempdb..#CurrentServer') IS NOT NULL
BEGIN
	DROP TABLE #CurrentServer
END


SELECT @@SERVERNAME AS SERVERNAME
INTO #CurrentServer


SET @SovHouse = (SELECT COUNT(*) FROM #CurrentServer 
				WHERE SERVERNAME IN ('SQLCluster05','SQLVS08','SQLVS10','SQLVS12','SQLVS14','SQLVS16','SQLVS18','SQLVS20','SQLVS22','SQLVS24'))

IF @SovHouse = 1
BEGIN
	SET @BackupPath = '\\ARIZONA\LogBackups\LogBackups'
END
ELSE
BEGIN
	SET @BackupPath = '\\spartan\SQLBackup\Logs'
END

IF OBJECT_ID('tempdb..##DatabaseFreeSpace') IS NOT NULL
BEGIN
	DROP TABLE  ##DatabaseFreeSpace
END

CREATE TABLE ##DatabaseFreeSpace
(DBName sysname,
[FileName] VARCHAR(200),
CurrentSpaceMB NUMERIC(12,2),
SpaceUsedMB NUMERIC(12,2),
FreeSpaceMB NUMERIC(12,2),
PercentFree NUMERIC(5,2),
[TYPE] TINYINT,
[physicalname] VARCHAR(200),
ShrinkFileCommand VARCHAR(500)
)

SELECT @command = 'USE [?] INSERT INTO ##DatabaseFreeSpace
						SELECT DB_NAME() AS DbName, name AS FileName,
						SIZE/128.0 AS CurrentSizeMB, 
						CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0  AS Space_Used,
						SIZE/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB,
						(SIZE/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)/ (SIZE/128.0) * 100 AS Percent_Free,			
						type,
						physical_name,
						''USE [''+DB_NAME()+ '']; DBCC SHRINKFILE(''+name+'', ''+CAST( (CAST(  CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128 /256.0 AS INT ) * 256) + 256 AS VARCHAR(30))+'')''
						FROM sys.database_files
						WHERE type = 1 -- ldf'

EXEC sp_MSforeachdb @command 

IF OBJECT_ID('tempdb..#DBsLogAvailableShrinking') IS NOT NULL
BEGIN
	DROP TABLE #DBsLogAvailableShrinking
END

SELECT  name AS Database_Name
INTO #DBsLogAvailableShrinking
FROM    sys.databases DB INNER JOIN ##DatabaseFreeSpace FS
ON DB.name = FS.DbName
WHERE state_desc = 'ONLINE'
--AND name LIKE 'TMC%'
AND name NOT IN ('master','model','msdb','tempdb','distribution')
AND log_reuse_wait_desc = 'NOTHING'
AND FreeSpaceMB > 1024
ORDER BY name


IF OBJECT_ID('tempdb..#DbsLogLogicalFiles') IS NOT NULL
BEGIN
	DROP TABLE #DbsLogLogicalFiles
END

SELECT DB_NAME(database_id) AS Database_Name,Name AS Logical_Name
INTO #DbsLogLogicalFiles
FROM sys.master_files
WHERE RIGHT(Physical_Name,3) = 'ldf'
AND  DB_NAME(database_id) LIKE 'TMC%'
AND  (SIZE*8)/1024 > 1024
ORDER BY DB_NAME(database_id)


DECLARE Shrink_Cursor CURSOR FOR 
SELECT 'USE ' + A.Database_Name + '; DBCC SHRINKFILE('+B.Logical_Name+', 1024)'   AS ShrinkCommand
FROM #DBsLogAvailableShrinking A INNER JOIN #DbsLogLogicalFiles B
ON A.Database_Name = B.Database_Name

OPEN Shrink_Cursor

FETCH NEXT FROM Shrink_Cursor INTO @ShrinkCommand

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @ShrinkCommand
--	EXEC(@ShrinkCommand)
	FETCH NEXT FROM Shrink_Cursor INTO @ShrinkCommand
END

CLOSE Shrink_Cursor
DEALLOCATE Shrink_Cursor

WHILE @NoOfAttempts < 1
BEGIN
	IF OBJECT_ID('tempdb..#DbsLogBackupRequired') IS NOT NULL
	BEGIN
		DROP TABLE #DbsLogBackupRequired
	END

	SELECT  name AS Database_Name, 'N' AS LogShrunk
	INTO #DbsLogBackupRequired
	FROM    sys.databases DB INNER JOIN ##DatabaseFreeSpace FS
	ON DB.name = FS.DbName
	WHERE state_desc = 'ONLINE'
	AND name LIKE 'TMC%'
--	AND name = 'TMC_MAN3'
	--and name NOT IN ('master','model','msdb','tempdb','distribution')
	AND name NOT IN (SELECT Database_Name FROM #DBsLogAvailableShrinking)
	AND log_reuse_wait_desc = 'LOG_BACKUP'
	AND FreeSpaceMB > 1024
	ORDER BY name

	DECLARE BackupLog_Cursor CURSOR FOR 
	SELECT 'EXECUTE master..sqlbackup ''-SQL "BACKUP LOGS ['+ A.Database_Name +'] TO DISK = '''''+@BackupPath+'\'+@@SERVERNAME+'\<database>\<AUTO>.sqb'''' WITH ERASEFILES_ATSTART = 4, MAILTO_ONERROR = ''''dba@microlise.com'''', NO_CHECKSUM, DISKRETRYINTERVAL = 30, DISKRETRYCOUNT = 10, COMPRESSION = 2, THREADCOUNT = 2"'' ' AS BackupCommand, A.Database_Name
	FROM #DbsLogBackupRequired A INNER JOIN #DbsLogLogicalFiles B
	ON A.Database_Name = B.Database_Name
	ORDER BY A.Database_Name

	OPEN BackupLog_Cursor

	FETCH NEXT FROM BackupLog_Cursor INTO @BackupCommand, @DatabaseName

	SET @StartDateTime = GETDATE()

	WHILE @@FETCH_STATUS = 0
	BEGIN

		PRINT @BackupCommand
--		EXEC(@BackupCommand)


		FETCH NEXT FROM BackupLog_Cursor INTO @BackupCommand, @DatabaseName
	END

	CLOSE BackupLog_Cursor
	DEALLOCATE BackupLog_Cursor

	SET @EndDateTime = GETDATE()
	SET @Seconds = 120 - DATEDIFF(SECOND,@StartDateTime,@EndDateTime)

	-- Wait as least 2 minutes before shrinking logs

	IF @Seconds > 0
	BEGIN
		SET @DelayLength =  REPLACE(STR(@Seconds/3600,LEN(LTRIM(@Seconds/3600))+
	ABS(SIGN(@Seconds/359999)-1)) + ':' + STR((@Seconds/60)%60,2)+
	':' + STR(@Seconds%60,2),' ','0')
		WAITFOR DELAY @DelayLength
	END
	ELSE
	BEGIN
		WAITFOR DELAY '00:00:00'
	END

	TRUNCATE TABLE ##DatabaseFreeSpace

	SELECT @command = 'USE [?] INSERT INTO ##DatabaseFreeSpace
							SELECT DB_NAME() AS DbName, name AS FileName,
							SIZE/128.0 AS CurrentSizeMB, 
							CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0  AS Space_Used,
							SIZE/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB,
							(SIZE/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)/ (SIZE/128.0) * 100 AS Percent_Free,			
							type,
							physical_name,
							''USE [''+DB_NAME()+ '']; DBCC SHRINKFILE(''+name+'', ''+CAST( (CAST(  CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128 /256.0 AS INT ) * 256) + 256 AS VARCHAR(30))+'')''
							FROM sys.database_files
							WHERE type = 1 -- ldf'

	EXEC sp_MSforeachdb @command 

	DECLARE Shrink_Cursor CURSOR FOR 
	SELECT 'USE ' + A.Database_Name + '; DBCC SHRINKFILE('+B.Logical_Name+', 1024)'   AS ShrinkCommand, A.Database_Name
	FROM #DbsLogBackupRequired A INNER JOIN #DbsLogLogicalFiles B
	ON A.Database_Name = B.Database_Name
	INNER JOIN ##DatabaseFreeSpace DFS
	ON A.Database_Name = DFS.DBName
	WHERE LogShrunk = 'N'
	AND DFS.FreeSpaceMB > 1024
	ORDER BY A.Database_Name

	--UPDATE #DbsLogBackupRequired
	--  SET LogShrunk = 'Y'
	--  FROM #DbsLogBackupRequired LBR INNER JOIN ##DatabaseFreeSpace DFS
	--  ON LBR.Database_Name = DFS.DBName
	--  WHERE DFS.FreeSpaceMB <= 1024


	OPEN Shrink_Cursor

	FETCH NEXT FROM Shrink_Cursor INTO  @ShrinkCommand, @DatabaseName

	WHILE @@FETCH_STATUS = 0
	BEGIN

			SET @LogResueNothingCount = (SELECT COUNT(*) AS RecCount
										   FROM sys.databases
										  WHERE name = @DatabaseName
											AND log_reuse_wait_desc = 'NOTHING')

			IF @LogResueNothingCount = 1 -- Ok to shrink
			BEGIN
				PRINT @ShrinkCommand
--				EXEC(@ShrinkCommand)
				UPDATE #DbsLogBackupRequired
				SET LogShrunk = 'Y'
				WHERE Database_Name = @DatabaseName
			END

		FETCH NEXT FROM Shrink_Cursor INTO @ShrinkCommand, @DatabaseName

	END

	CLOSE Shrink_Cursor
	DEALLOCATE Shrink_Cursor

	SET @NoOfAttempts = @NoOfAttempts + 1
END



SELECT  *
FROM   #DBsLogAvailableShrinking

SELECT  *
FROM   #DbsLogBackupRequired

SELECT  *
FROM #DbsLogLogicalFiles     
 
DROP TABLE #DBsLogAvailableShrinking
DROP TABLE #DbsLogBackupRequired
DROP TABLE #DbsLogLogicalFiles

