/*
SQL Server: memory manager: optimizer memory (KB)


This metric measures the total amount of dynamic memory (in kilobytes) on the server being used for query optimization. Generally speaking, this metric should remain more or less the same over time. If you see regular changes in the baseline for this metric, this may indicate that your instance is using a lot of ad hoc queries. While the use of ad hoc queries is not necessarily bad, it is generally preferable to substitute ad hoc queries with stored procedures for better scalability. There are no alerts required for this metric, as baseline data is needed to make any evaluation of what is happening within the server. In addition, if you do see a lot of variation in this counter, there is no simple fix, as any fixes require code changes, which is generally not a simple thing to do.
*/

SELECT cntr_value
  FROM sys.dm_os_performance_counters
  WHERE counter_name = 'Optimizer Memory (KB)';