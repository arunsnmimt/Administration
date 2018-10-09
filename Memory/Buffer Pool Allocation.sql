USE master

-- Get total buffer usage by database
SELECT  DB_NAME(database_id) AS [Database Name] ,
        CAST(COUNT(*) * 8 / 1024.0 AS DECIMAL (12,2)) AS [Cached Size (MB)],
        CAST(SUM (CAST ([free_space_in_bytes] AS BIGINT)) / (1024 * 1024.) AS DECIMAL (12,2)) AS [MBEmpty]
FROM    sys.dm_os_buffer_descriptors
--WHERE   database_id > 4 -- exclude system databases
--        AND database_id <> 32767 -- exclude ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC ;

-- Breaks down buffers by object (table, index) in the buffer pool (???? is this correct as figures
-- dont relate to query above.
USE NEXPHASEV6 --TMC_MARITIME
SELECT  OBJECT_NAME(p.[object_id]) AS [ObjectName] ,
--        p.index_id ,
        COUNT(*) / 128 AS [Buffer size(MB)] ,
        COUNT(*) AS [Buffer_count]
FROM    sys.allocation_units AS a
INNER JOIN sys.dm_os_buffer_descriptors
                 AS b ON a.allocation_unit_id = b.allocation_unit_id
        INNER JOIN sys.partitions AS p ON a.container_id = p.hobt_id
WHERE   b.database_id = DB_ID()
        AND p.[object_id] > 100 -- exclude system objects
GROUP BY p.[object_id] 
--       , p.index_id
ORDER BY buffer_count DESC ;


-- Break things down by table and index 

USE TMC_DHL_ICELAND

SELECT
    OBJECT_NAME (p.[object_id]) AS [Object],
    p.[index_id],
    i.[name] AS [Index],
    i.[type_desc] AS [Type],
    --au.[type_desc] AS [AUType],
    --DPCount AS [DirtyPageCount],
    --CPCount AS [CleanPageCount],
    --DPCount * 8 / 1024 AS [DirtyPageMB],
    --CPCount * 8 / 1024 AS [CleanPageMB],
    (DPCount + CPCount) * 8 / 1024 AS [TotalMB],
    --DPFreeSpace / 1024 / 1024 AS [DirtyPageFreeSpace],
    --CPFreeSpace / 1024 / 1024 AS [CleanPageFreeSpace],
    ([DPFreeSpace] + [CPFreeSpace]) / 1024 / 1024 AS [FreeSpaceMB],
    CAST (ROUND (100.0 * (([DPFreeSpace] + [CPFreeSpace]) / 1024) / (([DPCount] + [CPCount]) * 8), 1) AS DECIMAL (4, 1)) AS [FreeSpacePC]
FROM
    (SELECT
        allocation_unit_id,
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 1 ELSE 0 END) AS [DPCount],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 0 ELSE 1 END) AS [CPCount],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN CAST ([free_space_in_bytes] AS BIGINT) ELSE 0 END) AS [DPFreeSpace],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 0 ELSE CAST ([free_space_in_bytes] AS BIGINT) END) AS [CPFreeSpace]
    FROM sys.dm_os_buffer_descriptors
    GROUP BY [allocation_unit_id]) AS buffers
INNER JOIN sys.allocation_units AS au
    ON au.[allocation_unit_id] = buffers.[allocation_unit_id]
INNER JOIN sys.partitions AS p
    ON au.[container_id] = p.[partition_id]
INNER JOIN sys.indexes AS i
    ON i.[index_id] = p.[index_id] AND p.[object_id] = i.[object_id]
WHERE p.[object_id] > 100 AND ([DPCount] + [CPCount]) > 12800 -- Taking up more than 100MB
ORDER BY [TotalMB] DESC;







-- Clean and dirty pages there are in the buffer pool per-database

SELECT
   (CASE WHEN ([is_modified] = 1) THEN N'Dirty' ELSE N'Clean' END) AS N'Page State',
   (CASE WHEN ([database_id] = 32767) THEN N'Resource Database' ELSE DB_NAME ([database_id]) END) AS N'Database Name',
   COUNT (*) AS N'Page Count'
FROM sys.dm_os_buffer_descriptors
   GROUP BY [database_id], [is_modified]
   ORDER BY [database_id], [is_modified];
GO

