SELECT 
    t.NAME AS TableName,
    --p.rows AS RowCounts, 
--    LEFT(CONVERT(varchar, CAST(p.rows AS money), 1),LEN(CONVERT(varchar, CAST(p.rows AS money), 1)) -3) AS Row_Count,
    LEFT(CONVERT(varchar, CAST(MAX(p.rows) AS money), 1),LEN(CONVERT(varchar, CAST(MAX(p.rows) AS money), 1)) -3) AS Row_Count,
    SUM(a.total_pages) * 8 /1024 / 1024. AS TotalSpaceGB, 
    SUM(a.used_pages) * 8 / 1024 / 1024. AS UsedSpaceGB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024 / 1024. AS UnusedSpaceGB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
    --AND t.NAME LIKE 'tbl_imp%'
GROUP BY 
    t.Name --, LEFT(CONVERT(varchar, CAST(p.rows AS money), 1),LEN(CONVERT(varchar, CAST(p.rows AS money), 1)) -3) --p.Rows
HAVING  MAX(p.rows) > 0   
ORDER BY 
    TotalSpaceGB DESC


-- Shows all user tables and row counts for the current database 
-- Remove is_ms_shipped = 0 check to include system objects 
-- i.index_id < 2 indicates clustered index (1) or hash table (0) 
SELECT o.name, LEFT(CONVERT(varchar, CAST(ddps.row_count AS money), 1),LEN(CONVERT(varchar, CAST(ddps.row_count AS money), 1)) -3) AS Row_Count, --  Format as ###,###,###
-- ddps.row_count 
ddps.in_row_data_page_count * 8 / 1024 / 1024. AS Data_Size_GB
FROM sys.indexes AS i 
 INNER JOIN sys.objects AS o ON i.OBJECT_ID = o.OBJECT_ID 
 INNER JOIN sys.dm_db_partition_stats AS ddps ON i.OBJECT_ID = ddps.OBJECT_ID 
 AND i.index_id = ddps.index_id 
 --INNER JOIN 
 --   sys.allocation_units a ON ddps.partition_id = a.container_id
WHERE i.index_id < 2 
 AND o.is_ms_shipped = 0 
-- AND o.name IN ('tbl_TrackerEvents','tbl_SystemEvents')
ORDER BY ddps.row_count DESC
--ORDER BY o.NAME 

SELECT  *
FROM    sys.dm_db_partition_stats

SELECT  *
FROM    sys.indexes

SELECT  *
FROM    sys.database_files

SELECT  *
FROM    sys.allocation_units

    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB