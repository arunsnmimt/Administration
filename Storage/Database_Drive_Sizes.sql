/* 
	SQL Server 2000
*/

--===== Declare local files

DECLARE @DBID INT
DECLARE @DBName VARCHAR(30)
DECLARE @Text NVARCHAR(300)

DECLARE @TableOuput TABLE (
	DBName VARCHAR(128),
	fileid SMALLINT,
	DBFileName VARCHAR(500),
	FileGroupName VARCHAR(50),
	DBSize VARCHAR(20),
	MaxSize VARCHAR(20),
	Growth VARCHAR(20),
	Usage VARCHAR(20)
	)
--===== Get the first database ID
 SELECT @DBID = MIN(DBID) FROM Master.dbo.SysDataBases

--===== Loop until we run out of database ID's
  WHILE @DBID IS NOT NULL
  BEGIN
        --===== Get the database name for the current DBID
         SELECT @DBName = NAME FROM Master.dbo.SysDataBases WHERE DBID = @DBID 

        --===== Set the dynamic SQL to use the database name and get the info
            SET @Text = N'USE '+ @DBName + N' EXEC sp_HelpFile'

        --===== Exec the dynamic SQL
--		  INSERT @TableOuput
           EXEC dbo.sp_ExecuteSql @Text
        
        --===== Get the next larger DBID
         SELECT @DBID = MIN(DBID) FROM Master..SysDataBases WHERE DBID > @DBID
    END



USE master

--EXEC master..xp_fixeddrives

--SELECT  *
--FROM sys.master_files

--	#######################################################################################################################################################

-- Free space on drives

USE master

IF OBJECT_ID('tempdb..#tbl_xp_fixeddrives') IS NULL
BEGIN
	CREATE TABLE #tbl_xp_fixeddrives
	(Drive CHAR(1) NOT NULL,
	Free_MB INT NOT NULL,
	Free_GB DECIMAL (10,1) NULL
	)
END
ELSE
BEGIN
	TRUNCATE TABLE #tbl_xp_fixeddrives
END


INSERT INTO #tbl_xp_fixeddrives(Drive, [Free_MB])
EXEC master.sys.xp_fixeddrives

UPDATE #tbl_xp_fixeddrives
SET Free_GB = Free_MB / 1024.

SELECT @@SERVERNAME AS Server_Name, temp.Drive, d.[Description], d.Total_Size_GB, temp.Free_GB, CAST(CAST((temp.Free_GB / Total_Size_GB) * 100  AS DECIMAL(10,1)) AS VARCHAR(10)) +'%' AS Percent_Free
  FROM    #tbl_xp_fixeddrives temp LEFT OUTER JOIN [amber].Admin_DBA.dbo.tbl_DiskAlerts d 
  ON temp.Drive = d.Drive
  AND d.Server_Name = @@SERVERNAME
--  WHERE d.[Description] LIKE '%Log%'

DROP TABLE #tbl_xp_fixeddrives


--	#######################################################################################################################################################
-- Data/Log File Locations

