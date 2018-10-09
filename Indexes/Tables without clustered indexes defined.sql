/*
Tables without clustered indexes defined


This metric measures the number of tables without clustered indexes defined that contain more than 1000 rows per database. It is good practice to define the clustered index for every table in the database to help improve query performance.

Note: Having a clustered index per table is NOT compulsory. There are cases, where a heap (table without a clustered index) is acceptable.

*/
WITH CTE_1
AS
(
  SELECT db_name() as dbname,
         o.name as tablename,
         (SELECT SUM(p.rows)
            FROM sys.partitions p
           WHERE p.index_id = i.index_id
             AND i.object_id = p.object_id) as number_of_rows
    FROM sys.indexes i
   INNER JOIN sys.objects o
      ON i.object_id = o.object_id
   WHERE OBJECTPROPERTY(o.object_id, 'IsUserTable') = 1
     AND OBJECTPROPERTY(o.object_id, 'TableHasClustIndex') = 0
)
SELECT *
  FROM CTE_1
 WHERE number_of_rows > 1000;