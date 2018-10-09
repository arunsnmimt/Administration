
--System information, such as CPU, Memory...

EXEC xp_msver

GO

SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio], cpu_count/hyperthread_ratio AS [Physical CPU Count], physical_memory_in_bytes/1048576 AS [Physical Memory (MB)] FROM sys.dm_os_sys_info

GO

 

--Hard disk information

EXEC master..xp_fixeddrives

GO


SELECT
SERVERPROPERTY ('ServerName') AS ServerName,
SERVERPROPERTY ('Edition') AS Edition, 
SERVERPROPERTY ('EngineEdition') AS EngineEdition, --1 = Personal or Desktop Engine, 2 = Standard, 3 = Enterprise 
SERVERPROPERTY ('ProductLevel') AS ProductLevel, -- “RTM” for the initial release-to-manufacturing version, “SPn” for service packs, “Bn” for beta software
SERVERPROPERTY ('Collation') AS Collation,
SERVERPROPERTY ('InstanceName') AS InstanceName,
SERVERPROPERTY ('ProductVersion') AS ProductVersion
