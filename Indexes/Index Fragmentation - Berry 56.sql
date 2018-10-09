-- Get fragmentation info for all indexes above a certain size in the current database  (Query 56) (Index Fragmentation)
-- Note: This could take some time on a very large database
-- Helps determine whether you have framentation in your relational indexes
-- and how effective your index maintenance strategy is

SELECT DB_NAME(database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], 
i.name AS [Index Name], ps.index_id, ps.index_type_desc, ps.avg_fragmentation_in_percent, 
ps.fragment_count, ps.page_count, i.fill_factor, i.has_filter, i.filter_definition, 'USE ' + DB_NAME() + '; ALTER INDEX ' + i.name + ' ON ' + OBJECT_NAME(i.OBJECT_ID) + ' REBUILD'
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,'LIMITED') AS ps
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ps.[object_id] = i.[object_id] 
AND ps.index_id = i.index_id
WHERE database_id = DB_ID()
AND page_count > 2500
AND  ps.avg_fragmentation_in_percent > 30
ORDER BY avg_fragmentation_in_percent DESC OPTION (RECOMPILE);









-- SQL Server 2000 - Mike Giles

USE [SDSDB]
GO

DECLARE @dbname nvarchar(130);
DECLARE @dbid int;
SET @dbname = DB_NAME()-- change the name of the target database here
 
SELECT @dbid = dbid FROM sys.sysdatabases WHERE name = @dbname


SELECT DB_NAME(database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], 
i.name AS [Index Name], ps.index_id, ps.index_type_desc, ps.avg_fragmentation_in_percent, 
ps.fragment_count, ps.page_count, i.fill_factor, i.has_filter, i.filter_definition, 
'USE ' + DB_NAME() + '; ALTER INDEX ' + i.name + ' ON ' + OBJECT_NAME(i.OBJECT_ID) + ' REBUILD' AS Command_Rebuild,
'USE ' + DB_NAME() + '; ALTER INDEX ' + i.name + ' ON ' + OBJECT_NAME(i.OBJECT_ID) + ' REORGANIZE' AS Command_Reorg,
'USE ' + DB_NAME() + '; DBCC DBREINDEX ('''+OBJECT_NAME(i.OBJECT_ID)+''','''+i.name+''')' AS [Command_DBREINDEX (Rebuild)],
'USE ' + DB_NAME() + '; DBCC INDEXDEFRAG (0,'''+OBJECT_NAME(i.OBJECT_ID)+''','''+i.name+''')' AS [Command_INDEXDEFRAG (Reorg)]
FROM sys.dm_db_index_physical_stats( @dbid,NULL, NULL, NULL ,'LIMITED') AS ps
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ps.[object_id] = i.[object_id] 
AND ps.index_id = i.index_id
WHERE database_id =  @dbid
--AND page_count > 2500
AND  ps.avg_fragmentation_in_percent > 10
AND index_type_desc <> 'HEAP'
ORDER BY  avg_fragmentation_in_percent DESC OPTION (RECOMPILE);

