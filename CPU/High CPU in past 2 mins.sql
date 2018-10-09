-- How to find the possible queries that caused high CPU utilization in the past 2 minutes?
-- http://sqlblog.com/blogs/ben_nevarez/archive/2009/07/26/getting-cpu-utilization-data-from-sql-server.aspx
-- http://sqlknowledge.com/2010/12/how-to-monitor-sql-server-cpu-usage-and-get-auto-alerts/

DECLARE @ts_now bigint 
DECLARE @SQLVersion decimal (4,2) -- 9.00, 10.00
DECLARE @AvgCPUUtilization DECIMAL(10,2) 

SELECT @SQLVersion = LEFT(CAST(SERVERPROPERTY('PRODUCTVERSION') AS VARCHAR), 4) -- find the SQL Server Version

-- sys.dm_os_sys_info works differently in SQL Server 2005 vs SQL Server 2008+
-- comment out SQL Server 2005 if SQL Server 2008+

-- SQL Server 2005
--IF @SQLVersion = 9.00
--BEGIN 
--	SELECT @ts_now = cpu_ticks / CONVERT(float, cpu_ticks_in_ms) FROM sys.dm_os_sys_info 
--END

-- SQL Server 2008+
IF @SQLVersion >= 10.00
BEGIN
	SELECT @ts_now = cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info
END 

-- load the CPU utilization in the past 3 minutes into the temp table, you can load them into a permanent table
SELECT TOP(3) SQLProcessUtilization AS [SQLServerProcessCPUUtilization]
,SystemIdle AS [SystemIdleProcess]
,100 - SystemIdle - SQLProcessUtilization AS [OtherProcessCPU Utilization]
,DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [EventTime] 
INTO #CPUUtilization
FROM ( 
      SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
            record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
            AS [SystemIdle], 
            record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
            'int') 
            AS [SQLProcessUtilization], [timestamp] 
      FROM ( 
            SELECT [timestamp], CONVERT(xml, record) AS [record] 
            FROM sys.dm_os_ring_buffers 
            WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
            AND record LIKE '%<SystemHealth>%') AS x 
      ) AS y 
ORDER BY record_id DESC


-- check if the average CPU utilization was over 90% in the past 2 minutes
SELECT @AvgCPUUtilization = AVG([SQLServerProcessCPUUtilization] + [OtherProcessCPU Utilization])
FROM #CPUUtilization
WHERE EventTime > DATEADD(MM, -2, GETDATE())

IF @AvgCPUUtilization >= 90
BEGIN
	SELECT TOP(10)
		CONVERT(VARCHAR(25),@AvgCPUUtilization) +'%' AS [AvgCPUUtilization]
		, GETDATE() [Date and Time]
		, r.cpu_time
		, r.total_elapsed_time
		, s.session_id
		, s.login_name
		, s.host_name
		, DB_NAME(r.database_id) AS DatabaseName
		, SUBSTRING (t.text,(r.statement_start_offset/2) + 1,
		((CASE WHEN r.statement_end_offset = -1
			THEN LEN(CONVERT(NVARCHAR(MAX), t.text)) * 2
			ELSE r.statement_end_offset
		END - r.statement_start_offset)/2) + 1) AS [IndividualQuery]
		, SUBSTRING(text, 1, 200) AS [ParentQuery]
		, r.status
		, r.start_time
		, r.wait_type
		, s.program_name
	INTO #PossibleCPUUtilizationQueries		
	FROM sys.dm_exec_sessions s
	INNER JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
	INNER JOIN sys.dm_exec_requests r ON c.connection_id = r.connection_id
	CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
	WHERE s.session_id > 50
		AND r.session_id != @@spid
	order by r.cpu_time desc
	
	-- query the temp table, you can also send an email report to yourself or your development team
	SELECT *
	FROM #PossibleCPUUtilizationQueries		
END

-- drop the temp tables
IF OBJECT_ID('TEMPDB..#CPUUtilization') IS NOT NULL
drop table #CPUUtilization

IF OBJECT_ID('TEMPDB..#PossibleCPUUtilizationQueries') IS NOT NULL
drop table #PossibleCPUUtilizationQueries