SELECT DISTINCT
LEFT(Physical_Name, LEN(Physical_Name) - CHARINDEX('\',REVERSE(Physical_Name),1)) AS Location,
UPPER(RIGHT(Physical_Name,3)) AS File_Type
FROM sys.master_files mf INNER JOIN sys.sysdatabases db
ON mf.database_id = db.[dbid]
WHERE db.name NOT IN ('tempdb','master','model','msdb')

--	#######################################################################################################################################################
-- Database Sizes

SELECT db.name, CAST((SUM(mf.size)*8)/1024/1024. AS DECIMAL(10,2)) AS SizeGB, (SUM(mf.size) * 8)/1024 AS db_Size_MB
FROM sys.databases db 
INNER JOIN sys.master_files mf
ON db.database_id = mf.database_id
--and db.state_desc = 'OFFLINE'
--and db.name LIKE 'TMC%'
GROUP BY  db.name
ORDER BY db.name
ORDER BY (SUM(mf.size) * 8)/1024 DESC

-- Database Data File sizes


SELECT db.name, mf.type_desc,  CAST((SUM(mf.size)*8)/1024/1024. AS DECIMAL(10,2)) AS SizeGB, (SUM(mf.size) * 8)/1024 AS db_Size_MB
FROM sys.databases db 
INNER JOIN sys.master_files mf
ON db.database_id = mf.database_id
AND db.state_desc = 'ONLINE'
GROUP BY  db.name, mf.type_desc
ORDER BY db.name, mf.type_desc DESC

--	#######################################################################################################################################################


-- Recovery model, log reuse wait description, log file size,  
-- log usage size and compatibility level for all databases on instance 
SELECT  db.[name] AS [DATABASE Name] ,
        db.recovery_model_desc AS [Recovery Model] ,
        db.log_reuse_wait_desc AS [LOG Reuse Wait Description] ,
        ls.cntr_value AS [LOG SIZE (KB)] ,
		lu.cntr_value AS [LOG Used (KB)] ,
        CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)
                    AS DECIMAL(18,2)) * 100 AS [LOG Used %] ,
        db.[compatibility_level] AS [DB Compatibility LEVEL] ,
        db.page_verify_option_desc AS [Page Verify OPTION]
FROM    sys.databases AS db
        INNER JOIN sys.dm_os_performance_counters AS lu
                    ON db.name = lu.instance_name
        INNER JOIN sys.dm_os_performance_counters AS ls
                    ON db.name = ls.instance_name
WHERE   lu.counter_name LIKE 'Log File(s) Used Size (KB)%'
        AND ls.counter_name LIKE 'Log File(s) Size (KB)%'

--	#######################################################################################################################################################

-- Sorted by Database Name

SELECT  *
FROM    sys.sysdatabases

SELECT --DB_NAME(database_id) AS DatabaseName, 
	   db.name AS DatabaseName,
--db.create_date,
mf.Name AS Logical_Name,
LEFT(Physical_Name,1) AS Drive,
Physical_Name,
 --d.[Description] AS Drive_Desc,
--Physical_Name, (SIZE*8)/1024 SizeMB, 
CAST((SIZE*8)/1024/1024. AS DECIMAL(10,2)) AS SizeGB,
	   UPPER(RIGHT(mf.Physical_Name,3)) AS File_Type
FROM sys.master_files mf INNER JOIN sys.databases db
ON mf.database_id = db.database_id
--LEFT OUTER JOIN [amber].Admin_DBA.dbo.tbl_DiskAlerts d 
--ON LEFT(Physical_Name,1) = d.Drive
--  AND d.Server_Name = @@SERVERNAME
WHERE db.state_desc = 'ONLINE'
--AND db.name <> 'tempdb'
--AND  d.[Description] NOT LIKE '%Flash%'
--AND RIGHT(mf.Physical_Name,3) = 'ldf'
--AND RIGHT(mf.Physical_Name,3) = 'mdf'
--ORDER BY  db.name --DB_NAME(database_id)
--AND db.name LIKE '%Reports%'
--AND LEFT(db.name,3) = 'TMC'
--AND (LEFT(Physical_Name, 1) = 'F') -- OR LEFT(Physical_Name, 1) = 'G')
ORDER BY LEFT(Physical_Name,1), db.name
--ORDER BY LEFT(Physical_Name,1), DB_NAME(db.database_id)
ORDER BY SIZE DESC --db.crdate desc, DB_NAME(database_id)


SELECT  *
FROM    sys.databases

--WHERE DB_NAME(database_id) = 'AdventureWorks'

-- All files Sorted by size (Largest First)

SELECT DB_NAME(database_id) AS DatabaseName,
Name AS Logical_Name,
LEFT(Physical_Name,1) AS Drive,
Physical_Name, type_desc,
--(SIZE*8)/1024 SizeMB, 
CAST((SIZE*8)/1024/1024. AS DECIMAL(10,2)) AS SizeGB
FROM sys.master_files
--WHERE DB_NAME(database_id) LIKE '%UAT%'
--ORDER BY DB_NAME(database_id)
ORDER BY SIZE DESC

