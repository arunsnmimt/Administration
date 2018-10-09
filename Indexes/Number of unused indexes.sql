/*
Number of unused indexes


Use this metric if you want to monitor the number of indexes per database that haven’t been used for the last month. Indexes that aren’t in use should be removed because they can degrade INSERT, UPDATE and DELETE performance, and they use storage space.
*/

SELECT db_name() as dbname,
       o.name as tablename,
       i.name as indexname,
       i.index_id,
       user_seeks + user_scans + user_lookups as total_reads,
       user_updates as total_writes,
       (SELECT SUM(p.rows)
          FROM sys.partitions p
         WHERE p.index_id = s.index_id
           AND s.object_id = p.object_id) as number_of_rows,
       s.last_user_lookup,
       s.last_user_scan,
       s.last_user_seek
  FROM sys.indexes i
 INNER JOIN sys.objects o
    ON i.object_id = o.object_id
  LEFT OUTER JOIN sys.dm_db_index_usage_stats s
    ON i.index_id = s.index_id
   AND s.object_id = i.object_id
 WHERE OBJECTPROPERTY(o.object_id, 'IsUserTable') = 1
   AND ISNULL(s.database_id, DB_ID()) = DB_ID()
   AND (
        isnull(s.last_user_seek, '19000101') < datediff(month, -1, getdate()) AND
        isnull(s.last_user_scan, '19000101') < datediff(month, -1, getdate()) AND
        isnull(s.last_user_lookup, '19000101') < datediff(month, -1, getdate())
       )
 ORDER BY total_reads DESC;

