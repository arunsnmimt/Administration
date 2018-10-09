-- Isolate top waits for server instance since last restart or statistics clear  (Query 23) (Top Waits)
DECLARE @SQL AS VARCHAR(MAX)

DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)


IF @SQLServerProductVersion < 11
BEGIN

	WITH Waits AS
	(SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
	100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
	ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
	FROM sys.dm_os_wait_stats WITH (NOLOCK)
	WHERE wait_type NOT IN (N'CLR_SEMAPHORE',N'LAZYWRITER_SLEEP',N'RESOURCE_QUEUE',N'SLEEP_TASK',
	N'SLEEP_SYSTEMTASK',N'SQLTRACE_BUFFER_FLUSH',N'WAITFOR', N'LOGMGR_QUEUE',N'CHECKPOINT_QUEUE',
	N'REQUEST_FOR_DEADLOCK_SEARCH',N'XE_TIMER_EVENT',N'BROKER_TO_FLUSH',N'BROKER_TASK_STOP',N'CLR_MANUAL_EVENT',
	N'CLR_AUTO_EVENT',N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
	N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
	N'ONDEMAND_TASK_QUEUE', N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH'))
	SELECT W1.wait_type, 
	CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
	CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
	CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
	FROM Waits AS W1
	INNER JOIN Waits AS W2
	ON W2.rn <= W1.rn
	GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
	HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE)
END
ELSE
BEGIN
	SET @SQL = '
	WITH Waits
	AS (SELECT wait_type, CAST(wait_time_ms / 1000. AS DECIMAL(12, 2)) AS [wait_time_s],
		CAST(100. * wait_time_ms / SUM(wait_time_ms) OVER () AS decimal(12,2)) AS [pct],
		ROW_NUMBER() OVER (ORDER BY wait_time_ms DESC) AS rn
		FROM sys.dm_os_wait_stats WITH (NOLOCK)
		WHERE wait_type NOT IN (N''CLR_SEMAPHORE'', N''LAZYWRITER_SLEEP'', N''RESOURCE_QUEUE'',N''SLEEP_TASK'',
								N''SLEEP_SYSTEMTASK'', N''SQLTRACE_BUFFER_FLUSH'', N''WAITFOR'', N''LOGMGR_QUEUE'',
								N''CHECKPOINT_QUEUE'', N''REQUEST_FOR_DEADLOCK_SEARCH'', N''XE_TIMER_EVENT'',
								N''BROKER_TO_FLUSH'', N''BROKER_TASK_STOP'', N''CLR_MANUAL_EVENT'', N''CLR_AUTO_EVENT'',
								N''DISPATCHER_QUEUE_SEMAPHORE'' ,N''FT_IFTS_SCHEDULER_IDLE_WAIT'', N''XE_DISPATCHER_WAIT'',
								N''XE_DISPATCHER_JOIN'', N''SQLTRACE_INCREMENTAL_FLUSH_SLEEP'', N''ONDEMAND_TASK_QUEUE'',
								N''BROKER_EVENTHANDLER'', N''SLEEP_BPOOL_FLUSH'', N''SLEEP_DBSTARTUP'', N''DIRTY_PAGE_POLL'',
								N''HADR_FILESTREAM_IOMGR_IOCOMPLETION'',N''SP_SERVER_DIAGNOSTICS_SLEEP'')),
	Running_Waits 
	AS (SELECT W1.wait_type, wait_time_s, pct,
		SUM(pct) OVER(ORDER BY pct DESC ROWS UNBOUNDED PRECEDING) AS [running_pct]
		FROM Waits AS W1)
	SELECT wait_type, wait_time_s, pct, running_pct
	FROM Running_Waits
	WHERE running_pct - pct <= 99
	ORDER BY running_pct
	OPTION (RECOMPILE)'
	EXEC(@SQL)
END


-- Common Significant Wait types with BOL explanations

-- *** Network Related Waits ***
-- ASYNC_NETWORK_IO		Occurs on network writes when the task is blocked behind the network

-- *** Locking Waits ***
-- LCK_M_IX				Occurs when a task is waiting to acquire an Intent Exclusive (IX) lock
-- LCK_M_IU				Occurs when a task is waiting to acquire an Intent Update (IU) lock
-- LCK_M_S				Occurs when a task is waiting to acquire a Shared lock

-- *** I/O Related Waits ***
-- ASYNC_IO_COMPLETION  Occurs when a task is waiting for I/Os to finish
-- IO_COMPLETION		Occurs while waiting for I/O operations to complete. 
--                      This wait type generally represents non-data page I/Os. Data page I/O completion waits appear 
--                      as PAGEIOLATCH_* waits
-- PAGEIOLATCH_SH		Occurs when a task is waiting on a latch for a buffer that is in an I/O request. 
--                      The latch request is in Shared mode. Long waits may indicate problems with the disk subsystem.
-- PAGEIOLATCH_EX		Occurs when a task is waiting on a latch for a buffer that is in an I/O request. 
--                      The latch request is in Exclusive mode. Long waits may indicate problems with the disk subsystem.
-- WRITELOG             Occurs while waiting for a log flush to complete. 
--                      Common operations that cause log flushes are checkpoints and transaction commits.
-- PAGELATCH_EX			Occurs when a task is waiting on a latch for a buffer that is not in an I/O request. 
--                      The latch request is in Exclusive mode.
-- BACKUPIO				Occurs when a backup task is waiting for data, or is waiting for a buffer in which to store data

-- *** CPU Related Waits ***
-- SOS_SCHEDULER_YIELD  Occurs when a task voluntarily yields the scheduler for other tasks to execute. 
--                      During this wait the task is waiting for its quantum to be renewed.

-- THREADPOOL			Occurs when a task is waiting for a worker to run on. 
--                      This can indicate that the maximum worker setting is too low, or that batch executions are taking 
--                      unusually long, thus reducing the number of workers available to satisfy other batches.
-- CX_PACKET			Occurs when trying to synchronize the query processor exchange iterator 
--						You may consider lowering the degree of parallelism if contention on this wait type becomes a problem
--						Often caused by missing indexes or poorly written queries
