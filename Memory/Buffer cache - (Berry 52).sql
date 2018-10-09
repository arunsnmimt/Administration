-- Breaks down buffers used by current database by object (table, index) in the buffer cache  (Query 52) (Buffer Usage)
-- This query can take some time on a large database

DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)



IF @SQLServerProductVersion < 11
BEGIN
	SELECT OBJECT_NAME(p.[object_id]) AS [Object Name], p.index_id, 
	CAST(COUNT(*)/128.0 AS DECIMAL(10, 2)) AS [Buffer size(MB)],  
	COUNT(*) AS [BufferCount], p.Rows AS [Row Count],
	p.data_compression_desc AS [Compression Type]
	FROM sys.allocation_units AS a WITH (NOLOCK)
	INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
	ON a.allocation_unit_id = b.allocation_unit_id
	INNER JOIN sys.partitions AS p WITH (NOLOCK)
	ON a.container_id = p.hobt_id
	WHERE b.database_id = CONVERT(int,DB_ID())
	AND p.[object_id] > 100
	GROUP BY p.[object_id], p.index_id, p.data_compression_desc, p.[Rows]
	ORDER BY [BufferCount] DESC OPTION (RECOMPILE);
END
ELSE
BEGIN

	SELECT OBJECT_NAME(p.[object_id]) AS [ObjectName], 
	p.index_id, COUNT(*)/128 AS [Buffer size(MB)],  COUNT(*) AS [BufferCount], 
	p.data_compression_desc AS [CompressionType], a.type_desc, p.[rows]
	FROM sys.allocation_units AS a WITH (NOLOCK)
	INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
	ON a.allocation_unit_id = b.allocation_unit_id
	INNER JOIN sys.partitions AS p WITH (NOLOCK)
	ON a.container_id = p.partition_id
	WHERE b.database_id = CONVERT(int,DB_ID())
	AND p.[object_id] > 100
	GROUP BY p.[object_id], p.index_id, p.data_compression_desc, a.type_desc, p.[rows]
	ORDER BY [BufferCount] DESC OPTION (RECOMPILE);


END
-- Tells you what tables and indexes are using the most memory in the buffer cache
-- It can help identify possible candidates for data compression




