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

IF OBJECT_ID('tempdb..#CurrentServer') IS NOT NULL
BEGIN
	DROP TABLE #CurrentServer
END


SELECT @@SERVERNAME AS ServerName
INTO #CurrentServer


SET @SovHouse = (SELECT COUNT(*) FROM #CurrentServer 
				WHERE ServerName IN ('SQLCluster05','SQLVS08','SQLVS10','SQLVS12','SQLVS14','SQLVS16','SQLVS18','SQLVS20','SQLVS22','SQLVS24'))

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

IF OBJECT_ID('tempdb..#DbsLogBackupRequired') IS NOT NULL
BEGIN
	DROP TABLE #DbsLogBackupRequired
END

IF OBJECT_ID('tempdb..#DbsLogLogicalFiles') IS NOT NULL
BEGIN
	DROP TABLE #DbsLogLogicalFiles
END

SELECT  name AS Database_Name
INTO #DBsLogAvailableShrinking
FROM    sys.databases DB INNER JOIN ##DatabaseFreeSpace FS
ON DB.name = FS.DbName
WHERE state_desc = 'ONLINE'
and name LIKE 'TMC%'
--and name NOT IN ('master','model','msdb','tempdb','distribution')
AND log_reuse_wait_desc = 'NOTHING'
AND FreeSpaceMB > 1024
ORDER BY name

SELECT  name AS Database_Name
INTO #DbsLogBackupRequired
FROM    sys.databases DB INNER JOIN ##DatabaseFreeSpace FS
ON DB.name = FS.DbName
WHERE state_desc = 'ONLINE'
and name LIKE 'TMC%'
--and name NOT IN ('master','model','msdb','tempdb','distribution')
AND log_reuse_wait_desc = 'LOG_BACKUP'
AND FreeSpaceMB > 1024
ORDER BY name

SELECT DB_NAME(database_id) AS Database_Name,Name AS Logical_Name
INTO #DbsLogLogicalFiles
FROM sys.master_files
WHERE RIGHT(Physical_Name,3) = 'ldf'
and  DB_NAME(database_id) LIKE 'TMC%'
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
--	PRINT @ShrinkCommand
	EXEC(@ShrinkCommand)
	FETCH NEXT FROM Shrink_Cursor INTO @ShrinkCommand
END

CLOSE Shrink_Cursor
DEALLOCATE Shrink_Cursor

----
--SELECT  *
--FROM    #DbsLogBackupRequired

--SELECT  *
--FROM    #DbsLogLogicalFiles

--DECLARE @BackupPath AS VARCHAR(250) = 'test'
--
DECLARE BackupLog_Shrink_Cursor CURSOR FOR 
SELECT 'EXECUTE master..sqlbackup ''-SQL "BACKUP LOGS ['+ A.Database_Name +'] TO DISK = '''''+@BackupPath+'\'+@@SERVERNAME+'\<database>\<AUTO>.sqb'''' WITH ERASEFILES_ATSTART = 4, MAILTO_ONERROR = ''''dba@microlise.com'''', NO_CHECKSUM, DISKRETRYINTERVAL = 30, DISKRETRYCOUNT = 10, COMPRESSION = 2, THREADCOUNT = 2"'' ' AS BackupCommand, 'USE ' + A.Database_Name + '; DBCC SHRINKFILE('+B.Logical_Name+', 1024)'   AS ShrinkCommand, A.Database_Name
FROM #DbsLogBackupRequired A INNER JOIN #DbsLogLogicalFiles B
ON A.Database_Name = B.Database_Name
ORDER BY A.Database_Name

OPEN BackupLog_Shrink_Cursor

FETCH NEXT FROM BackupLog_Shrink_Cursor INTO @BackupCommand, @ShrinkCommand, @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN

	WHILE @NoOfAttempts <= 6 AND @LogShrunk = 0
	BEGIN
		SET @LogBackupRequired = (SELECT COUNT(*) AS RecCount
									   FROM sys.databases
									  WHERE name = @DatabaseName
										AND log_reuse_wait_desc = 'LOG_BACKUP')
		IF @LogBackupRequired = 1
		BEGIN
--			PRINT @BackupCommand
			EXEC(@BackupCommand)
		END

		WAITFOR DELAY '00:02:00' -- 2 Minutes

		SET @LogResueNothingCount = (SELECT COUNT(*) AS RecCount
									   FROM sys.databases
									  WHERE name = @DatabaseName
										AND log_reuse_wait_desc = 'NOTHING')

		IF @LogResueNothingCount = 1 -- Ok to shrink
		BEGIN
