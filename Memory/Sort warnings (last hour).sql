/*
Sort warnings (last hour)


This metric measures the number of sort warning events that occurred in the last hour. Sort warning operations that do not fit into memory can degrade query and server performance because multiple passes over the data are required to sort the data. It is important to optimize queries by removing them.

Note: This metric relies on SQL Server default trace. If this is not enabled, the metric will not work.
Description:

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
  WHERE te.name LIKE 'Sort Warnings'
    AND trace.StartTime >= DATEADD(hh, -1, GETDATE());
