/*
Percentage of fragmented indexes


Explanation: This is a general indicator of performance problems. Index fragmentation can affect the rate of return for moderate to large tables. If multiple indexes are fragmented throughout the database, then an index maintenance strategy needs to be evaluated.

Guideline values:The ideal value for this metric is less than 5%; this metric counts the number of moderate to large indexes (page values > 100) with fragmentation levels greater than 5%, and then divides that number by the number of indexes in the database. This percentage may increase throughout the day as data is loaded into your database, but it will shrink when indexes are rebuilt or reorganized. This metric does not identify specific performance problems with a specific index, but should be used to obtain a general idea of how well your index maintenance strategy addresses overall problems.

Possible solutions: If this value indicates an increased amount of index fragmentation throughout your database, you may need to fine-tune your index maintenance plans. Indexes may need to be redesigned or rebuilt more frequently.

More information:

sys.dm_db_index_physical_stats (Transact-SQL)

*/

DECLARE @frag DECIMAL(10, 2) ,
    @tot INT;
   
SELECT  @frag = COUNT(*)
FROM    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL,
                                       NULL, 'LIMITED') ps
WHERE   ps.avg_fragmentation_in_percent >= 5
        AND ps.page_count > 100
        AND OBJECTPROPERTY(ps.[object_id], 'IsUserTable') = 1;
  
SELECT  @tot = COUNT(*)
FROM    sys.indexes i
WHERE   OBJECTPROPERTY(i.[object_id], 'IsUserTable') = 1;
  
SELECT  @tot = CASE WHEN @tot = 0 THEN 1
                    ELSE @tot
               END;
  
SELECT  CAST(( @frag / @tot ) AS DECIMAL(10, 2)) * 100;