--			PRINT @ShrinkCommand
			EXEC(@ShrinkCommand)
			SET @LogShrunk = 1
		END
		ELSE
		BEGIN
			SET @BackupActive = (SELECT COUNT(*) AS RecCount
									   FROM sys.databases
									  WHERE name = @DatabaseName
										AND log_reuse_wait_desc = 'ACTIVE_BACKUP_OR_RESTORE')
							
			IF @BackupActive = 0									
			BEGIN
				SET @NoOfAttempts = @NoOfAttempts + 1
			END
		END
	END

	SET @NoOfAttempts = 0
	SET @LogShrunk  = 0

	FETCH NEXT FROM BackupLog_Shrink_Cursor INTO @BackupCommand, @ShrinkCommand, @DatabaseName

-- Backup log twice before attepting to shrink. Sometimes this is necessary
	

	--EXEC(@BackupCommand)
	--WAITFOR DELAY '00:01:00'
	--EXEC(@BackupCommand)
	--WAITFOR DELAY '00:01:00'
	--EXEC(@ShrinkCommand)
END

CLOSE BackupLog_Shrink_Cursor
DEALLOCATE BackupLog_Shrink_Cursor

--SELECT  *
--FROM   #DBsLogAvailableShrinking

--SELECT  *
--FROM   #DbsLogBackupRequired

--SELECT  *
--FROM #DbsLogLogicalFiles     
 
DROP TABLE #DBsLogAvailableShrinking
DROP TABLE #DbsLogBackupRequired
DROP TABLE #DbsLogLogicalFiles

/*

SET @SQL = 'EXECUTE master..sqlbackup ''-SQL "BACKUP LOGS ['+ A.Database_Name +'] TO DISK = ''''\\ARIZONA\LogBackups\LogBackups\'+@@SERVERNAME+'\<database>\<AUTO>.sqb'''' WITH ERASEFILES_ATSTART = 4, MAILTO_ONERROR = ''''dba@microlise.com'''', NO_CHECKSUM, DISKRETRYINTERVAL = 30, DISKRETRYCOUNT = 10, COMPRESSION = 2, THREADCOUNT = 2"'' '

PRINT @SQL
								  
DECLARE @LogResueNothingCount AS TINYINT
DECLARE @LogBackupRequired AS TINYINT
DECLARE @BackupActive AS TINYINT
DECLARE @NoOfAttempts		  AS SMALLINT = 0
DECLARE @LogShrunk AS BIT = 0

-- See if log can be shrunk

WHILE @NoOfAttempts <= 6 AND @LogShrunk = 0
BEGIN
	SET @LogBackupRequired = (SELECT COUNT(*) AS RecCount
								   FROM sys.databases
								  WHERE name = 'TMC_CULINA'
									AND log_reuse_wait_desc = 'LOG_BACKUP')

	IF @LogBackupRequired = 1
	BEGIN
		EXECUTE master..sqlbackup '-SQL "BACKUP LOGS [TMC_CULINA] TO DISK = ''\\ARIZONA\LogBackups\LogBackups\SQLVS20\<database>\<AUTO>.sqb'' WITH ERASEFILES_ATSTART = 4, MAILTO_ONERROR = ''dba@microlise.com'', NO_CHECKSUM, DISKRETRYINTERVAL = 30, DISKRETRYCOUNT = 10, COMPRESSION = 2, THREADCOUNT = 2"'
	END


	SET @LogResueNothingCount = (SELECT COUNT(*) AS RecCount
								   FROM sys.databases
								  WHERE name = 'TMC_CULINA'
									AND log_reuse_wait_desc = 'NOTHING')

	IF @LogResueNothingCount = 1 -- Ok to shrink
	BEGIN
		USE TMC_CULINA;	DBCC SHRINKFILE(TMC_CULINA_log, 256)
		SET @LogShrunk = 1
	END
	ELSE
	BEGIN
		
		SET @BackupActive = (SELECT COUNT(*) AS RecCount
								   FROM sys.databases
								  WHERE name = 'TMC_CULINA'
									AND log_reuse_wait_desc = 'ACTIVE_BACKUP_OR_RESTORE')
									
		IF @BackupActive = 0									
		BEGIN
			SET @NoOfAttempts = @NoOfAttempts + 1
		END

		WAITFOR DELAY '00:01'
		
	END
END					

*/
	  