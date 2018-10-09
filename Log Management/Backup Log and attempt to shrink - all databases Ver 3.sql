/*
USE TMC_WMARMSTRONGS

DECLARE @LatencySecs AS INT
------------------------------

SET @LatencySecs = 999
WHILE @LatencySecs >= 60
BEGIN
	SET @LatencySecs =	(SELECT	CASE 
				   WHEN MAX(LastContactTime) > GETDATE() THEN 0
				   ELSE DATEDIFF(SECOND, MAX(LastContactTime), GETDATE())
				END AS Latency_Secs
		FROM tbl_Vehicles WITH (NOLOCK)
		WHERE LastContactTime < DATEADD(SECOND, 60, GETDATE()))
		
	PRINT @LatencySecs
	
	IF @LatencySecs >= 60
	BEGIN
		WAITFOR DELAY '00:01'
	END
END

EXEC msdb.dbo.sp_send_dbmail @profile_name  = 'Microlise', @recipients = 'michael.giles@microlise.com', @body = 'No Latency on WMArm',@Subject = 'No Latency on WMArm - Backup/Shrink logs started'

*/

--DBCC INDEXDEFRAG (TMC_RYDER_FMS, 'tbl_TrackerEvents', 'PK_tbl_TrackerEvents')
--EXEC msdb.dbo.sp_send_dbmail @profile_name  = 'Microlise', @recipients = 'michael.giles@microlise.com', @body = 'Defrag Completed',@Subject = 'Defrag  Completed';

USE master

DECLARE @command AS VARCHAR(4000)
DECLARE @BackupCommand AS VARCHAR(1000)
DECLARE @ShrinkCommand AS VARCHAR(1000)
DECLARE @SovHouse TINYINT
DECLARE @BackupPath AS VARCHAR(250)


DECLARE @LogResueNothingCount AS TINYINT
DECLARE @LogBackupRequired AS TINYINT
DECLARE @BackupActive AS TINYINT
DECLARE @NoOfAttempts AS SMALLINT; SET @NoOfAttempts = 0
DECLARE @LogShrunk AS BIT; SET @LogShrunk = 0
DECLARE @DatabaseName AS VARCHAR(128)

DECLARE @StartDateTime AS DATETIME
DECLARE @EndDateTime AS DATETIME
DECLARE @DelayLength CHAR(8)
DECLARE @Seconds INTEGER
DECLARE @MinLogSize SMALLINT
SET @MinLogSize = 512


IF OBJECT_ID('tempdb..#CurrentServer') IS NOT NULL
BEGIN
	DROP TABLE #CurrentServer
END


SELECT @@SERVERNAME AS SERVERNAME
INTO #CurrentServer


SET @SovHouse = (SELECT COUNT(*) FROM #CurrentServer 
				WHERE SERVERNAME IN ('SQLCluster05','SQLVS08','SQLVS10','SQLVS12','SQLVS14','SQLVS16','SQLVS18','SQLVS20','SQLVS22','SQLVS24','SQLVS26'))

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
AND name LIKE 'TMC%'
--and name NOT IN ('master','model','msdb','tempdb','distribution')
--AND name NOT IN ('TMC_RYDER_FMS')
AND log_reuse_wait_desc = 'NOTHING'
AND FreeSpaceMB > @MinLogSize
ORDER BY name


IF OBJECT_ID('tempdb..#DbsLogLogicalFiles') IS NOT NULL
BEGIN
	DROP TABLE #DbsLogLogicalFiles
END

SELECT DB_NAME(database_id) AS Database_Name,Name AS Logical_Name
INTO #DbsLogLogicalFiles
FROM sys.master_files
WHERE RIGHT(Physical_Name,3) = 'ldf'
and DB_NAME(database_id) NOT IN ('master','model','msdb','tempdb','distribution')
--AND DB_NAME(database_id) NOT IN ('TMC_RYDER_FMS')
--AND  DB_NAME(database_id) LIKE 'TMC%'
AND  (SIZE*8)/@MinLogSize > @MinLogSize
ORDER BY DB_NAME(database_id)

--SELECT  *
--FROM #DbsLogLogicalFiles    

