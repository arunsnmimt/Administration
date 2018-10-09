USE master

DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)
DECLARE @SQL VARCHAR(MAX)
-- Hardware information from SQL Server 2012  (Query 8) (Hardware Info)
-- (new virtual_machine_type_desc column)
-- (Cannot distinguish between HT and multi-core)

IF @SQLServerProductVersion < 11
BEGIN
	SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
	cpu_count/hyperthread_ratio AS [Physical CPU Count], 
	physical_memory_in_bytes/1048576 AS [Physical Memory (MB)], 
	sqlserver_start_time --, affinity_type_desc -- (affinity_type_desc is only in 2008 R2)
	FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);
END
ELSE
BEGIN
	SET @SQL = 
	'SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
	cpu_count/hyperthread_ratio AS [Physical CPU Count], 
	physical_memory_kb/1024 AS [Physical Memory (MB)], committed_target_kb/1024 AS [Committed Target Memory (MB)],
	max_workers_count AS [Max Workers Count], affinity_type_desc AS [Affinity Type], 
	sqlserver_start_time AS [SQL Server Start Time], virtual_machine_type_desc AS [Virtual Machine Type]
	FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);'
	EXEC(@SQL)
END


-- Gives you some good basic hardware information about your database server


-- Get System Manufacturer and model number from  (Query 9) (System Manufacturer)
-- SQL Server Error log. This query might take a few seconds 
-- if you have not recycled your error log recently
EXEC xp_readerrorlog 0,1,"Manufacturer"; 

-- This can help you determine the capabilities
-- and capacities of your database server


-- Get processor description from Windows Registry  (Query 10) (Processor Description)
EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE',
'HARDWARE\DESCRIPTION\System\CentralProcessor\0','ProcessorNameString';