-- Data files Sorted by size (Largest First)

SELECT DB_NAME(mf.database_id) AS DatabaseName, RIGHT(Physical_Name,3) AS 'File_Type',
--mf.Name AS Logical_Name,
LEFT(Physical_Name,1) AS Drive,
--Physical_Name, 
--(SIZE*8)/1024 SizeMB, 
--CAST(SIZE AS BIGINT)*8
--CAST((SIZE*8)/1024/1024. AS DECIMAL(10,2)) AS SizeGB
CAST((CAST(SIZE AS BIGINT)*8)/1024/1024. AS DECIMAL(10,2)) AS SizeGB
FROM sys.master_files mf INNER JOIN sys.databases db
ON mf.database_id = db.database_id
WHERE (RIGHT(Physical_Name,3) = 'mdf'
OR RIGHT(Physical_Name,3) = 'ldf'
--AND db.state_desc = 'OFFLINE'
OR RIGHT(Physical_Name,3) = 'ndf')
--AND LEFT(Physical_Name,1) = 'G'
--AND DB_NAME(mf.database_id) LIKE '%Reports%'
--AND DB_NAME(mf.database_id) IN ('TMC_MAN_HOYER','TMC_MAN_GROCON')
--ORDER BY DB_NAME(mf.database_id)
ORDER BY  DB_NAME(mf.database_id) -- SIZE DESC

-- Log files Sorted by size (Largest First)  CAST(dbsizeMB/1024 AS DECIMAL (10,2)) AS dbsizeGB

SELECT DB_NAME(database_id) AS DatabaseName,
Name AS Logical_Name,
Physical_Name, (SIZE*8)/1024 SizeMB, CAST((SIZE*8)/1024/1024. AS DECIMAL (10,2)) AS SizeGB
FROM sys.master_files
WHERE RIGHT(Physical_Name,3) = 'ldf'
--AND LEFT(Physical_Name,1) = 'G'
--AND DB_NAME(database_id) LIKE 'tempdb%'
ORDER BY SIZE DESC
--ORDER BY DB_NAME(database_id)
/*
AND (DB_NAME(database_id) LIKE '%MALCOLM%' OR
DB_NAME(database_id) LIKE '%BIBBY%' OR
DB_NAME(database_id) LIKE '%HOYER%' OR
DB_NAME(database_id) LIKE '%JJBANNISTER%' OR
DB_NAME(database_id) LIKE '%MITCHELLS%' OR
DB_NAME(database_id) LIKE '%AXIS%' OR
DB_NAME(database_id) LIKE '%CEVA%' OR
DB_NAME(database_id) LIKE '%FRANCE%' OR
DB_NAME(database_id) LIKE '%ASHLEY%' OR
DB_NAME(database_id) LIKE '%NORTHUMBRIA%' OR
DB_NAME(database_id) LIKE '%PEACOCKS%' OR
DB_NAME(database_id) LIKE '%RENTAL%' OR
DB_NAME(database_id) LIKE '%SAINTS%' OR
DB_NAME(database_id) LIKE '%SBD%' OR
DB_NAME(database_id) LIKE '%TUFFNELLS%')
*/

--SELECT * FROM sys.database_files

--	#######################################################################################################################################################
/* Free space on database files  */
--	#######################################################################################################################################################
USE master

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


DECLARE @command VARCHAR(1000)
DECLARE @DatabaseName VARCHAR(128)

DECLARE DatabaseCursor CURSOR  FOR  
			select name from master.dbo.sysdatabases

			--SELECT name
			--FROM master.sys.databases 
			--WHERE state_desc = 'ONLINE'
