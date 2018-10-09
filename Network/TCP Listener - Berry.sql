DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)

IF @SQLServerProductVersion > 10
BEGIN
	-- Get information about TCP Listener for SQL Server  (Query 15) (TCP Listener States)
	SELECT listener_id, ip_address, is_ipv4, port, type_desc, state_desc, start_time
	FROM sys.dm_tcp_listener_states WITH (NOLOCK) OPTION (RECOMPILE);
END