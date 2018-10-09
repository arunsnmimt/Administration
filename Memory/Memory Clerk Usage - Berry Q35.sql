DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)

DECLARE @SQL AS VARCHAR(4000)


-- Memory Clerk Usage for instance  (Query 35) (Memory Clerk Usage)
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)

-- CACHESTORE_SQLCP  SQL Plans         
-- These are cached SQL statements or batches that aren't in stored procedures, functions and triggers
--
-- CACHESTORE_OBJCP  Object Plans      
-- These are compiled plans for stored procedures, functions and triggers
--
-- CACHESTORE_PHDR   Algebrizer Trees  
-- An algebrizer tree is the parsed SQL text that resolves the table and column names


IF @SQLServerProductVersion < 11
BEGIN
	SET @SQL = '
	SELECT TOP(10) [type] AS [Memory Clerk Type], SUM(single_pages_kb)/1024 AS [SPA Memory Usage (MB)] 
	FROM sys.dm_os_memory_clerks WITH (NOLOCK)
	GROUP BY [type]  
	ORDER BY SUM(single_pages_kb) DESC OPTION (RECOMPILE);'

END
ELSE
BEGIN
	SET @SQL = '
	SELECT TOP(10) [type] AS [Memory Clerk Type], 
		   SUM(pages_kb)/1024 AS [Memory Usage (MB)] 
	FROM sys.dm_os_memory_clerks WITH (NOLOCK)
	GROUP BY [type]  
	ORDER BY SUM(pages_kb) DESC OPTION (RECOMPILE);'

END


EXEC(@SQL)