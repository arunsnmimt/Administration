-- Version

SELECT
SERVERPROPERTY('ProductVersion') AS ProductVersion,
SERVERPROPERTY('ProductLevel') AS ProductLevel,
SERVERPROPERTY('Edition') AS Edition,
SERVERPROPERTY('EngineEdition') AS EngineEdition;

--	#######################################################################################################################################################

-- Hardware information 

DECLARE @SQL VARCHAR(1000)

IF CAST(SERVERPROPERTY('ProductVersion') AS CHAR(1)) = '9'
BEGIN
	-- Hardware information from SQL Server 2005  
	-- (Cannot distinguish between HT and multi-core) 
	SET @SQL =
	'SELECT  cpu_count AS [Logical CPU Count] ,
			hyperthread_ratio AS [Hyperthread Ratio] ,
			cpu_count / hyperthread_ratio AS [Physical CPU Count] ,
			physical_memory_in_bytes / 1048576 AS [Physical Memory (MB)]
	FROM    sys.dm_os_sys_info ;'
END
ELSE
BEGIN
    -- Hardware information from SQL Server 2008 
	-- (Cannot distinguish between HT and multi-core) 
	SET @SQL =
	'SELECT  cpu_count AS [Logical CPU Count] ,
			hyperthread_ratio AS [Hyperthread Ratio] ,
			cpu_count / hyperthread_ratio AS [Physical CPU Count] ,
			physical_memory_in_bytes / 1048576 AS [Physical Memory (MB)] ,
			sqlserver_start_time 
	FROM    sys.dm_os_sys_info ;'
END

EXEC(@SQL)

--	#######################################################################################################################################################

-- Server Settings

sp_configure 'show advanced option', '1'
RECONFIGURE WITH OVERRIDE
go

CREATE TABLE #tbl_sp_configure (
name VARCHAR(128),
minimum INTEGER,
maximum INTEGER,
config_value INTEGER,
run_value INTEGER
)


INSERT INTO #tbl_sp_configure(name, minimum,maximum, config_value, run_value )
EXEC sp_configure

SELECT name, run_value 
 FROM #tbl_sp_configure
 WHERE name IN ('max server memory (MB)' )

DROP TABLE #tbl_sp_configure