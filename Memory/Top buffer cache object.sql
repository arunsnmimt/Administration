/*
Top buffer cache object


This metric measures the amount of memory used in the buffer cache by the largest object (based on the number of pages). It checks the sys.dm_os_buffer_descriptors to identify the object, and returns the relative percentage used. You should use this metric if you want to monitor what is in the buffer area, or if you are having performance-related disk read problems.

Memory is one of the most important resources for SQL Server, so it’s important to make sure SQL Server is using it efficiently. For example, if 90% of the buffer pool (memory area) is being used to store data from one table, it is important to try to optimize the size of this table to save space for other tables in memory. It is very common for one or two objects to be responsible for using a large amount of the buffer cache. To increase the efficiency of the buffer cache area, these objects may benefit from a schema revision (datatype changes or sparse columns), and are great candidates for compression.
*/
WITH  CTE_1
        AS (SELECT DB_NAME() AS dbName,
                obj.name AS objectname,
                ind.name AS indexname,
                COUNT(*) AS cached_pages_count
              FROM sys.dm_os_buffer_descriptors AS bd
              INNER JOIN (SELECT object_id AS objectid,
                              OBJECT_NAME(object_id) AS name,
                              index_id,
                              allocation_unit_id
                            FROM sys.allocation_units AS au
                            INNER JOIN sys.partitions AS p
                            ON
                              au.container_id = p.hobt_id
                              AND (au.type = 1
                              OR au.type = 3)
                          UNION ALL
                          SELECT object_id AS objectid,
                              OBJECT_NAME(object_id) AS name,
                              index_id,
                              allocation_unit_id
                            FROM sys.allocation_units AS au
                            INNER JOIN sys.partitions AS p
                            ON
                              au.container_id = p.partition_id
                              AND au.type = 2
                         ) AS obj
              ON
                bd.allocation_unit_id = obj.allocation_unit_id
              LEFT OUTER JOIN sys.indexes ind
              ON
                obj.objectid = ind.object_id
                AND obj.index_id = ind.index_id
              WHERE bd.database_id = DB_ID()
                AND bd.page_type IN ('data_page', 'index_page')
              GROUP BY obj.name,
                ind.name,
                obj.index_id
           )
  SELECT TOP 1 --*, -- Uncomment to return the object name
      ObjPercent = CONVERT(NUMERIC(18, 2),
        (CONVERT(NUMERIC(18, 2), cached_pages_count)
        / SUM(cached_pages_count) OVER ()) * 100)
    FROM CTE_1
    ORDER BY cached_pages_count DESC;