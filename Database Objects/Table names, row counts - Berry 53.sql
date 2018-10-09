-- Get Table names, row counts, and compression status for clustered index or heap  (Query 53) (Table Sizes)
DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)


IF @SQLServerProductVersion < 11
BEGIN

	SELECT OBJECT_NAME(object_id) AS [ObjectName], 
	SUM(Rows) AS [RowCount], data_compression_desc AS [CompressionType]
	FROM sys.partitions WITH (NOLOCK)
	WHERE index_id < 2 --ignore the partitions from the non-clustered index if any
	AND OBJECT_NAME(object_id) NOT LIKE N'sys%'
	AND OBJECT_NAME(object_id) NOT LIKE N'queue_%' 
	AND OBJECT_NAME(object_id) NOT LIKE N'filestream_tombstone%' 
	AND OBJECT_NAME(object_id) NOT LIKE N'fulltext%'
	AND OBJECT_NAME(object_id) NOT LIKE N'ifts_comp_fragment%'
	GROUP BY object_id, data_compression_desc
	ORDER BY SUM(Rows) DESC OPTION (RECOMPILE);

END
ELSE
BEGIN

	SELECT OBJECT_NAME(object_id) AS [ObjectName], 
	SUM(Rows) AS [RowCount], data_compression_desc AS [CompressionType]
	FROM sys.partitions WITH (NOLOCK)
	WHERE index_id < 2 --ignore the partitions from the non-clustered index if any
	AND OBJECT_NAME(object_id) NOT LIKE N'sys%'
	AND OBJECT_NAME(object_id) NOT LIKE N'queue_%' 
	AND OBJECT_NAME(object_id) NOT LIKE N'filestream_tombstone%' 
	AND OBJECT_NAME(object_id) NOT LIKE N'fulltext%'
	AND OBJECT_NAME(object_id) NOT LIKE N'ifts_comp_fragment%'
	AND OBJECT_NAME(object_id) NOT LIKE N'filetable_updates%'
	AND OBJECT_NAME(object_id) NOT LIKE N'xml_index_nodes%'
	GROUP BY object_id, data_compression_desc
	ORDER BY SUM(Rows) DESC OPTION (RECOMPILE);
END

-- Gives you an idea of table sizes, and possible data compression opportunities
