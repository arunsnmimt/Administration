/*
Possible duplicate indexes

When a table has multiple indexes defined on the same columns, it produces duplicate indexes that waste space and have a negative impact on performance. This metric measures the number of possible duplicate indexes per database. Use it if you want to monitor when a duplicate index is created or to find whether there is a duplicated index in your database.

Further analysis is necessary to identify how many of the indexes found by this metric are really duplicated, and you can use the query below to find exact matches. The indexes must have the same key columns in the same order, and the same included columns but in any order. You can consider dropping the indexes that are definitely duplicates.

Note: Be very careful before dropping an index. Check that the index is really not used (sys.dm_db_index_usage_stats can help with this), and that applications are not using the index on hints. Even if there is a duplicate based on the key columns, there are occasionally valid reasons for having a duplicate, for example, a clustered index and a non-clustered index can use the same key columns.

*/

-- Exactly duplicated indexes
WITH  indexcols
        AS (SELECT object_id AS id,
                index_id AS indid,
                name,
                (SELECT CASE keyno
                          WHEN 0 THEN NULL
                          ELSE colid
                        END AS [data()]
                  FROM sys.sysindexkeys AS k
                  WHERE k.id = i.object_id
                    AND k.indid = i.index_id
                  ORDER BY keyno,
                    colid
                FOR
                 XML PATH('')
                ) AS cols,
                (SELECT CASE keyno
                          WHEN 0 THEN colid
                          ELSE NULL
                        END AS [data()]
                  FROM sys.sysindexkeys AS k
                  WHERE k.id = i.object_id
                    AND k.indid = i.index_id
                  ORDER BY colid
                FOR
                 XML PATH('')
                ) AS inc
              FROM sys.indexes AS i
           )
  SELECT DB_NAME() AS 'DBName',
      OBJECT_SCHEMA_NAME(c1.id) + '.'
        + OBJECT_NAME(c1.id) AS 'TableName',
      c1.name + CASE c1.indid
                  WHEN 1 THEN ' (clustered index)'
                  ELSE ' (nonclustered index)'
                END AS 'IndexName',
      c2.name + CASE c2.indid
                  WHEN 1 THEN ' (clustered index)'
                  ELSE ' (nonclustered index)'
                END AS 'ExactDuplicatedIndexName'
    FROM indexcols AS c1
    INNER JOIN indexcols AS c2
    ON
      c1.id = c2.id
      AND c1.indid < c2.indid
      AND c1.cols = c2.cols
      AND c1.inc = c2.inc;