--			AND name NOT IN ('ARC_3663_WHOLESALE_2014-05-18','ARC_BnQ_2012-09-25','ARC_BOUGHEY_20130512','ARC_BSKYB_20121204','ARC_BSKYB_2013-09-01','ARC_BSKYB_2013-12-01','ARC_BSKYB_20140302','ARC_DHL_NISA_20140622','ARC_DOWNTON_2014-04-20','ARC_GSH_UK_2014-01-26','ARC_INFINIS_2014-01-19')
			ORDER BY name
			
OPEN DatabaseCursor

FETCH NEXT FROM DatabaseCursor INTO @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN	
--	SELECT @command = 'USE [?] INSERT INTO ##DatabaseFreeSpace
	SELECT @command = 'USE ['+@DatabaseName+'] INSERT INTO ##DatabaseFreeSpace
							SELECT DB_NAME() AS DbName, name AS FileName,
							SIZE/128.0 AS CurrentSizeMB, 
							CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0  AS Space_Used,
							SIZE/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB,
							(SIZE/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)/ (SIZE/128.0) * 100 AS Percent_Free,			
							type,
							physical_name,
							''USE [''+DB_NAME()+ '']; DBCC SHRINKFILE(''+name+'', ''+CAST( (CAST(  CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128 /256.0 AS INT ) * 256) + 256 AS VARCHAR(30))+'')''
							FROM sys.database_files'

	--EXEC sp_MSforeachdb @command 
	EXEC (@command)
	FETCH NEXT FROM DatabaseCursor INTO @DatabaseName
END

SELECT  *
FROM  ##DatabaseFreeSpace
WHERE DBName NOT IN ('master','model','msdb','ReportServerTempDB','ReportServer2TempDB','ReportServer3TempDB')
--WHERE DBName <> 'tempdb'
--AND (DBName LIKE '%MALCOLM%' OR DBName LIKE '%TUFFNELLS%')
--AND DBName IN ('TMC_BSKYB','TMC_CHAMBERLAINS','TMC_LAURA_ASHLEY','TMC_MAN_SAINTS','TMC_MARITIME','TMC_MITCHELLS','TMC_NIGHTFREIGHT','TMC_TUFFNELLS')
AND [type] = 0 -- mdf
--AND [TYPE] = 1 -- ldf
AND LEFT(PhysicalName,1) IN ('G') --,'H')
AND CurrentSpaceMB > 1024
AND FreeSpaceMB > 1024
ORDER BY FreeSpaceMB DESC -- DBName

CLOSE DatabaseCursor
DEALLOCATE DatabaseCursor

DROP TABLE  ##DatabaseFreeSpace


--	#######################################################################################################################################################

--	#######################################################################################################################################################
-- SQL 2000

SELECT RTRIM(name) AS [Segment Name], groupid AS [Group Id], filename AS [File Name],
   CAST(size/128.0 AS DECIMAL(15,2)) AS [Allocated Size in MB],
   CAST(FILEPROPERTY(name, 'SpaceUsed')/128.0 AS DECIMAL(15,2)) AS [Space Used in MB],
   CAST([maxsize]/128.0 AS DECIMAL(15,2)) AS [Max in MB],
   CAST([maxsize]/128.0-(FILEPROPERTY(name, 'SpaceUsed')/128.0) AS DECIMAL(15,2)) AS [Available Space in MB],
   CAST((CAST(FILEPROPERTY(name, 'SpaceUsed')/128.0 AS DECIMAL(15,2))/CAST([maxsize]/128.0 AS DECIMAL(15,2)))*100 AS DECIMAL(15,2)) AS [Percent Used]
FROM sysfiles
ORDER BY groupid DESC


						SELECT DB_NAME() AS DbName, name AS FileName,
						TYPE,
						SIZE/128.0 AS CurrentSizeMB, 
						SIZE/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB,
						(SIZE/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0)/ (SIZE/128.0) * 100 AS Percent_Free,
						CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0  AS Space_Used,
						'DBCC SHRINKFILE('+name+', '+CAST( CAST(  CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS INT ) + 512 AS VARCHAR(30))+')'
						FROM sys.database_files
						


