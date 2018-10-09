USE master

DECLARE @SQL AS VARCHAR(MAX)
DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)

IF @SQLServerProductVersion > 10
BEGIN
-- Get information about your OS cluster (if your database server is in a cluster)  (Query 12) (Cluster Properties)
	SELECT VerboseLogging, SqlDumperDumpFlags, SqlDumperDumpPath, 
		   SqlDumperDumpTimeOut, FailureConditionLevel, HealthCheckTimeout
	FROM sys.dm_os_cluster_properties WITH (NOLOCK) OPTION (RECOMPILE);
END
-- You will see no results if your instance is not clustered


-- Get information about your cluster nodes and their status  (Query 13) (Current Cluster Node)
-- (if your database server is in a cluster)

IF @SQLServerProductVersion < 11
BEGIN
	SELECT NodeName
	FROM sys.dm_os_cluster_nodes WITH (NOLOCK) OPTION (RECOMPILE);
END
ELSE
BEGIN
	SET @SQL = '
	SELECT NodeName, status_description, is_current_owner
	FROM sys.dm_os_cluster_nodes WITH (NOLOCK) OPTION (RECOMPILE);'
	EXEC(@SQL)

END



-- Knowing which node owns the cluster resources is critical
-- Especially when you are installing Windows or SQL Server updates
-- You will see no results if your instance is not clustered
