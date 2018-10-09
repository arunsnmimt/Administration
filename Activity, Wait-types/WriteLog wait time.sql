/*
WriteLog wait time


During a transaction, data is written to the log cache so that it’s ready to be written to the log file on commit, or can be rolled back if necessary. When the log cache is being flushed to disk, the SQL Server session will wait on the WriteLog wait type. If this happens all the time, it may suggest disk bottlenecks where the transaction log is stored.

	
WriteLog Wait Time (ms per sec)
Description:

Occurs while waiting for a log flush to complete. Common operations that cause log flushes are checkpoints and transaction commits. Metric shows the wait time (in ms) per elapsed second. For more information, see http://blogs.msdn.com/b/sqlsakthi/archive/2011/04/17/what-is-writelog-waittype-and-how-to-troubleshoot-and-fix-this-wait-in-sql-server.aspx.
*/

SELECT wait_time_ms
FROM  sys.dm_os_wait_stats
WHERE wait_type = 'WRITELOG'