-- Get information on location, time and size of any memory dumps from SQL Server  (Query 16) (Memory Dump Info)
SELECT [filename], creation_time, size_in_bytes
FROM sys.dm_server_memory_dumps WITH (NOLOCK) OPTION (RECOMPILE);