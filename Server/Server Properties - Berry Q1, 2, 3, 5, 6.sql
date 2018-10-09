USE master

DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)

-- SQL and OS Version information for current instance  (Query 1) (Version Info)
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

-- When was SQL Server installed  (Query 2) (SQL Server Install Date) 
SELECT @@SERVERNAME AS [Server Name], createdate AS [SQL Server Install Date] 
FROM sys.syslogins WITH (NOLOCK)
WHERE [sid] = 0x010100000000000512000000;

-- Get selected server properties (SQL Server 2008)  (Query 3) (Server Properties)
IF @SQLServerProductVersion < 11
BEGIN
	SELECT SERVERPROPERTY('MachineName') AS [MachineName], SERVERPROPERTY('ServerName') AS [ServerName],  
	SERVERPROPERTY('InstanceName') AS [Instance], SERVERPROPERTY('IsClustered') AS [IsClustered], 
	SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
	SERVERPROPERTY('Edition') AS [Edition], SERVERPROPERTY('ProductLevel') AS [ProductLevel], 
	SERVERPROPERTY('ProductVersion') AS [ProductVersion], SERVERPROPERTY('ProcessID') AS [ProcessID],
	SERVERPROPERTY('Collation') AS [Collation], SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled], 
	SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly];
END
ELSE
BEGIN
	SELECT SERVERPROPERTY('MachineName') AS [MachineName], SERVERPROPERTY('ServerName') AS [ServerName],  
	SERVERPROPERTY('InstanceName') AS [Instance], SERVERPROPERTY('IsClustered') AS [IsClustered], 
	SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
	SERVERPROPERTY('Edition') AS [Edition], SERVERPROPERTY('ProductLevel') AS [ProductLevel], 
	SERVERPROPERTY('ProductVersion') AS [ProductVersion], SERVERPROPERTY('ProcessID') AS [ProcessID],
	SERVERPROPERTY('Collation') AS [Collation], SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled], 
	SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly],
	SERVERPROPERTY('IsHadrEnabled') AS [IsHadrEnabled], SERVERPROPERTY('HadrManagerStatus') AS [HadrManagerStatus];
END


-- Windows information (SQL Server 2008 R2 SP1 or greater)  (Query 5) (Windows Info)
SELECT windows_release, windows_service_pack_level, 
       windows_sku, os_language_version
FROM sys.dm_os_windows_info WITH (NOLOCK) OPTION (RECOMPILE);

-- SQL Server Services information (SQL Server 2008 R2 SP1 or greater)  (Query 6) (SQL Server Services Info)
SELECT servicename, startup_type_desc, status_desc, 
last_startup_time, service_account, is_clustered, cluster_nodename
FROM sys.dm_server_services WITH (NOLOCK) OPTION (RECOMPILE);

IF @SQLServerProductVersion > 10
BEGIN
-- Shows you where the SQL Server error log is located and how it is configured  (Query 11) (SQL Server Error Log)
	SELECT is_enabled, [path], max_size, max_files
	FROM sys.dm_os_server_diagnostics_log_configurations WITH (NOLOCK) OPTION (RECOMPILE);
END