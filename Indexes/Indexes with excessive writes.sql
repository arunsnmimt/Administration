/*
Indexes with excessive writes

This metric measures the total number of indexes per database, where the number of writes exceed the number of reads. It provides a general indicator of possible performance factors affecting queries in your database.

If indexes are being updated with new data more often than they are being used in query plans, they can cause performance issues during write-heavy operations (INSERT, UPDATE, and DELETE statements), while adding little or no benefit to read operations.


Guideline values: The ideal value for this metric should be 0, but not every bad index should be dropped. There may be some indexes which are used for occasional (but important) queries. This metric should be used to provide insight into the overall indexing strategy.

Possible solutions: If this value indicates the need for further investigation, the following query can help identify indexes that may be candidates for adjustment or elimination:

*/

SELECT  OBJECT_NAME(s.object_id) As table_name, i.name AS index_name, i.type_desc AS index_type
FROM    sys.dm_db_index_usage_stats s WITH ( NOLOCK )
JOIN sys.indexes i WITH (NOLOCK) ON s.index_id = i.index_id
AND s.object_id = i.object_id
WHERE   OBJECTPROPERTY(s.[object_id], 'IsUserTable') = 1
AND s.database_id = DB_ID()
AND s.user_updates > ( s.user_seeks + s.user_scans + s.user_lookups )
AND s.index_id > 1
