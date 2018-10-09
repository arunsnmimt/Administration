/*
Percentage of database free space


This metric measures the percentage of database free space – both reserved and unused – to help you manage space requirements more efficiently. For example, you might find this data helps you to correctly estimate file size, so you don’t suffer from problems associated with automatic file growth.
Metric definition
Metric Name:
	
*/

SELECT (AU.unallocated + AU.unused) * 100 / (AU.reserved + AU.unallocated) AS free_space_pct
  FROM (SELECT AU.reserved,
               AU.reserved - AU.used AS unused,
               CASE WHEN SF.db_size >= AU.reserved THEN (SF.db_size - AU.reserved) ELSE 0 END AS unallocated
          FROM (SELECT SUM(CAST(CASE WHEN SF.status & 64 = 0 THEN SF.size ELSE 0 END AS DECIMAL(38, 2))) AS db_size
                  FROM dbo.sysfiles AS SF) AS SF
               CROSS JOIN
               (SELECT SUM(CAST(A.total_pages AS DECIMAL(38, 2))) AS reserved,
                       SUM(CAST(A.used_pages AS DECIMAL(38, 2))) AS used
                  FROM sys.partitions AS P
                       INNER JOIN
                       sys.allocation_units AS A
                       on A.container_id = P.partition_id) AS AU) AS AU;