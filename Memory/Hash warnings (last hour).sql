/*
Hash warnings (last hour)


This metric measures the number of hash warnings events in the last hour. A hash warning event means that part of the data processed for a hash operation was written to tempdb. This means that a hash join or hash aggregate has run out of memory and been forced to spill information to disk (tempdb) during query execution, which can degrade the SQL Server performance. If you have performance problems, this metric may help you to find out what they are. It is also a good idea to run this metric on servers suffering from tempdb contention, because data is spilled to tempdb.

Use this metric to find out when a hash recursion or hash bailout (cessation of hashing) has occurred on your server during a hash operation. A hash recursion (event 0) happens when the input of the query does not fit entirely into available memory, forcing SQL Server to split the input into multiple partitions that are then processed seperately. A hash bailout (event 1) is even worse for performance. It occurs when a hashing operation reaches its maximum recursion level and shifts to an alternative query plan to process the remaining partitioned data. This usually occurs because the data is skewed.

To eliminate or reduce the frequency of hash recursions and bailouts, do one of the following:

    Make sure that statistics exist on the columns that are being joined or grouped.
    If statistics exist on the columns, update them.
    Use a different type of join. For example, use a MERGE or LOOP join instead, if appropriate.
    Increase available memory. Hash recursion or bailout occurs when there is not enough memory to process queries in place and they need to spill to disk.

Creating or updating the statistics on the column involved in the join is the most effective way to reduce the number of hash recursion or bailouts that occur.

*/

DECLARE @Str NVARCHAR(MAX);
 
SELECT @Str = CONVERT(NVARCHAR(MAX), Value)
  FROM :: FN_TRACE_GETINFO(DEFAULT) AS Tab
  WHERE Tab.Property = 2
    AND Traceid = 1;
  
SELECT COUNT(*) AS Cnt
  FROM FN_TRACE_GETTABLE(@Str, DEFAULT) AS trace
  INNER JOIN sys.trace_events te
  ON te.trace_event_id = trace.EventClass
  WHERE te.name LIKE 'Hash Warning'
    AND trace.StartTime >= DATEADD(hh, -1, GETDATE());