IF OBJECT_ID('tempdb..#DbsLogBackupRequired') IS NOT NULL
BEGIN
	DROP TABLE #DbsLogBackupRequired
END

SELECT  name AS Database_Name
INTO #DbsLogBackupRequired
FROM    sys.databases DB INNER JOIN ##DatabaseFreeSpace FS
ON DB.name = FS.DbName
WHERE state_desc = 'ONLINE'
and DB.name NOT IN ('master','model','msdb','tempdb','distribution')
AND DB.name NOT LIKE 'Export%'
--AND DB.name NOT IN ('TMC_RYDER_FMS')
AND DB.recovery_model_desc = 'FULL'
ORDER BY name


DECLARE Shrink_Cursor CURSOR FOR 
SELECT 'USE ' + A.Database_Name + '; DBCC SHRINKFILE('+B.Logical_Name+', '++CAST(@MinLogSize AS VARCHAR(6))+')'   AS ShrinkCommand
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

SET @NoOfAttempts = @NoOfAttempts + 1

WHILE @NoOfAttempts <= 2
BEGIN


	DECLARE BackupLog_Cursor CURSOR FOR 
	SELECT 'EXECUTE master..sqlbackup ''-SQL "BACKUP LOGS ['+ A.Database_Name +'] TO DISK = '''''+@BackupPath+'\'+@@SERVERNAME+'\<database>\<AUTO>.sqb'''' WITH ERASEFILES_ATSTART = 4, MAILTO_ONERROR = ''''michael.giles@microlise.com'''', NO_CHECKSUM, DISKRETRYINTERVAL = 30, DISKRETRYCOUNT = 10, COMPRESSION = 2, THREADCOUNT = 2"'' ' AS BackupCommand, A.Database_Name
	FROM #DbsLogBackupRequired A INNER JOIN #DbsLogLogicalFiles B
	ON A.Database_Name = B.Database_Name
	ORDER BY A.Database_Name

	OPEN BackupLog_Cursor

	FETCH NEXT FROM BackupLog_Cursor INTO @BackupCommand, @DatabaseName

	SET @StartDateTime = GETDATE()

	WHILE @@FETCH_STATUS = 0
	BEGIN

--		PRINT @BackupCommand
		EXEC(@BackupCommand)


		FETCH NEXT FROM BackupLog_Cursor INTO @BackupCommand, @DatabaseName
	END

	CLOSE BackupLog_Cursor
	DEALLOCATE BackupLog_Cursor


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
	SELECT 'USE ' + A.Name + '; DBCC SHRINKFILE('+B.Logical_Name+', '++CAST(@MinLogSize AS VARCHAR(6))+')'   AS ShrinkCommand, A.Name
	FROM sys.databases A INNER JOIN #DbsLogLogicalFiles B
	ON A.Name = B.Database_Name
	INNER JOIN ##DatabaseFreeSpace DFS
	ON A.Name = DFS.DBName
	WHERE DFS.FreeSpaceMB > @MinLogSize
	ORDER BY A.Name


	OPEN Shrink_Cursor

	FETCH NEXT FROM Shrink_Cursor INTO  @ShrinkCommand, @DatabaseName

	WHILE @@FETCH_STATUS = 0
	BEGIN

--		PRINT @ShrinkCommand
		EXEC(@ShrinkCommand)

		FETCH NEXT FROM Shrink_Cursor INTO @ShrinkCommand, @DatabaseName

	END

	CLOSE Shrink_Cursor
	DEALLOCATE Shrink_Cursor

	SET @EndDateTime = GETDATE()
	SET @Seconds = 120 - DATEDIFF(SECOND,@StartDateTime,@EndDateTime)
	PRINT @Seconds

	-- Wait as least 2 minutes before next loop

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

	SET @NoOfAttempts = @NoOfAttempts + 1
END



--SELECT  *
--FROM   #DBsLogAvailableShrinking

--SELECT  *
--FROM   #DbsLogBackupRequired

--SELECT  *
--FROM #DbsLogLogicalFiles     
 
DROP TABLE #DBsLogAvailableShrinking
DROP TABLE #DbsLogBackupRequired
DROP TABLE #DbsLogLogicalFiles


