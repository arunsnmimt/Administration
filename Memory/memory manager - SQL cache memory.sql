/*
SQL Server: memory manager: SQL cache memory


This metric specifies the total amount of dynamic memory, in kilobytes (KB) the server is using for the dynamic SQL plan cache. It is very similar to the SQL Server: plan cache: cache pages total metric, but instead of providing the size of the dynamic SQL plan cache in kilobytes of memory, it provides very similar data in the form of the number of 8-kilobyte (KB) pages that make up the size of the plan cache.

There is no right or wrong number for this counter. In many instances, the value for this counter won’t change much over time, which is what you would expect on a server with no memory pressure. On the other hand, if you see sudden drops over time for this counter, it might be an indication that the instance is under memory pressure and SQL Server had to reclaim part of the plan cache for other use by SQL Server, which causes this counter to suddenly decrease. Or, if you see sudden increases in this counter, this may indicate that a large number of one-time use ad hoc queries may have been executed, causing plan cache pollution. This is most often seen shortly after SQL Server has been restarted, and as one-time use ad hoc queries begin to occur, this this counter will increase over time. If this is the case, consider turning on the “optimize for ad hoc workloads” instance-level option to stop plan cache pollution.
Metric definition
*/

--SQL Server: Memory Manager: SQL Cache Memory(KB) (Custom Metric)
SELECT cntr_value
  FROM sys.dm_os_performance_counters
  WHERE counter_name = 'SQL Cache Memory (KB)';