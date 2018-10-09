USE [master];
GO

IF OBJECT_ID('master.dbo.sp_AskBrent') IS NOT NULL 
    DROP PROC dbo.sp_AskBrent;
GO


CREATE PROCEDURE [dbo].[sp_AskBrent]
    @Question NVARCHAR(MAX) = NULL ,
    @AsOf DATETIME = NULL ,
	@ExpertMode TINYINT = 0 ,
    @Seconds TINYINT = 5 ,
    @OutputType VARCHAR(20) = 'TABLE' ,
    @OutputDatabaseName NVARCHAR(128) = NULL ,
    @OutputSchemaName NVARCHAR(256) = NULL ,
    @OutputTableName NVARCHAR(256) = NULL ,
    @OutputXMLasNVARCHAR TINYINT = 0 ,
    @Version INT = NULL OUTPUT,
    @VersionDate DATETIME = NULL OUTPUT
    WITH EXECUTE AS CALLER, RECOMPILE
AS 
BEGIN
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
sp_AskBrent (TM)

(C) 2013, Brent Ozar Unlimited. 
See http://BrentOzar.com/go/eula for the End User Licensing Agreement.

Sure, the server needs tuning - but why is it slow RIGHT NOW?
sp_AskBrent performs quick checks for things like:

* Blocking queries that have been running a long time
* Backups, restores, DBCCs
* Recently cleared plan cache
* Transactions that are rolling back

To learn more, visit http://www.BrentOzar.com/askbrent/ where you can download
new versions for free, watch training videos on how it works, get more info on
the findings, and more.  To contribute code and see your name in the change
log, email your improvements & checks to Help@BrentOzar.com.

Known limitations of this version:
 - No support for SQL Server 2000 or compatibility mode 80.
 - If a temp table called #CustomPerfmonCounters exists for any other session,
   but not our session, this stored proc will fail with an error saying the
   temp table #CustomPerfmonCounters doesn't exist.

Unknown limitations of this version:
 - None. Like Zombo.com, the only limit is yourself.

Changes in v9 - Nov 3, 2013
 - Changed date format to accommodate the British. They gave us Gordon Ramsay,
   so it's the least I could do. Many folks reported this one.

Changes in v8 - October 21, 2013
 - Whoops! Left an extra line in check 8 that failed on SQL 2005.

Changes in v7 - October 21, 2013
 - Updated many of the links to point to newly published pages.
 - Performance tuning Check 8 (sleeping connections with open transactions).
   Went from >1 minute at StackExchange to <10 seconds.

Changes in v6 - October 11, 2013
 - Time travel enabled. Can log to database using the @Output* parameters, and
   you can go back in time with the @AsOf parameter.
 - Bug fixing for SQL Server 2005 compatibility.

Changes in v5 - September 16, 2013
 - Enabled @Question again.
 - Bail out of plan cache analysis if we're more than 10 seconds behind.

Changes in v4 - August 25, 2013
 - Added plan cache analysis.
 - Fixed checkid 8 (sleeping query with open transactions) for SQL 2005/08/R2.
 - Refactored a little for readability.
 - Added QueryPlan to the default results because the plan cache stuff is cool.

Changes in v3 - August 23, 2013
 - Added @OutputType = 'SCHEMA', which returns the version number and a list
   of columns for a CREATE TABLE definition for the default outputs. We don't
   include the actual CREATE TABLE part because you might want to use a table
   variable or whatever.
 - Added @OutputXMLasNVARCHAR. If 1, then the QueryPlan is outputted as an
   NVARCHAR(MAX) instead of XML. This helps if you want to insert the
   sp_AskBrent results into a temp table. For instructions, visit:

Changes in v2 - August 9, 2013
 - Added @Seconds to control the sampling time.
 - @ExpertMode now returns all work tables with no thresholds.
 - Added basic wait stats, file stats, Perfmon checks.

Changes in v1 - July 11, 2013
 - Initial bug-filled release. We purposely left extra errors on here so
   you could email bug reports to Help@BrentOzar.com, thereby increasing
   your self-esteem. It's all about you.
*/


SELECT @Version = 9, @VersionDate = '20131103'

DECLARE @StringToExecute NVARCHAR(4000),
	@OurSessionID INT,
	@LineFeed NVARCHAR(10),
	@StockWarningHeader NVARCHAR(500),
	@StockWarningFooter NVARCHAR(100),
	@StockDetailsHeader NVARCHAR(100),
	@StockDetailsFooter NVARCHAR(100),
	@StartSampleTime DATETIME,
	@FinishSampleTime DATETIME;

/* Sanitize our inputs */
SELECT
	@OutputDatabaseName = QUOTENAME(@OutputDatabaseName),
	@OutputSchemaName = QUOTENAME(@OutputSchemaName),
	@OutputTableName = QUOTENAME(@OutputTableName),
	@LineFeed = CHAR(13) + CHAR(10),
	@StartSampleTime = GETDATE(),
	@FinishSampleTime = DATEADD(ss, @Seconds, GETDATE()),
	@OurSessionID = @@SPID;

IF @OutputType = 'SCHEMA'
BEGIN
	SELECT @Version AS Version,
	FieldList = '[Priority] TINYINT, [FindingsGroup] VARCHAR(50), [Finding] VARCHAR(200), [URL] VARCHAR(200), [Details] NVARCHAR(4000), [HowToStopIt] NVARCHAR(MAX), [QueryPlan] XML, [QueryText] NVARCHAR(MAX)'

END
ELSE IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL
BEGIN
	/* They want to look into the past. */

		SET @StringToExecute = N' IF EXISTS(SELECT * FROM '
			+ @OutputDatabaseName
			+ '.INFORMATION_SCHEMA.SCHEMATA WHERE QUOTENAME(SCHEMA_NAME) = '''
			+ @OutputSchemaName + ''') SELECT CheckDate, [Priority], [FindingsGroup], [Finding], [URL], CAST([Details] AS [XML]) AS Details,'
			+ '[HowToStopIt], [CheckID], [StartTime], [LoginName], [NTUserName], [OriginalLoginName], [ProgramName], [HostName], [DatabaseID],'
			+ '[DatabaseName], [OpenTransactionCount], [QueryPlan], [QueryText] FROM '
			+ @OutputDatabaseName + '.'
			+ @OutputSchemaName + '.'
			+ @OutputTableName
			+ ' WHERE CheckDate >= DATEADD(mi, -15, ''' + CAST(@AsOf AS NVARCHAR(100)) + ''')'
			+ ' AND CheckDate <= DATEADD(mi, 15, ''' + CAST(@AsOf AS NVARCHAR(100)) + ''')'
			+ ' /*ORDER BY CheckDate, Priority , FindingsGroup , Finding , Details*/;';
		EXEC(@StringToExecute);


END /* IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL */
ELSE IF @Question IS NULL /* IF @OutputType = 'SCHEMA' */
BEGIN


	/*
	We start by creating #AskBrentResults. It's a temp table that will storef
	the results from our checks. Throughout the rest of this stored procedure,
	we're running a series of checks looking for dangerous things inside the SQL
	Server. When we find a problem, we insert rows into #BlitzResults. At the
	end, we return these results to the end user.

	#AskBrentResults has a CheckID field, but there's no Check table. As we do
	checks, we insert data into this table, and we manually put in the CheckID.
	We (Brent Ozar Unlimited) maintain a list of the checks by ID#. You can
	download that from http://www.BrentOzar.com/askbrent/documentation/ if you
	want to build a tool that relies on the output of sp_AskBrent.
	*/

	IF OBJECT_ID('tempdb..#AskBrentResults') IS NOT NULL 
		DROP TABLE #AskBrentResults;
	CREATE TABLE #AskBrentResults
		(
		  ID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
		  CheckID INT NOT NULL,
		  Priority TINYINT NOT NULL,
		  FindingsGroup VARCHAR(50) NOT NULL,
		  Finding VARCHAR(200) NOT NULL,
		  URL VARCHAR(200) NOT NULL,
		  Details NVARCHAR(4000) NULL,
		  HowToStopIt [XML] NULL,
		  QueryPlan [XML] NULL,
		  QueryText NVARCHAR(MAX) NULL,
		  StartTime DATETIME NULL,
		  LoginName NVARCHAR(128) NULL,
		  NTUserName NVARCHAR(128) NULL,
		  OriginalLoginName NVARCHAR(128) NULL,
		  ProgramName NVARCHAR(128) NULL,
		  HostName NVARCHAR(128) NULL,
		  DatabaseID INT NULL,
		  DatabaseName NVARCHAR(128) NULL,
		  OpenTransactionCount INT NULL
		);

	IF OBJECT_ID('tempdb..#WaitStats') IS NOT NULL 
		DROP TABLE #WaitStats;
	CREATE TABLE #WaitStats (Pass TINYINT NOT NULL, wait_type NVARCHAR(60), wait_time_ms BIGINT, signal_wait_time_ms BIGINT, waiting_tasks_count BIGINT, SampleTime DATETIME);

	IF OBJECT_ID('tempdb..#FileStats') IS NOT NULL 
		DROP TABLE #FileStats;
	CREATE TABLE #FileStats ( 
		ID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
		Pass TINYINT NOT NULL,
		SampleTime DATETIME NOT NULL,
		DatabaseID INT NOT NULL,
		FileID INT NOT NULL,
		DatabaseName NVARCHAR(256) ,
		FileLogicalName NVARCHAR(256) ,
		TypeDesc NVARCHAR(60) ,
		SizeOnDiskMB BIGINT ,
		io_stall_read_ms BIGINT ,
		num_of_reads BIGINT ,
		bytes_read BIGINT ,
		io_stall_write_ms BIGINT ,
		num_of_writes BIGINT ,
		bytes_written BIGINT, 
		PhysicalName NVARCHAR(520) ,
		avg_stall_read_ms INT ,
		avg_stall_write_ms INT
	);

	IF OBJECT_ID('tempdb..#QueryStats') IS NOT NULL 
		DROP TABLE #QueryStats;
	CREATE TABLE #QueryStats ( 
		ID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
		Pass TINYINT NOT NULL,
		SampleTime DATETIME NOT NULL,
		[sql_handle] VARBINARY(64),
		statement_start_offset INT,
		statement_end_offset INT,
		plan_generation_num BIGINT,
		plan_handle VARBINARY(64),
		execution_count BIGINT,
		total_worker_time BIGINT,
		total_physical_reads BIGINT,
		total_logical_writes BIGINT,
		total_logical_reads BIGINT,
		total_clr_time BIGINT,
		total_elapsed_time BIGINT,
		creation_time DATETIME,
		query_hash BINARY(8),
		query_plan_hash BINARY(8),
		Points TINYINT
	);

	IF OBJECT_ID('tempdb..#PerfmonStats') IS NOT NULL 
		DROP TABLE #PerfmonStats;
	CREATE TABLE #PerfmonStats ( 
		ID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
		Pass TINYINT NOT NULL,
		SampleTime DATETIME NOT NULL,
		[object_name] NVARCHAR(128) NOT NULL,
		[counter_name] NVARCHAR(128) NOT NULL,
		[instance_name] NVARCHAR(128) NULL,
		[cntr_value] BIGINT NULL,
		[cntr_type] INT NOT NULL,
		[value_delta] BIGINT NULL,
		[value_per_second] DECIMAL(18,2) NULL
	);

	IF OBJECT_ID('tempdb..#PerfmonCounters') IS NOT NULL 
		DROP TABLE #PerfmonCounters;
	CREATE TABLE #PerfmonCounters ( 
		ID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
		[object_name] NVARCHAR(128) NOT NULL,
		[counter_name] NVARCHAR(128) NOT NULL,
		[instance_name] NVARCHAR(128) NULL
	);

	SET @StockWarningHeader = '<?ClickToSeeCommmand -- ' + @LineFeed + @LineFeed 
		+ 'WARNING: Running this command may result in data loss or an outage.' + @LineFeed
		+ 'This tool is meant as a shortcut to help generate scripts for DBAs.' + @LineFeed
		+ 'It is not a substitute for database training and experience.' + @LineFeed
		+ 'Now, having said that, here''s the details:' + @LineFeed + @LineFeed;

	SELECT @StockWarningFooter = @LineFeed + @LineFeed + '-- ?>',
		@StockDetailsHeader = '<?ClickToSeeDetails -- ' + @LineFeed,
		@StockDetailsFooter = @LineFeed + ' -- ?>';

	/* Build a list of queries that were run in the last 10 seconds.
	   We're looking for the death-by-a-thousand-small-cuts scenario
	   where a query is constantly running, and it doesn't have that
	   big of an impact individually, but it has a ton of impact
	   overall. We're going to build this list, and then after we
	   finish our @Seconds sample, we'll compare our plan cache to
	   this list to see what ran the most. */

	/* Populate #QueryStats. SQL 2005 doesn't have query hash or query plan hash. */
	IF @@VERSION LIKE 'Microsoft SQL Server 2005%'
		SET @StringToExecute = N'INSERT INTO #QueryStats ([sql_handle], Pass, SampleTime, statement_start_offset, statement_end_offset, plan_generation_num, plan_handle, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time, query_hash, query_plan_hash, Points)
									SELECT [sql_handle], 1 AS Pass, GETDATE(), statement_start_offset, statement_end_offset, plan_generation_num, plan_handle, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time, NULL AS query_hash, NULL AS query_plan_hash, 0
									FROM sys.dm_exec_query_stats qs
									WHERE qs.last_execution_time >= (DATEADD(ss, -10, GETDATE()));';
	ELSE
		SET @StringToExecute = N'INSERT INTO #QueryStats ([sql_handle], Pass, SampleTime, statement_start_offset, statement_end_offset, plan_generation_num, plan_handle, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time, query_hash, query_plan_hash, Points)
									SELECT [sql_handle], 1 AS Pass, GETDATE(), statement_start_offset, statement_end_offset, plan_generation_num, plan_handle, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time, query_hash, query_plan_hash, 0
									FROM sys.dm_exec_query_stats qs
									WHERE qs.last_execution_time >= (DATEADD(ss, -10, GETDATE()));';
	EXEC(@StringToExecute);

	IF EXISTS (SELECT * 
					FROM tempdb.sys.all_objects obj
					INNER JOIN tempdb.sys.all_columns col1 ON obj.object_id = col1.object_id AND col1.name = 'object_name'
					INNER JOIN tempdb.sys.all_columns col2 ON obj.object_id = col2.object_id AND col2.name = 'counter_name'
					INNER JOIN tempdb.sys.all_columns col3 ON obj.object_id = col3.object_id AND col3.name = 'instance_name'
					WHERE obj.name LIKE '%CustomPerfmonCounters%') 
		BEGIN
		SET @StringToExecute = 'INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) SELECT [object_name],[counter_name],[instance_name] FROM #CustomPerfmonCounters'
		EXEC(@StringToExecute);
		END
	ELSE
		BEGIN
		/* Add our default Perfmon counters */
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Access Methods','Forwarded Records/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Access Methods','Page compression attempts/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Access Methods','Page Splits/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Access Methods','Skipped Ghosted Records/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Access Methods','Table Lock Escalations/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Access Methods','Worktables Created/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Buffer Manager','Page life expectancy', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Buffer Manager','Page reads/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Buffer Manager','Page writes/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Buffer Manager','Readahead pages/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Buffer Manager','Target pages', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Buffer Manager','Total pages', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Databases','', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Buffer Manager','Active Transactions','_Total')
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Databases','Log Growths', '_Total')
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Databases','Log Shrinks', '_Total')
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Exec Statistics','Distributed Query', 'Execs in progress')
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Exec Statistics','DTC calls', 'Execs in progress')
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Exec Statistics','Extended Procedures', 'Execs in progress')
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Exec Statistics','OLEDB calls', 'Execs in progress')
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:General Statistics','Active Temp Tables', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:General Statistics','Logins/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:General Statistics','Logouts/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:General Statistics','Mars Deadlocks', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:General Statistics','Processes blocked', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Locks','Number of Deadlocks/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:Memory Manager','Memory Grants Pending', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:SQL Errors','Errors/sec', '_Total')
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:SQL Statistics','Batch Requests/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:SQL Statistics','Forced Parameterizations/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:SQL Statistics','Guided plan executions/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:SQL Statistics','SQL Attention rate', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:SQL Statistics','SQL Compilations/sec', NULL)
		INSERT INTO #PerfmonCounters ([object_name],[counter_name],[instance_name]) VALUES ('SQLServer:SQL Statistics','SQL Re-Compilations/sec', NULL)
		END

	/* Populate #FileStats, #PerfmonStats, #WaitStats with DMV data. 
		After we finish doing our checks, we'll take another sample and compare them. */
	INSERT #WaitStats(Pass, SampleTime, wait_type, wait_time_ms, signal_wait_time_ms, waiting_tasks_count)
	SELECT
		1 AS Pass,
		GETDATE() AS SampleTime,
		os.wait_type,
		SUM(os.wait_time_ms) OVER (PARTITION BY os.wait_type) as sum_wait_time_ms,
		SUM(os.signal_wait_time_ms) OVER (PARTITION BY os.wait_type ) as sum_signal_wait_time_ms,
		SUM(os.waiting_tasks_count) OVER (PARTITION BY os.wait_type) AS sum_waiting_tasks
	FROM sys.dm_os_wait_stats os
	WHERE
		os.wait_type not in (
			'REQUEST_FOR_DEADLOCK_SEARCH',
			'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
			'SQLTRACE_BUFFER_FLUSH',
			'LAZYWRITER_SLEEP',
			'XE_TIMER_EVENT',
			'XE_DISPATCHER_WAIT',
			'FT_IFTS_SCHEDULER_IDLE_WAIT',
			'LOGMGR_QUEUE',
			'CHECKPOINT_QUEUE',
			'BROKER_TO_FLUSH',
			'BROKER_TASK_STOP',
			'BROKER_EVENTHANDLER',
			'SLEEP_TASK',
			'WAITFOR',
			'DBMIRROR_DBM_MUTEX',
			'DBMIRROR_EVENTS_QUEUE',
			'DBMIRRORING_CMD',
			'DISPATCHER_QUEUE_SEMAPHORE',
			'BROKER_RECEIVE_WAITFOR',
			'CLR_AUTO_EVENT',
			'DIRTY_PAGE_POLL',
			'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
			'ONDEMAND_TASK_QUEUE',
			'FT_IFTSHC_MUTEX',
			'CLR_MANUAL_EVENT',
			'SP_SERVER_DIAGNOSTICS_SLEEP',
			'HADR_CLUSAPI_CALL',
			'HADR_LOGCAPTURE_WAIT',
			'HADR_TIMER_TASK',
			'HADR_WORK_QUEUE'
		)
	ORDER BY sum_wait_time_ms DESC;


	INSERT INTO #FileStats (Pass, SampleTime, DatabaseID, FileID, DatabaseName, FileLogicalName, SizeOnDiskMB, io_stall_read_ms ,
		num_of_reads, [bytes_read] , io_stall_write_ms,num_of_writes, [bytes_written], PhysicalName, TypeDesc)
	SELECT 
		1 AS Pass,
		GETDATE() AS SampleTime,
		mf.[database_id],
		mf.[file_id],
		DB_NAME(vfs.database_id) AS [db_name], 
		mf.name + N' [' + mf.type_desc COLLATE SQL_Latin1_General_CP1_CI_AS + N']' AS file_logical_name ,
		CAST(( ( vfs.size_on_disk_bytes / 1024.0 ) / 1024.0 ) AS INT) AS size_on_disk_mb ,
		vfs.io_stall_read_ms ,
		vfs.num_of_reads ,
		vfs.[num_of_bytes_read],
		vfs.io_stall_write_ms ,
		vfs.num_of_writes ,
		vfs.[num_of_bytes_written],
		mf.physical_name,
		mf.type_desc
	FROM sys.dm_io_virtual_file_stats (NULL, NULL) AS vfs
	INNER JOIN sys.master_files AS mf ON vfs.file_id = mf.file_id
		AND vfs.database_id = mf.database_id
	WHERE vfs.num_of_reads > 0
		OR vfs.num_of_writes > 0;

	INSERT INTO #PerfmonStats (Pass, SampleTime, [object_name],[counter_name],[instance_name],[cntr_value],[cntr_type])
	SELECT 		1 AS Pass,
		GETDATE() AS SampleTime, RTRIM(dmv.object_name), RTRIM(dmv.counter_name), RTRIM(dmv.instance_name), dmv.cntr_value, dmv.cntr_type
		FROM #PerfmonCounters counters
		INNER JOIN sys.dm_os_performance_counters dmv ON counters.counter_name = RTRIM(dmv.counter_name)
			AND counters.[object_name] = RTRIM(dmv.[object_name])
			AND (counters.[instance_name] IS NULL OR counters.[instance_name] = RTRIM(dmv.[instance_name]))

	/* Maintenance Tasks Running - Backup Running - CheckID 1 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, StartTime, LoginName, NTUserName, ProgramName, HostName, DatabaseID, DatabaseName, OpenTransactionCount)
	SELECT 1 AS CheckID,
		1 AS Priority,
		'Maintenance Tasks Running' AS FindingGroup,
		'Backup Running' AS Finding,
		'http://BrentOzar.com/askbrent/backups/' AS URL,
		@StockDetailsHeader + 'Backup of ' + DB_NAME(db.resource_database_id) + ' database (' + (SELECT CAST(CAST(SUM(size * 8.0 / 1024 / 1024) AS BIGINT) AS NVARCHAR) FROM sys.master_files WHERE database_id = db.resource_database_id) + 'GB) is ' + CAST(r.percent_complete AS NVARCHAR(100)) + '% complete, has been running since ' + CAST(r.start_time AS NVARCHAR(100)) + '. ' AS Details,
		CAST(@StockWarningHeader + 'KILL ' + CAST(r.session_id AS NVARCHAR(100)) + ';' + @StockWarningFooter AS XML) AS HowToStopIt,
		pl.query_plan AS QueryPlan,
		r.start_time AS StartTime,
		s.login_name AS LoginName,
		s.nt_user_name AS NTUserName,
		s.[program_name] AS ProgramName,
		s.[host_name] AS HostName,
		db.[resource_database_id] AS DatabaseID,
		DB_NAME(db.resource_database_id) AS DatabaseName,
		0 AS OpenTransactionCount
	FROM sys.dm_exec_requests r
	INNER JOIN sys.dm_exec_connections c ON r.session_id = c.session_id
	INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
	INNER JOIN (
	SELECT DISTINCT request_session_id, resource_database_id
	FROM    sys.dm_tran_locks
	WHERE resource_type = N'DATABASE'
	AND     request_mode = N'S'
	AND     request_status = N'GRANT'
	AND     request_owner_type = N'SHARED_TRANSACTION_WORKSPACE') AS db ON s.session_id = db.request_session_id
	CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) pl
	WHERE r.command LIKE 'BACKUP%';


	/* If there's a backup running, add details explaining how long full backup has been taking in the last month. */
	UPDATE #AskBrentResults
	SET Details = Details + ' Over the last 60 days, the full backup usually takes ' + CAST((SELECT AVG(DATEDIFF(mi, bs.backup_start_date, bs.backup_finish_date)) FROM msdb.dbo.backupset bs WHERE abr.DatabaseName = bs.database_name AND bs.type = 'D' AND bs.backup_start_date > DATEADD(dd, -60, GETDATE()) AND bs.backup_finish_date IS NOT NULL) AS NVARCHAR(100)) + ' minutes.'
	FROM #AskBrentResults abr
	WHERE abr.CheckID = 1 AND EXISTS (SELECT * FROM msdb.dbo.backupset bs WHERE bs.type = 'D' AND bs.backup_start_date > DATEADD(dd, -60, GETDATE()) AND bs.backup_finish_date IS NOT NULL AND abr.DatabaseName = bs.database_name AND DATEDIFF(mi, bs.backup_start_date, bs.backup_finish_date) > 1)



	/* Maintenance Tasks Running - DBCC Running - CheckID 2 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, StartTime, LoginName, NTUserName, ProgramName, HostName, DatabaseID, DatabaseName, OpenTransactionCount)
	SELECT 2 AS CheckID,
		1 AS Priority,
		'Maintenance Tasks Running' AS FindingGroup,
		'DBCC Running' AS Finding,
		'http://BrentOzar.com/askbrent/dbcc/' AS URL,
		@StockDetailsHeader + 'Corruption check of ' + DB_NAME(db.resource_database_id) + ' database (' + (SELECT CAST(CAST(SUM(size * 8.0 / 1024 / 1024) AS BIGINT) AS NVARCHAR) FROM sys.master_files WHERE database_id = db.resource_database_id) + 'GB) has been running since ' + CAST(r.start_time AS NVARCHAR(100)) + '. ' AS Details,
		CAST(@StockWarningHeader + 'KILL ' + CAST(r.session_id AS NVARCHAR(100)) + ';' + @StockWarningFooter AS XML) AS HowToStopIt,
		pl.query_plan AS QueryPlan,
		r.start_time AS StartTime,
		s.login_name AS LoginName,
		s.nt_user_name AS NTUserName,
		s.[program_name] AS ProgramName,
		s.[host_name] AS HostName,
		db.[resource_database_id] AS DatabaseID,
		DB_NAME(db.resource_database_id) AS DatabaseName,
		0 AS OpenTransactionCount
	FROM sys.dm_exec_requests r
	INNER JOIN sys.dm_exec_connections c ON r.session_id = c.session_id
	INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
	INNER JOIN (SELECT DISTINCT l.request_session_id, l.resource_database_id
	FROM    sys.dm_tran_locks l
	INNER JOIN sys.databases d ON l.resource_database_id = d.database_id
	WHERE l.resource_type = N'DATABASE'
	AND     l.request_mode = N'S'
	AND    l.request_status = N'GRANT'
	AND    l.request_owner_type = N'SHARED_TRANSACTION_WORKSPACE') AS db ON s.session_id = db.request_session_id
	CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) pl
	WHERE r.command LIKE 'DBCC%';


	/* Maintenance Tasks Running - Restore Running - CheckID 3 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, StartTime, LoginName, NTUserName, ProgramName, HostName, DatabaseID, DatabaseName, OpenTransactionCount)
	SELECT 3 AS CheckID,
		1 AS Priority,
		'Maintenance Tasks Running' AS FindingGroup,
		'Restore Running' AS Finding,
		'http://BrentOzar.com/askbrent/backups/' AS URL,
		@StockDetailsHeader + 'Restore of ' + DB_NAME(db.resource_database_id) + ' database (' + (SELECT CAST(CAST(SUM(size * 8.0 / 1024 / 1024) AS BIGINT) AS NVARCHAR) FROM sys.master_files WHERE database_id = db.resource_database_id) + 'GB) is ' + CAST(r.percent_complete AS NVARCHAR(100)) + '% complete, has been running since ' + CAST(r.start_time AS NVARCHAR(100)) + '. ' AS Details,
		CAST(@StockWarningHeader + 'KILL ' + CAST(r.session_id AS NVARCHAR(100)) + ';' + @StockWarningFooter AS XML) AS HowToStopIt,
		pl.query_plan AS QueryPlan,
		r.start_time AS StartTime,
		s.login_name AS LoginName,
		s.nt_user_name AS NTUserName,
		s.[program_name] AS ProgramName,
		s.[host_name] AS HostName,
		db.[resource_database_id] AS DatabaseID,
		DB_NAME(db.resource_database_id) AS DatabaseName,
		0 AS OpenTransactionCount
	FROM sys.dm_exec_requests r
	INNER JOIN sys.dm_exec_connections c ON r.session_id = c.session_id
	INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
	INNER JOIN (
	SELECT DISTINCT request_session_id, resource_database_id
	FROM    sys.dm_tran_locks
	WHERE resource_type = N'DATABASE'
	AND     request_mode = N'S'
	AND     request_status = N'GRANT'
	AND     request_owner_type = N'SHARED_TRANSACTION_WORKSPACE') AS db ON s.session_id = db.request_session_id
	CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) pl
	WHERE r.command LIKE 'RESTORE%';


	/* SQL Server Internal Maintenance - Database File Growing - CheckID 4 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, StartTime, LoginName, NTUserName, ProgramName, HostName, DatabaseID, DatabaseName, OpenTransactionCount)
	SELECT 4 AS CheckID,
		1 AS Priority,
		'SQL Server Internal Maintenance' AS FindingGroup,
		'Database File Growing' AS Finding,
		'http://BrentOzar.com/go/instant' AS URL,
		@StockDetailsHeader + 'SQL Server is waiting for Windows to provide storage space for a database restore, a data file growth, or a log file growth. This task has been running since ' + CAST(r.start_time AS NVARCHAR(100)) + '.' + @LineFeed + 'Check the query plan (expert mode) to identify the database involved.' AS Details,
		CAST(@StockWarningHeader + 'Unfortunately, you can''t stop this, but you can prevent it next time. Check out http://BrentOzar.com/go/instant for details.' + @StockWarningFooter AS XML) AS HowToStopIt,
		pl.query_plan AS QueryPlan,
		r.start_time AS StartTime,
		s.login_name AS LoginName,
		s.nt_user_name AS NTUserName,
		s.[program_name] AS ProgramName,
		s.[host_name] AS HostName,
		NULL AS DatabaseID,
		NULL AS DatabaseName,
		0 AS OpenTransactionCount
	FROM sys.dm_os_waiting_tasks t
	INNER JOIN sys.dm_exec_connections c ON t.session_id = c.session_id
	INNER JOIN sys.dm_exec_requests r ON t.session_id = r.session_id
	INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
	CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) pl
	WHERE t.wait_type = 'PREEMPTIVE_OS_WRITEFILEGATHER'


	/* Query Problems - Long-Running Query Blocking Others - CheckID 5 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, QueryText, StartTime, LoginName, NTUserName, ProgramName, HostName, DatabaseID, DatabaseName, OpenTransactionCount)
	SELECT 5 AS CheckID,
		1 AS Priority,
		'Query Problems' AS FindingGroup,
		'Long-Running Query Blocking Others' AS Finding,
		'http://BrentOzar.com/go/blocking' AS URL,
		@StockDetailsHeader + 'Query in ' + DB_NAME(db.resource_database_id) + ' has been running since ' + CAST(r.start_time AS NVARCHAR(100)) + '. ' + @LineFeed + @LineFeed
			+ CAST(COALESCE((SELECT TOP 1 [text] FROM sys.dm_exec_sql_text(rBlocker.sql_handle)),
			(SELECT TOP 1 [text] FROM master..sysprocesses spBlocker CROSS APPLY ::fn_get_sql(spBlocker.sql_handle) WHERE spBlocker.spid = tBlocked.blocking_session_id), '') AS NVARCHAR(2000)) AS Details,
		CAST(@StockWarningHeader + 'KILL ' + CAST(tBlocked.blocking_session_id AS NVARCHAR(100)) + ';' + @StockWarningFooter AS XML) AS HowToStopIt,
		(SELECT TOP 1 query_plan FROM sys.dm_exec_query_plan(rBlocker.plan_handle)) AS QueryPlan,
		COALESCE((SELECT TOP 1 [text] FROM sys.dm_exec_sql_text(rBlocker.sql_handle)),
			(SELECT TOP 1 [text] FROM master..sysprocesses spBlocker CROSS APPLY ::fn_get_sql(spBlocker.sql_handle) WHERE spBlocker.spid = tBlocked.blocking_session_id)) AS QueryText,
		r.start_time AS StartTime,
		s.login_name AS LoginName,
		s.nt_user_name AS NTUserName,
		s.[program_name] AS ProgramName,
		s.[host_name] AS HostName,
		db.[resource_database_id] AS DatabaseID,
		DB_NAME(db.resource_database_id) AS DatabaseName,
		0 AS OpenTransactionCount
	FROM sys.dm_exec_sessions s
	INNER JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
	INNER JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
	INNER JOIN sys.dm_os_waiting_tasks tBlocked ON tBlocked.session_id = s.session_id AND tBlocked.session_id <> s.session_id
	INNER JOIN (
	SELECT DISTINCT request_session_id, resource_database_id
	FROM    sys.dm_tran_locks
	WHERE resource_type = N'DATABASE'
	AND     request_mode = N'S'
	AND     request_status = N'GRANT'
	AND     request_owner_type = N'SHARED_TRANSACTION_WORKSPACE') AS db ON s.session_id = db.request_session_id
	LEFT OUTER JOIN sys.dm_exec_requests rBlocker ON tBlocked.blocking_session_id = rBlocker.session_id
	  WHERE NOT EXISTS (SELECT * FROM sys.dm_os_waiting_tasks tBlocker WHERE tBlocker.session_id = tBlocked.blocking_session_id AND tBlocker.blocking_session_id IS NOT NULL)
	  AND s.last_request_start_time < DATEADD(SECOND, -30, GETDATE())

	/* Query Problems - Plan Cache Erased Recently */
	IF DATEADD(mi, -15, GETDATE()) < (SELECT TOP 1 creation_time FROM sys.dm_exec_query_stats ORDER BY creation_time)
	BEGIN
		INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt)
		SELECT TOP 1 7 AS CheckID,
			50 AS Priority,
			'Query Problems' AS FindingGroup,
			'Plan Cache Erased Recently' AS Finding,
			'http://BrentOzar.com/askbrent/plan-cache-erased-recently/' AS URL,
			@StockDetailsHeader + 'The oldest query in the plan cache was created at ' + CAST(creation_time AS NVARCHAR(50)) + '. ' + @LineFeed + @LineFeed
				+ 'This indicates that someone ran DBCC FREEPROCCACHE at that time,' + @LineFeed
				+ 'Giving SQL Server temporary amnesia. Now, as queries come in,' + @LineFeed
				+ 'SQL Server has to use a lot of CPU power in order to build execution' + @LineFeed
				+ 'plans and put them in cache again. This causes high CPU loads.' AS Details,
			CAST(@StockWarningHeader + 'Find who did that, and stop them from doing it again.' + @StockWarningFooter AS XML) AS HowToStopIt
		FROM sys.dm_exec_query_stats 
		ORDER BY creation_time	
	END;


	/* Query Problems - Sleeping Query with Open Transactions - CheckID 8 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, StartTime, LoginName, NTUserName, ProgramName, HostName, DatabaseID, DatabaseName, QueryText, OpenTransactionCount)
	SELECT 8 AS CheckID,
		50 AS Priority,
		'Query Problems' AS FindingGroup,
		'Sleeping Query with Open Transactions' AS Finding,
		'http://www.brentozar.com/askbrent/sleeping-query-with-open-transactions/' AS URL,
		@StockDetailsHeader + 'Database: ' + DB_NAME(db.resource_database_id) + @LineFeed + 'Host: ' + s.[host_name] + @LineFeed + 'Program: ' + s.[program_name] + @LineFeed + 'Asleep with open transactions and locks since ' + CAST(s.last_request_end_time AS NVARCHAR(100)) + '. ' AS Details,
		CAST(@StockWarningHeader + 'KILL ' + CAST(s.session_id AS NVARCHAR(100)) + ';' + @StockWarningFooter AS XML) AS HowToStopIt,
		s.last_request_start_time AS StartTime,
		s.login_name AS LoginName,
		s.nt_user_name AS NTUserName,
		s.[program_name] AS ProgramName,
		s.[host_name] AS HostName,
		db.[resource_database_id] AS DatabaseID,
		DB_NAME(db.resource_database_id) AS DatabaseName,
		(SELECT TOP 1 [text] FROM sys.dm_exec_sql_text(c.most_recent_sql_handle)) AS QueryText,
		sessions_with_transactions.open_transaction_count AS OpenTransactionCount
	FROM (SELECT session_id, SUM(open_transaction_count) AS open_transaction_count FROM sys.dm_exec_requests WHERE open_transaction_count > 0 GROUP BY session_id) AS sessions_with_transactions
	INNER JOIN sys.dm_exec_sessions s ON sessions_with_transactions.session_id = s.session_id
	INNER JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
	INNER JOIN (
	SELECT DISTINCT request_session_id, resource_database_id
	FROM    sys.dm_tran_locks
	WHERE resource_type = N'DATABASE'
	AND     request_mode = N'S'
	AND     request_status = N'GRANT'
	AND     request_owner_type = N'SHARED_TRANSACTION_WORKSPACE') AS db ON s.session_id = db.request_session_id
	WHERE s.status = 'sleeping'
	AND s.last_request_end_time < DATEADD(ss, -10, GETDATE())
	AND EXISTS(SELECT * FROM sys.dm_tran_locks WHERE request_session_id = s.session_id 
	AND NOT (resource_type = N'DATABASE' AND request_mode = N'S' AND request_status = N'GRANT' AND request_owner_type = N'SHARED_TRANSACTION_WORKSPACE'))


	/* Query Problems - Query Rolling Back - CheckID 9 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, StartTime, LoginName, NTUserName, ProgramName, HostName, DatabaseID, DatabaseName, QueryText)
	SELECT 9 AS CheckID,
		1 AS Priority,
		'Query Problems' AS FindingGroup,
		'Query Rolling Back' AS Finding,
		'http://BrentOzar.com/askbrent/rollback/' AS URL,
		@StockDetailsHeader + 'Rollback started at ' + CAST(r.start_time AS NVARCHAR(100)) + ', is ' + CAST(r.percent_complete AS NVARCHAR(100)) + '% complete.' AS Details,
		CAST(@StockWarningHeader + 'Unfortunately, you can''t stop this. Whatever you do, don''t restart the server in an attempt to fix it - SQL Server will keep rolling back.' + @StockWarningFooter AS XML) AS HowToStopIt,
		r.start_time AS StartTime,
		s.login_name AS LoginName,
		s.nt_user_name AS NTUserName,
		s.[program_name] AS ProgramName,
		s.[host_name] AS HostName,
		db.[resource_database_id] AS DatabaseID,
		DB_NAME(db.resource_database_id) AS DatabaseName,
		(SELECT TOP 1 [text] FROM sys.dm_exec_sql_text(c.most_recent_sql_handle)) AS QueryText
	FROM sys.dm_exec_sessions s 
	INNER JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
	INNER JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
	LEFT OUTER JOIN (
		SELECT DISTINCT request_session_id, resource_database_id
		FROM    sys.dm_tran_locks
		WHERE resource_type = N'DATABASE'
		AND     request_mode = N'S'
		AND     request_status = N'GRANT'
		AND     request_owner_type = N'SHARED_TRANSACTION_WORKSPACE') AS db ON s.session_id = db.request_session_id
	WHERE r.status = 'rollback'


	/* Server Performance - Page Life Expectancy Low - CheckID 10 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt)
	SELECT 10 AS CheckID,
		50 AS Priority,
		'Server Performance' AS FindingGroup,
		'Page Life Expectancy Low' AS Finding,
		'http://BrentOzar.com/askbrent/page-life-expectancy/' AS URL,
		@StockDetailsHeader + 'SQL Server Buffer Manager:Page life expectancy is ' + CAST(c.cntr_value AS NVARCHAR(10)) + ' seconds.' + @LineFeed 
			+ 'This means SQL Server can only keep data pages in memory for that many seconds after reading those pages in from storage.' + @LineFeed 
			+ 'This is a symptom, not a cause - it indicates very read-intensive queries that need an index, or insufficient server memory.' AS Details,
		CAST(@StockWarningHeader + 'Add more memory to the server, or find the queries reading a lot of data, and make them more efficient (or fix them with indexes).' + @StockWarningFooter AS XML) AS HowToStopIt
	FROM sys.dm_os_performance_counters c
	WHERE object_name LIKE 'SQLServer:Buffer Manager%'
	AND counter_name LIKE 'Page life expectancy%'
	AND cntr_value < 300



	/* End of checks. If we haven't waited @Seconds seconds, wait. */
	IF GETDATE() < @FinishSampleTime
		WAITFOR TIME @FinishSampleTime;


	/* Populate #FileStats, #PerfmonStats, #WaitStats with DMV data. In a second, we'll compare these. */
	INSERT #WaitStats(Pass, SampleTime, wait_type, wait_time_ms, signal_wait_time_ms, waiting_tasks_count)
	SELECT
		2 AS Pass,
		GETDATE() AS SampleTime,
		os.wait_type,
		SUM(os.wait_time_ms) OVER (PARTITION BY os.wait_type) as sum_wait_time_ms,
		SUM(os.signal_wait_time_ms) OVER (PARTITION BY os.wait_type ) as sum_signal_wait_time_ms,
		SUM(os.waiting_tasks_count) OVER (PARTITION BY os.wait_type) AS sum_waiting_tasks
	FROM sys.dm_os_wait_stats os
	WHERE
		os.wait_type not in (
			'REQUEST_FOR_DEADLOCK_SEARCH',
			'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
			'SQLTRACE_BUFFER_FLUSH',
			'LAZYWRITER_SLEEP',
			'XE_TIMER_EVENT',
			'XE_DISPATCHER_WAIT',
			'FT_IFTS_SCHEDULER_IDLE_WAIT',
			'LOGMGR_QUEUE',
			'CHECKPOINT_QUEUE',
			'BROKER_TO_FLUSH',
			'BROKER_TASK_STOP',
			'BROKER_EVENTHANDLER',
			'SLEEP_TASK',
			'WAITFOR',
			'DBMIRROR_DBM_MUTEX',
			'DBMIRROR_EVENTS_QUEUE',
			'DBMIRRORING_CMD',
			'DISPATCHER_QUEUE_SEMAPHORE',
			'BROKER_RECEIVE_WAITFOR',
			'CLR_AUTO_EVENT',
			'DIRTY_PAGE_POLL',
			'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
			'ONDEMAND_TASK_QUEUE',
			'FT_IFTSHC_MUTEX',
			'CLR_MANUAL_EVENT',
			'SP_SERVER_DIAGNOSTICS_SLEEP',
			'HADR_CLUSAPI_CALL',
			'HADR_LOGCAPTURE_WAIT',
			'HADR_TIMER_TASK',
			'HADR_WORK_QUEUE'
		)
	ORDER BY sum_wait_time_ms DESC;

	INSERT INTO #FileStats (Pass, SampleTime, DatabaseID, FileID, DatabaseName, FileLogicalName, SizeOnDiskMB, io_stall_read_ms ,
		num_of_reads, [bytes_read] , io_stall_write_ms,num_of_writes, [bytes_written], PhysicalName, TypeDesc, avg_stall_read_ms, avg_stall_write_ms)
	SELECT 		2 AS Pass,
		GETDATE() AS SampleTime,
		mf.[database_id],
		mf.[file_id],
		DB_NAME(vfs.database_id) AS [db_name], 
		mf.name + N' [' + mf.type_desc COLLATE SQL_Latin1_General_CP1_CI_AS + N']' AS file_logical_name ,
		CAST(( ( vfs.size_on_disk_bytes / 1024.0 ) / 1024.0 ) AS INT) AS size_on_disk_mb ,
		vfs.io_stall_read_ms ,
		vfs.num_of_reads ,
		vfs.[num_of_bytes_read],
		vfs.io_stall_write_ms ,
		vfs.num_of_writes ,
		vfs.[num_of_bytes_written],
		mf.physical_name,
		mf.type_desc,
		0,
		0
	FROM sys.dm_io_virtual_file_stats (NULL, NULL) AS vfs
	INNER JOIN sys.master_files AS mf ON vfs.file_id = mf.file_id
		AND vfs.database_id = mf.database_id
	WHERE vfs.num_of_reads > 0
		OR vfs.num_of_writes > 0;

	INSERT INTO #PerfmonStats (Pass, SampleTime, [object_name],[counter_name],[instance_name],[cntr_value],[cntr_type])
	SELECT 		2 AS Pass,
		GETDATE() AS SampleTime,
		RTRIM(dmv.object_name), RTRIM(dmv.counter_name), RTRIM(dmv.instance_name), dmv.cntr_value, dmv.cntr_type
		FROM #PerfmonCounters counters
		INNER JOIN sys.dm_os_performance_counters dmv ON counters.counter_name = RTRIM(dmv.counter_name)
			AND counters.[object_name] = RTRIM(dmv.[object_name])
			AND (counters.[instance_name] IS NULL OR counters.[instance_name] = RTRIM(dmv.[instance_name]))

	/* Set the latencies and averages. We could do this with a CTE, but we're not ambitious today. */
	UPDATE fNow
	SET avg_stall_read_ms = ((fNow.io_stall_read_ms - fBase.io_stall_read_ms) / (fNow.num_of_reads - fBase.num_of_reads))
	FROM #FileStats fNow
	INNER JOIN #FileStats fBase ON fNow.DatabaseID = fBase.DatabaseID AND fNow.FileID = fBase.FileID AND fNow.SampleTime > fBase.SampleTime AND fNow.num_of_reads > fBase.num_of_reads AND fNow.io_stall_read_ms > fBase.io_stall_read_ms
	WHERE (fNow.num_of_reads - fBase.num_of_reads) > 0

	UPDATE fNow
	SET avg_stall_write_ms = ((fNow.io_stall_write_ms - fBase.io_stall_write_ms) / (fNow.num_of_writes - fBase.num_of_writes))
	FROM #FileStats fNow
	INNER JOIN #FileStats fBase ON fNow.DatabaseID = fBase.DatabaseID AND fNow.FileID = fBase.FileID AND fNow.SampleTime > fBase.SampleTime AND fNow.num_of_writes > fBase.num_of_writes AND fNow.io_stall_write_ms > fBase.io_stall_write_ms
	WHERE (fNow.num_of_writes - fBase.num_of_writes) > 0

	UPDATE pNow
		SET [value_delta] = pNow.cntr_value - pFirst.cntr_value,
			[value_per_second] = ((1.0 * pNow.cntr_value - pFirst.cntr_value) / DATEDIFF(ss, pFirst.SampleTime, pNow.SampleTime)) 
		FROM #PerfmonStats pNow
			INNER JOIN #PerfmonStats pFirst ON pFirst.[object_name] = pNow.[object_name] AND pFirst.counter_name = pNow.counter_name AND (pFirst.instance_name = pNow.instance_name OR (pFirst.instance_name IS NULL AND pNow.instance_name IS NULL))
				AND pNow.ID > pFirst.ID;


	/* If we're within 10 seconds of our projected finish time, do the plan cache analysis. */
	IF DATEDIFF(ss, @FinishSampleTime, GETDATE()) > 10 AND @ExpertMode = 0
		BEGIN
		
			INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details)
			VALUES (18, 210, 'Query Stats', 'Plan Cache Analysis Skipped', 'http://BrentOzar.com/go/topqueries',
				@StockDetailsHeader + 'Due to excessive load, the plan cache analysis was skipped. To override this, use @ExpertMode = 1.')
		
		END
	ELSE /* IF DATEDIFF(ss, @FinishSampleTime, GETDATE()) > 10 AND @ExpertMode = 0 */
		BEGIN


		/* Populate #QueryStats. SQL 2005 doesn't have query hash or query plan hash. */
		IF @@VERSION LIKE 'Microsoft SQL Server 2005%'
			SET @StringToExecute = N'INSERT INTO #QueryStats ([sql_handle], Pass, SampleTime, statement_start_offset, statement_end_offset, plan_generation_num, plan_handle, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time, query_hash, query_plan_hash, Points)
										SELECT [sql_handle], 2 AS Pass, GETDATE(), statement_start_offset, statement_end_offset, plan_generation_num, plan_handle, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time, NULL AS query_hash, NULL AS query_plan_hash, 0
										FROM sys.dm_exec_query_stats qs
										WHERE qs.last_execution_time >= ''' + CAST(@StartSampleTime AS NVARCHAR(100)) + ''';';
		ELSE
			SET @StringToExecute = N'INSERT INTO #QueryStats ([sql_handle], Pass, SampleTime, statement_start_offset, statement_end_offset, plan_generation_num, plan_handle, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time, query_hash, query_plan_hash, Points)
										SELECT [sql_handle], 2 AS Pass, GETDATE(), statement_start_offset, statement_end_offset, plan_generation_num, plan_handle, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time, query_hash, query_plan_hash, 0
										FROM sys.dm_exec_query_stats qs
										WHERE qs.last_execution_time >= ''' + CAST(@StartSampleTime AS NVARCHAR(100)) + ''';';
		EXEC(@StringToExecute);

		/* Get the totals for the entire plan cache */
		INSERT INTO #QueryStats (Pass, SampleTime, execution_count, total_worker_time, total_physical_reads, total_logical_writes, total_logical_reads, total_clr_time, total_elapsed_time, creation_time)
		SELECT 0 AS Pass, GETDATE(), SUM(execution_count), SUM(total_worker_time), SUM(total_physical_reads), SUM(total_logical_writes), SUM(total_logical_reads), SUM(total_clr_time), SUM(total_elapsed_time), MIN(creation_time)
			FROM sys.dm_exec_query_stats qs;

		/* 
		Pick the most resource-intensive queries to review. Update the Points field
		in #QueryStats - if a query is in the top 10 for logical reads, CPU time,
		duration, or execution, add 1 to its points.
		*/
		WITH qsTop AS (
		SELECT TOP 10 qsNow.ID
		FROM #QueryStats qsNow
		  INNER JOIN #QueryStats qsFirst ON qsNow.[sql_handle] = qsFirst.[sql_handle] AND qsNow.statement_start_offset = qsFirst.statement_start_offset AND qsNow.statement_end_offset = qsFirst.statement_end_offset AND qsNow.plan_generation_num = qsFirst.plan_generation_num AND qsNow.plan_handle = qsFirst.plan_handle AND qsFirst.Pass = 1
		WHERE qsNow.total_elapsed_time > qsFirst.total_elapsed_time
			AND qsNow.Pass = 2
		ORDER BY (qsNow.total_elapsed_time - COALESCE(qsFirst.total_elapsed_time, 0)) DESC)
		UPDATE #QueryStats
			SET Points = Points + 1
			FROM #QueryStats qs
			INNER JOIN qsTop ON qs.ID = qsTop.ID;

		WITH qsTop AS (
		SELECT TOP 10 qsNow.ID
		FROM #QueryStats qsNow
		  INNER JOIN #QueryStats qsFirst ON qsNow.[sql_handle] = qsFirst.[sql_handle] AND qsNow.statement_start_offset = qsFirst.statement_start_offset AND qsNow.statement_end_offset = qsFirst.statement_end_offset AND qsNow.plan_generation_num = qsFirst.plan_generation_num AND qsNow.plan_handle = qsFirst.plan_handle AND qsFirst.Pass = 1
		WHERE qsNow.total_logical_reads > qsFirst.total_logical_reads
			AND qsNow.Pass = 2
		ORDER BY (qsNow.total_logical_reads - COALESCE(qsFirst.total_logical_reads, 0)) DESC)
		UPDATE #QueryStats
			SET Points = Points + 1
			FROM #QueryStats qs
			INNER JOIN qsTop ON qs.ID = qsTop.ID;

		WITH qsTop AS (
		SELECT TOP 10 qsNow.ID
		FROM #QueryStats qsNow
		  INNER JOIN #QueryStats qsFirst ON qsNow.[sql_handle] = qsFirst.[sql_handle] AND qsNow.statement_start_offset = qsFirst.statement_start_offset AND qsNow.statement_end_offset = qsFirst.statement_end_offset AND qsNow.plan_generation_num = qsFirst.plan_generation_num AND qsNow.plan_handle = qsFirst.plan_handle AND qsFirst.Pass = 1
		WHERE qsNow.total_worker_time > qsFirst.total_worker_time
			AND qsNow.Pass = 2
		ORDER BY (qsNow.total_worker_time - COALESCE(qsFirst.total_worker_time, 0)) DESC)
		UPDATE #QueryStats
			SET Points = Points + 1
			FROM #QueryStats qs
			INNER JOIN qsTop ON qs.ID = qsTop.ID;

		WITH qsTop AS (
		SELECT TOP 10 qsNow.ID
		FROM #QueryStats qsNow
		  INNER JOIN #QueryStats qsFirst ON qsNow.[sql_handle] = qsFirst.[sql_handle] AND qsNow.statement_start_offset = qsFirst.statement_start_offset AND qsNow.statement_end_offset = qsFirst.statement_end_offset AND qsNow.plan_generation_num = qsFirst.plan_generation_num AND qsNow.plan_handle = qsFirst.plan_handle AND qsFirst.Pass = 1
		WHERE qsNow.execution_count > qsFirst.execution_count
			AND qsNow.Pass = 2
		ORDER BY (qsNow.execution_count - COALESCE(qsFirst.execution_count, 0)) DESC)
		UPDATE #QueryStats
			SET Points = Points + 1
			FROM #QueryStats qs
			INNER JOIN qsTop ON qs.ID = qsTop.ID;

		/* Query Stats - CheckID 17 - Most Resource-Intensive Queries */
		INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, QueryText)
		SELECT 17, 210, 'Query Stats', 'Most Resource-Intensive Queries', 'http://BrentOzar.com/go/topqueries',
			@StockDetailsHeader + 'Query stats during the sample:' + @LineFeed +
			'Executions: ' + CAST(qsNow.execution_count - (COALESCE(qsFirst.execution_count, 0)) AS NVARCHAR(100)) + @LineFeed +
			'Elapsed Time: ' + CAST(qsNow.total_elapsed_time - (COALESCE(qsFirst.total_elapsed_time, 0)) AS NVARCHAR(100)) + @LineFeed +
			'CPU Time: ' + CAST(qsNow.total_worker_time - (COALESCE(qsFirst.total_worker_time, 0)) AS NVARCHAR(100)) + @LineFeed +
			'Logical Reads: ' + CAST(qsNow.total_logical_reads - (COALESCE(qsFirst.total_logical_reads, 0)) AS NVARCHAR(100)) + @LineFeed +
			'Logical Writes: ' + CAST(qsNow.total_logical_writes - (COALESCE(qsFirst.total_logical_writes, 0)) AS NVARCHAR(100)) + @LineFeed +
			'CLR Time: ' + CAST(qsNow.total_clr_time - (COALESCE(qsFirst.total_clr_time, 0)) AS NVARCHAR(100)) + @LineFeed +
			@LineFeed + @LineFeed + 'Query stats since ' + CONVERT(NVARCHAR(100), qsNow.creation_time ,121) + @LineFeed +
			'Executions: ' + CAST(qsNow.execution_count AS NVARCHAR(100)) + 
					CASE qsTotal.execution_count WHEN 0 THEN '' ELSE (' - Percent of Server Total: ' + CAST(CAST(100.0 * qsNow.execution_count / qsTotal.execution_count AS DECIMAL(6,2)) AS NVARCHAR(100)) + '%') END + @LineFeed +
			'Elapsed Time: ' + CAST(qsNow.total_elapsed_time AS NVARCHAR(100)) + 
					CASE qsTotal.total_elapsed_time WHEN 0 THEN '' ELSE (' - Percent of Server Total: ' + CAST(CAST(100.0 * qsNow.total_elapsed_time / qsTotal.total_elapsed_time AS DECIMAL(6,2)) AS NVARCHAR(100)) + '%') END + @LineFeed +
			'CPU Time: ' + CAST(qsNow.total_worker_time AS NVARCHAR(100)) + 
					CASE qsTotal.total_worker_time WHEN 0 THEN '' ELSE (' - Percent of Server Total: ' + CAST(CAST(100.0 * qsNow.total_worker_time / qsTotal.total_worker_time AS DECIMAL(6,2)) AS NVARCHAR(100)) + '%') END + @LineFeed +
			'Logical Reads: ' + CAST(qsNow.total_logical_reads AS NVARCHAR(100)) +
					CASE qsTotal.total_logical_reads WHEN 0 THEN '' ELSE (' - Percent of Server Total: ' + CAST(CAST(100.0 * qsNow.total_logical_reads / qsTotal.total_logical_reads AS DECIMAL(6,2)) AS NVARCHAR(100)) + '%') END + @LineFeed +
			'Logical Writes: ' + CAST(qsNow.total_logical_writes AS NVARCHAR(100)) + 
					CASE qsTotal.total_logical_writes WHEN 0 THEN '' ELSE (' - Percent of Server Total: ' + CAST(CAST(100.0 * qsNow.total_logical_writes / qsTotal.total_logical_writes AS DECIMAL(6,2)) AS NVARCHAR(100)) + '%') END + @LineFeed +
			'CLR Time: ' + CAST(qsNow.total_clr_time AS NVARCHAR(100)) + 
					CASE qsTotal.total_clr_time WHEN 0 THEN '' ELSE (' - Percent of Server Total: ' + CAST(CAST(100.0 * qsNow.total_clr_time / qsTotal.total_clr_time AS DECIMAL(6,2)) AS NVARCHAR(100)) + '%') END + @LineFeed +
			--@LineFeed + @LineFeed + 'Query hash: ' + CAST(qsNow.query_hash AS NVARCHAR(100)) + @LineFeed +
			--@LineFeed + @LineFeed + 'Query plan hash: ' + CAST(qsNow.query_plan_hash AS NVARCHAR(100)) + 
			@LineFeed AS Details,
			CAST(@StockWarningHeader + 'See the URL for tuning tips on why this query may be consuming resources.' + @StockWarningFooter AS XML) AS HowToStopIt,
			qp.query_plan, st.text
			FROM #QueryStats qsNow
				INNER JOIN #QueryStats qsTotal ON qsTotal.Pass = 0
				LEFT OUTER JOIN #QueryStats qsFirst ON qsNow.[sql_handle] = qsFirst.[sql_handle] AND qsNow.statement_start_offset = qsFirst.statement_start_offset AND qsNow.statement_end_offset = qsFirst.statement_end_offset AND qsNow.plan_generation_num = qsFirst.plan_generation_num AND qsNow.plan_handle = qsFirst.plan_handle AND qsFirst.Pass = 1
				CROSS APPLY sys.dm_exec_sql_text(qsNow.sql_handle) AS st 
				CROSS APPLY sys.dm_exec_query_plan(qsNow.plan_handle) AS qp
			WHERE qsNow.Points > 0 AND st.text IS NOT NULL AND qp.query_plan IS NOT NULL

		END /* IF DATEDIFF(ss, @FinishSampleTime, GETDATE()) > 10 AND @ExpertMode = 0 */
	

	/* Wait Stats - CheckID 6 */
	/* Compare the current wait stats to the sample we took at the start, and insert the top 10 waits. */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt)
	SELECT TOP 10 6 AS CheckID,
		200 AS Priority,
		'Wait Stats' AS FindingGroup,
		wNow.wait_type AS Finding,
		N'http://www.brentozar.com/sql/wait-stats/#' + wNow.wait_type AS URL,
		@StockDetailsHeader + 'For ' + CAST(((wNow.wait_time_ms - COALESCE(wBase.wait_time_ms,0)) / 1000) AS NVARCHAR(100)) + ' seconds over the last ' + CAST(@Seconds AS NVARCHAR(10)) + ' seconds, SQL Server was waiting on this particular bottleneck.' + @LineFeed + @LineFeed AS Details,
		CAST(@StockWarningHeader + 'See the URL for more details on how to mitigate this wait type.' + @StockWarningFooter AS XML) AS HowToStopIt
	FROM #WaitStats wNow
	LEFT OUTER JOIN #WaitStats wBase ON wNow.wait_type = wBase.wait_type AND wNow.SampleTime > wBase.SampleTime
	WHERE wNow.wait_time_ms > (wBase.wait_time_ms + (.5 * @Seconds * 1000)) /* Only look for things we've actually waited on for half of the time or more */
	AND wNow.wait_type NOT IN ('REQUEST_FOR_DEADLOCK_SEARCH','SQLTRACE_INCREMENTAL_FLUSH_SLEEP','SQLTRACE_BUFFER_FLUSH',
	'LAZYWRITER_SLEEP','XE_TIMER_EVENT','XE_DISPATCHER_WAIT','FT_IFTS_SCHEDULER_IDLE_WAIT','LOGMGR_QUEUE','CHECKPOINT_QUEUE',
	'BROKER_TO_FLUSH','BROKER_TASK_STOP','BROKER_EVENTHANDLER','BROKER_TRANSMITTER','SLEEP_TASK','WAITFOR','DBMIRROR_DBM_MUTEX',
	'DBMIRROR_EVENTS_QUEUE','DBMIRRORING_CMD','DISPATCHER_QUEUE_SEMAPHORE','BROKER_RECEIVE_WAITFOR','CLR_AUTO_EVENT',
	'DIRTY_PAGE_POLL','CLR_SEMAPHORE','HADR_FILESTREAM_IOMGR_IOCOMPLETION','ONDEMAND_TASK_QUEUE','FT_IFTSHC_MUTEX',
	'CLR_MANUAL_EVENT','SP_SERVER_DIAGNOSTICS_SLEEP','DBMIRROR_WORKER_QUEUE','DBMIRROR_DBM_EVENT')
	ORDER BY (wNow.wait_time_ms - COALESCE(wBase.wait_time_ms,0)) DESC;

	/* Server Performance - Slow Data File Reads - CheckID 11 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, DatabaseID, DatabaseName)
	SELECT TOP 10 11 AS CheckID,
		50 AS Priority,
		'Server Performance' AS FindingGroup,
		'Slow Data File Reads' AS Finding,
		'http://BrentOzar.com/go/slow/' AS URL,
		@StockDetailsHeader + 'File: ' + fNow.PhysicalName + @LineFeed 
			+ 'Number of reads during the sample: ' + CAST((fNow.num_of_reads - fBase.num_of_reads) AS NVARCHAR(20)) + @LineFeed 
			+ 'Seconds spent waiting on storage for these reads: ' + CAST(((fNow.io_stall_read_ms - fBase.io_stall_read_ms) / 1000.0) AS NVARCHAR(20)) + @LineFeed 
			+ 'Average read latency during the sample: ' + CAST(((fNow.io_stall_read_ms - fBase.io_stall_read_ms) / (fNow.num_of_reads - fBase.num_of_reads) ) AS NVARCHAR(20)) + ' milliseconds' + @LineFeed 
			+ 'Microsoft guidance for data file read speed: 20ms or less.' + @LineFeed + @LineFeed AS Details,
		CAST(@StockWarningHeader + 'See the URL for more details on how to mitigate this wait type.' + @StockWarningFooter AS XML) AS HowToStopIt,
		fNow.DatabaseID,
		fNow.DatabaseName
	FROM #FileStats fNow
	INNER JOIN #FileStats fBase ON fNow.DatabaseID = fBase.DatabaseID AND fNow.FileID = fBase.FileID AND fNow.SampleTime > fBase.SampleTime AND fNow.num_of_reads > fBase.num_of_reads AND fNow.io_stall_read_ms > (fBase.io_stall_read_ms + 1000)
	WHERE (fNow.io_stall_read_ms - fBase.io_stall_read_ms) / (fNow.num_of_reads - fBase.num_of_reads) > 100
		AND fNow.TypeDesc = 'ROWS'
	ORDER BY (fNow.io_stall_read_ms - fBase.io_stall_read_ms) / (fNow.num_of_reads - fBase.num_of_reads) DESC;

	/* Server Performance - Slow Log File Writes - CheckID 12 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, DatabaseID, DatabaseName)
	SELECT TOP 10 12 AS CheckID,
		50 AS Priority,
		'Server Performance' AS FindingGroup,
		'Slow Log File Writes' AS Finding,
		'http://BrentOzar.com/go/slow/' AS URL,
		@StockDetailsHeader + 'File: ' + fNow.PhysicalName + @LineFeed 
			+ 'Number of writes during the sample: ' + CAST((fNow.num_of_writes - fBase.num_of_writes) AS NVARCHAR(20)) + @LineFeed 
			+ 'Seconds spent waiting on storage for these writes: ' + CAST(((fNow.io_stall_write_ms - fBase.io_stall_write_ms) / 1000.0) AS NVARCHAR(20)) + @LineFeed 
			+ 'Average write latency during the sample: ' + CAST(((fNow.io_stall_write_ms - fBase.io_stall_write_ms) / (fNow.num_of_writes - fBase.num_of_writes) ) AS NVARCHAR(20)) + ' milliseconds' + @LineFeed 
			+ 'Microsoft guidance for log file write speed: 3ms or less.' + @LineFeed + @LineFeed AS Details,
		CAST(@StockWarningHeader + 'See the URL for more details on how to mitigate this wait type.' + @StockWarningFooter AS XML) AS HowToStopIt,
		fNow.DatabaseID,
		fNow.DatabaseName
	FROM #FileStats fNow
	INNER JOIN #FileStats fBase ON fNow.DatabaseID = fBase.DatabaseID AND fNow.FileID = fBase.FileID AND fNow.SampleTime > fBase.SampleTime AND fNow.num_of_writes > fBase.num_of_writes AND fNow.io_stall_write_ms > (fBase.io_stall_write_ms + 1000)
	WHERE (fNow.io_stall_write_ms - fBase.io_stall_write_ms) / (fNow.num_of_writes - fBase.num_of_writes) > 100
		AND fNow.TypeDesc = 'LOG'
	ORDER BY (fNow.io_stall_write_ms - fBase.io_stall_write_ms) / (fNow.num_of_writes - fBase.num_of_writes) DESC;


	/* SQL Server Internal Maintenance - Log File Growing - CheckID 13 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt)
	SELECT 13 AS CheckID,
		1 AS Priority,
		'SQL Server Internal Maintenance' AS FindingGroup,
		'Log File Growing' AS Finding,
		'http://BrentOzar.com/askbrent/file-growing/' AS URL,
		@StockDetailsHeader + 'Number of growths during the sample: ' + CAST(ps.value_delta AS NVARCHAR(20)) + @LineFeed 
			+ 'Determined by sampling Perfmon counter ' + ps.object_name + ' - ' + ps.counter_name + @LineFeed AS Details,
		CAST(@StockWarningHeader + 'Pre-grow data and log files during maintenance windows so that they do not grow during production loads.' + @StockWarningFooter AS XML) AS HowToStopIt
	FROM #PerfmonStats ps
	WHERE ps.Pass = 2
		AND object_name = 'SQLServer:Databases'
		AND counter_name = 'Log Growths'
		AND value_delta > 0


	/* SQL Server Internal Maintenance - Log File Shrinking - CheckID 14 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt)
	SELECT 14 AS CheckID,
		1 AS Priority,
		'SQL Server Internal Maintenance' AS FindingGroup,
		'Log File Shrinking' AS Finding,
		'http://BrentOzar.com/askbrent/file-shrinking/' AS URL,
		@StockDetailsHeader + 'Number of shrinks during the sample: ' + CAST(ps.value_delta AS NVARCHAR(20)) + @LineFeed 
			+ 'Determined by sampling Perfmon counter ' + ps.object_name + ' - ' + ps.counter_name + @LineFeed AS Details,
		CAST(@StockWarningHeader + 'Pre-grow data and log files during maintenance windows so that they do not grow during production loads.' + @StockWarningFooter AS XML) AS HowToStopIt
	FROM #PerfmonStats ps
	WHERE ps.Pass = 2
		AND object_name = 'SQLServer:Databases'
		AND counter_name = 'Log Shrinks'
		AND value_delta > 0

	/* Query Problems - Compilations/Sec High - CheckID 15 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt)
	SELECT 15 AS CheckID,
		50 AS Priority,
		'Query Problems' AS FindingGroup,
		'Compilations/Sec High' AS Finding,
		'http://BrentOzar.com/askbrent/compilations/' AS URL,
		@StockDetailsHeader + 'Number of batch requests during the sample: ' + CAST(ps.value_delta AS NVARCHAR(20)) + @LineFeed 
			+ 'Number of compilations during the sample: ' + CAST(psComp.value_delta AS NVARCHAR(20)) + @LineFeed 
			+ 'For OLTP environments, Microsoft recommends that 90% of batch requests should hit the plan cache, and not be compiled from scratch. We are exceeding that threshold.' + @LineFeed AS Details,
		CAST(@StockWarningHeader + 'Find out why plans are not being reused, and consider enabling Forced Parameterization. See the URL for more details.' + @StockWarningFooter AS XML) AS HowToStopIt
	FROM #PerfmonStats ps
		INNER JOIN #PerfmonStats psComp ON psComp.Pass = 2 AND psComp.object_name = 'SQLServer:SQL Statistics' AND psComp.counter_name = 'SQL Compilations/sec' AND psComp.value_delta > 0
	WHERE ps.Pass = 2
		AND ps.object_name = 'SQLServer:SQL Statistics'
		AND ps.counter_name = 'Batch Requests/sec'
		AND ps.value_delta > 100 /* Ignore servers sitting idle */
		AND (psComp.value_delta * 10) > ps.value_delta /* Compilations are more than 10% of batch requests per second */

	/* Query Problems - Re-Compilations/Sec High - CheckID 16 */
	INSERT INTO #AskBrentResults (CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt)
	SELECT 16 AS CheckID,
		50 AS Priority,
		'Query Problems' AS FindingGroup,
		'Re-Compilations/Sec High' AS Finding,
		'http://BrentOzar.com/askbrent/recompilations/' AS URL,
		@StockDetailsHeader + 'Number of batch requests during the sample: ' + CAST(ps.value_delta AS NVARCHAR(20)) + @LineFeed 
			+ 'Number of recompilations during the sample: ' + CAST(psComp.value_delta AS NVARCHAR(20)) + @LineFeed 
			+ 'More than 10% of our queries are being recompiled. This is typically due to statistics changing on objects.' + @LineFeed AS Details,
		CAST(@StockWarningHeader + 'Find out which objects are changing so quickly that they hit the stats update threshold. See the URL for more details.' + @StockWarningFooter AS XML) AS HowToStopIt
	FROM #PerfmonStats ps
		INNER JOIN #PerfmonStats psComp ON psComp.Pass = 2 AND psComp.object_name = 'SQLServer:SQL Statistics' AND psComp.counter_name = 'SQL Re-Compilations/sec' AND psComp.value_delta > 0
	WHERE ps.Pass = 2
		AND ps.object_name = 'SQLServer:SQL Statistics'
		AND ps.counter_name = 'Batch Requests/sec'
		AND ps.value_delta > 100 /* Ignore servers sitting idle */
		AND (psComp.value_delta * 10) > ps.value_delta /* Recompilations are more than 10% of batch requests per second */


	/* If we didn't find anything, apologize. */
	IF NOT EXISTS (SELECT * FROM #AskBrentResults)
	BEGIN

		INSERT  INTO #AskBrentResults
				( CheckID ,
				  Priority ,
				  FindingsGroup ,
				  Finding ,
				  URL ,
				  Details
				)
		VALUES  ( -1 ,
				  255 ,
				  'No Problems Found' ,
				  'From Brent Ozar Unlimited' ,
				  'http://www.BrentOzar.com/askbrent/' ,
				  @StockDetailsHeader + 'Try running our more in-depth checks: http://www.BrentOzar.com/blitz/' + @LineFeed + 'or there may not be an unusual SQL Server performance problem. ' + @StockDetailsFooter
				);
		
	END /*IF NOT EXISTS (SELECT * FROM #AskBrentResults) */
	ELSE /* We found stuff, so add credits */
	BEGIN
		/* Close out the XML field Details by adding a footer */
		UPDATE #AskBrentResults
		  SET Details = Details + @StockDetailsFooter;

		/* Add credits for the nice folks who put so much time into building and maintaining this for free: */                    
		INSERT  INTO #AskBrentResults
				( CheckID ,
				  Priority ,
				  FindingsGroup ,
				  Finding ,
				  URL ,
				  Details
				)
		VALUES  ( -1 ,
				  255 ,
				  'Thanks!' ,
				  'From Brent Ozar Unlimited' ,
				  'http://www.BrentOzar.com/askbrent/' ,
				  '<?Thanks --' + @LineFeed + 'Thanks from the Brent Ozar Unlimited team.  We hope you found this tool useful, and if you need help relieving your SQL Server pains, email us at Help@BrentOzar.com. ' + @LineFeed + '-- ?>'
				);

		INSERT  INTO #AskBrentResults
				( CheckID ,
				  Priority ,
				  FindingsGroup ,
				  Finding ,
				  URL ,
				  Details

				)
		VALUES  ( -1 ,
				  0 ,
				  'sp_AskBrent (TM) v' + CAST(@Version AS VARCHAR(20)) + ' as of ' + CAST(CONVERT(DATETIME, @VersionDate, 102) AS VARCHAR(100)),
				  'From Brent Ozar Unlimited' ,
				  'http://www.BrentOzar.com/askbrent/' ,
				  '<?Thanks --' + @LineFeed + 'Thanks from the Brent Ozar Unlimited team.  We hope you found this tool useful, and if you need help relieving your SQL Server pains, email us at Help@BrentOzar.com.' + @LineFeed + ' -- ?>'
				);

	END /* ELSE  We found stuff, so add credits */

	/* @OutputTableName lets us export the results to a permanent table */
	IF @OutputDatabaseName IS NOT NULL
		AND @OutputSchemaName IS NOT NULL
		AND @OutputTableName IS NOT NULL
		AND EXISTS ( SELECT *
					 FROM   sys.databases
					 WHERE  QUOTENAME([name]) = @OutputDatabaseName) 
	BEGIN
		SET @StringToExecute = 'USE '
			+ @OutputDatabaseName
			+ '; IF EXISTS(SELECT * FROM '
			+ @OutputDatabaseName
			+ '.INFORMATION_SCHEMA.SCHEMATA WHERE QUOTENAME(SCHEMA_NAME) = '''
			+ @OutputSchemaName
			+ ''') AND NOT EXISTS (SELECT * FROM '
			+ @OutputDatabaseName
			+ '.INFORMATION_SCHEMA.TABLES WHERE QUOTENAME(TABLE_SCHEMA) = '''
			+ @OutputSchemaName + ''' AND QUOTENAME(TABLE_NAME) = '''
			+ @OutputTableName + ''') CREATE TABLE '
			+ @OutputSchemaName + '.'
			+ @OutputTableName
			+ ' (ID INT IDENTITY(1,1) NOT NULL, 
				ServerName NVARCHAR(128), 
				CheckDate DATETIME, 
				AskBrentVersion INT,
				CheckID INT NOT NULL,
				Priority TINYINT NOT NULL,
				FindingsGroup VARCHAR(50) NOT NULL,
				Finding VARCHAR(200) NOT NULL,
				URL VARCHAR(200) NOT NULL,
				Details NVARCHAR(4000) NULL,
				HowToStopIt [XML] NULL,
				QueryPlan [XML] NULL,
				QueryText NVARCHAR(MAX) NULL,
				StartTime DATETIME NULL,
				LoginName NVARCHAR(128) NULL,
				NTUserName NVARCHAR(128) NULL,
				OriginalLoginName NVARCHAR(128) NULL,
				ProgramName NVARCHAR(128) NULL,
				HostName NVARCHAR(128) NULL,
				DatabaseID INT NULL,
				DatabaseName NVARCHAR(128) NULL,
				OpenTransactionCount INT NULL,
				CONSTRAINT [PK_' + CAST(NEWID() AS CHAR(36)) + '] PRIMARY KEY CLUSTERED (ID ASC));'

		EXEC(@StringToExecute);
		SET @StringToExecute = N' IF EXISTS(SELECT * FROM '
			+ @OutputDatabaseName
			+ '.INFORMATION_SCHEMA.SCHEMATA WHERE QUOTENAME(SCHEMA_NAME) = '''
			+ @OutputSchemaName + ''') INSERT '
			+ @OutputDatabaseName + '.'
			+ @OutputSchemaName + '.'
			+ @OutputTableName
			+ ' (ServerName, CheckDate, AskBrentVersion, CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, QueryText, StartTime, LoginName, NTUserName, OriginalLoginName, ProgramName, HostName, DatabaseID, DatabaseName, OpenTransactionCount) SELECT '''
			+ CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128))
			+ ''', GETDATE(), ' + CAST(@Version AS NVARCHAR(128))
			+ ', CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, QueryText, StartTime, LoginName, NTUserName, OriginalLoginName, ProgramName, HostName, DatabaseID, DatabaseName, OpenTransactionCount FROM #AskBrentResults ORDER BY Priority , FindingsGroup , Finding , Details';
		EXEC(@StringToExecute);
	END
	ELSE IF (SUBSTRING(@OutputTableName, 2, 2) = '##')
	BEGIN
		SET @StringToExecute = N' IF (OBJECT_ID(''tempdb..'
			+ @OutputTableName
			+ ''') IS NOT NULL) DROP TABLE ' + @OutputTableName + ';'
			+ 'CREATE TABLE '
			+ @OutputTableName
			+ ' (ID INT IDENTITY(1,1) NOT NULL, 
				ServerName NVARCHAR(128), 
				CheckDate DATETIME, 
				AskBrentVersion INT,
				CheckID INT NOT NULL,
				Priority TINYINT NOT NULL,
				FindingsGroup VARCHAR(50) NOT NULL,
				Finding VARCHAR(200) NOT NULL,
				URL VARCHAR(200) NOT NULL,
				Details NVARCHAR(4000) NULL,
				HowToStopIt [XML] NULL,
				QueryPlan [XML] NULL,
				QueryText NVARCHAR(MAX) NULL,
				StartTime DATETIME NULL,
				LoginName NVARCHAR(128) NULL,
				NTUserName NVARCHAR(128) NULL,
				OriginalLoginName NVARCHAR(128) NULL,
				ProgramName NVARCHAR(128) NULL,
				HostName NVARCHAR(128) NULL,
				DatabaseID INT NULL,
				DatabaseName NVARCHAR(128) NULL,
				OpenTransactionCount INT NULL,
				CONSTRAINT [PK_' + CAST(NEWID() AS CHAR(36)) + '] PRIMARY KEY CLUSTERED (ID ASC));'
			+ ' INSERT '
			+ @OutputTableName
			+ ' (ServerName, CheckDate, AskBrentVersion, CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, QueryText, StartTime, LoginName, NTUserName, OriginalLoginName, ProgramName, HostName, DatabaseID, DatabaseName, Op) SELECT '''
			+ CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128))
			+ ''', GETDATE(), ' + CAST(@Version AS NVARCHAR(128))
			+ ', CheckID, Priority, FindingsGroup, Finding, URL, Details, HowToStopIt, QueryPlan, QueryText, StartTime, LoginName, NTUserName, OriginalLoginName, ProgramName, HostName, DatabaseID, DatabaseName, OpenTransactionCount FROM #AskBrentResults ORDER BY Priority , FindingsGroup , Finding , Details';
		EXEC(@StringToExecute);
	END
	ELSE IF (SUBSTRING(@OutputTableName, 2, 1) = '#')
	BEGIN
		RAISERROR('Due to the nature of Dymamic SQL, only global (i.e. double pound (##)) temp tables are supported for @OutputTableName', 16, 0)
	END


	DECLARE @separator AS VARCHAR(1);
	IF @OutputType = 'RSV' 
		SET @separator = CHAR(31);
	ELSE 
		SET @separator = ',';

	IF @OutputType = 'COUNT' 
	BEGIN
		SELECT  COUNT(*) AS Warnings
		FROM    #AskBrentResults
	END
	ELSE 
		IF @OutputType IN ( 'CSV', 'RSV' ) 
		BEGIN

			SELECT  Result = CAST([Priority] AS NVARCHAR(100))
					+ @separator + CAST(CheckID AS NVARCHAR(100))
					+ @separator + COALESCE([FindingsGroup],
											'(N/A)') + @separator
					+ COALESCE([Finding], '(N/A)') + @separator
					+ COALESCE(DatabaseName, '(N/A)') + @separator
					+ COALESCE([URL], '(N/A)') + @separator
					+ COALESCE([Details], '(N/A)')
			FROM    #AskBrentResults
			ORDER BY Priority ,
					FindingsGroup ,
					Finding ,
					Details;
		END
		ELSE IF @ExpertMode = 0 AND @OutputXMLasNVARCHAR = 0
		BEGIN
			SELECT  [Priority] ,
					[FindingsGroup] ,
					[Finding] ,
					[URL] ,
					CAST([Details] AS [XML]) AS Details,
					[HowToStopIt],
					[QueryText],
					[QueryPlan]
			FROM    #AskBrentResults
			ORDER BY Priority ,
					FindingsGroup ,
					Finding ,
					ID;
		END
		ELSE IF @ExpertMode = 0 AND @OutputXMLasNVARCHAR = 1
		BEGIN
			SELECT  [Priority] ,
					[FindingsGroup] ,
					[Finding] ,
					[URL] ,
					CAST([Details] AS NVARCHAR(MAX)) AS Details,
					CAST([HowToStopIt] AS NVARCHAR(MAX)) AS HowToStopIt,
					CAST([QueryText] AS NVARCHAR(MAX)) AS QueryText,
					CAST([QueryPlan] AS NVARCHAR(MAX)) AS QueryPlan
			FROM    #AskBrentResults
			ORDER BY Priority ,
					FindingsGroup ,
					Finding ,
					ID;
		END
		ELSE IF @ExpertMode = 1
		BEGIN
			SELECT  [Priority] ,
					[FindingsGroup] ,
					[Finding] ,
					[URL] ,
					CAST([Details] AS [XML]) AS Details,
					[HowToStopIt] ,
					[CheckID] ,
					[StartTime],
					[LoginName],
					[NTUserName],
					[OriginalLoginName],
					[ProgramName],
					[HostName],
					[DatabaseID],
					[DatabaseName],
					[OpenTransactionCount],
					[QueryPlan],
					[QueryText]
			FROM    #AskBrentResults
			ORDER BY Priority ,
					FindingsGroup ,
					Finding ,
					ID;

			-------------------------
			--What happened: #WaitStats
			-------------------------
			;with max_batch as (
				select max(SampleTime) as SampleTime
				from #WaitStats
			)
			SELECT
				'WAIT STATS' as Pattern,
				b.SampleTime as [Sample Ended],
				datediff(ss,wd1.SampleTime, wd2.SampleTime) as [Seconds Sample],
				wd1.wait_type,
				c.[Wait Time (Seconds)],
				c.[Signal Wait Time (Seconds)],
				CASE WHEN c.[Wait Time (Seconds)] > 0
				 THEN CAST(100.*(c.[Signal Wait Time (Seconds)]/c.[Wait Time (Seconds)]) as NUMERIC(4,1))
				ELSE 0 END AS [Percent Signal Waits],
				(wd2.waiting_tasks_count - wd1.waiting_tasks_count) AS [Number of Waits],
				CASE WHEN (wd2.waiting_tasks_count - wd1.waiting_tasks_count) > 0
				THEN
					cast((wd2.wait_time_ms-wd1.wait_time_ms)/
						(1.0*(wd2.waiting_tasks_count - wd1.waiting_tasks_count)) as numeric(10,1))
				ELSE 0 END AS [Avg ms Per Wait]
			FROM  max_batch b
			JOIN #WaitStats wd2 on
				wd2.SampleTime =b.SampleTime
			JOIN #WaitStats wd1 ON 
				wd1.wait_type=wd2.wait_type AND
				wd2.SampleTime > wd1.SampleTime
			CROSS APPLY (SELECT
				cast((wd2.wait_time_ms-wd1.wait_time_ms)/1000. as numeric(10,1)) as [Wait Time (Seconds)],
				cast((wd2.signal_wait_time_ms - wd1.signal_wait_time_ms)/1000. as numeric(10,1)) as [Signal Wait Time (Seconds)]) AS c
			WHERE (wd2.waiting_tasks_count - wd1.waiting_tasks_count) > 0
				and wd2.wait_time_ms-wd1.wait_time_ms > 0
			ORDER BY [Wait Time (Seconds)] DESC;


			-------------------------
			--What happened: #FileStats
			-------------------------
			WITH readstats as (
				SELECT 'PHYSICAL READS' as Pattern,
				ROW_NUMBER() over (order by wd2.avg_stall_read_ms desc) as StallRank,
				wd2.SampleTime as [Sample Time], 
				datediff(ss,wd1.SampleTime, wd2.SampleTime) as [Sample (seconds)],
				wd1.DatabaseName ,
				wd1.FileLogicalName AS [File Name],
				UPPER(SUBSTRING(wd1.PhysicalName, 1, 2)) AS [Drive] ,
				wd1.SizeOnDiskMB ,
				( wd2.num_of_reads - wd1.num_of_reads ) AS [# Reads/Writes],
				CASE WHEN wd2.num_of_reads - wd1.num_of_reads > 0
				  THEN CAST(( wd2.bytes_read - wd1.bytes_read)/1024./1024. AS NUMERIC(21,1)) 
				  ELSE 0 
				END AS [MB Read/Written],
				wd2.avg_stall_read_ms AS [Avg Stall (ms)],
				wd1.PhysicalName AS [file physical name]
			FROM #FileStats wd2
				JOIN #FileStats wd1 ON wd2.SampleTime > wd1.SampleTime
				  AND wd1.DatabaseID = wd2.DatabaseID
				  AND wd1.FileID = wd2.FileID
			),
			writestats as (
				SELECT 
				'PHYSICAL WRITES' as Pattern,
				ROW_NUMBER() over (order by wd2.avg_stall_write_ms desc) as StallRank,
				wd2.SampleTime as [Sample Time], 
				datediff(ss,wd1.SampleTime, wd2.SampleTime) as [Sample (seconds)],
				wd1.DatabaseName ,
				wd1.FileLogicalName AS [File Name],
				UPPER(SUBSTRING(wd1.PhysicalName, 1, 2)) AS [Drive] ,
				wd1.SizeOnDiskMB ,
				( wd2.num_of_writes - wd1.num_of_writes ) AS [# Reads/Writes],
				CASE WHEN wd2.num_of_writes - wd1.num_of_writes > 0
				  THEN CAST(( wd2.bytes_written - wd1.bytes_written)/1024./1024. AS NUMERIC(21,1)) 
				  ELSE 0 
				END AS [MB Read/Written],
				wd2.avg_stall_write_ms AS [Avg Stall (ms)],
				wd1.PhysicalName AS [file physical name]
			FROM #FileStats wd2
				JOIN #FileStats wd1 ON wd2.SampleTime > wd1.SampleTime
				  AND wd1.DatabaseID = wd2.DatabaseID
				  AND wd1.FileID = wd2.FileID
			)
			SELECT 
				Pattern, [Sample Time], [Sample (seconds)], [File Name], [Drive],  [# Reads/Writes],[MB Read/Written],[Avg Stall (ms)], [file physical name]
			from readstats
			where StallRank <=5 and [MB Read/Written] > 0
			union all
			SELECT Pattern, [Sample Time], [Sample (seconds)], [File Name], [Drive],  [# Reads/Writes],[MB Read/Written],[Avg Stall (ms)], [file physical name]
			from writestats
			where StallRank <=5 and [MB Read/Written] > 0;


			-------------------------
			--What happened: #PerfmonStats
			-------------------------

			SELECT 'PERFMON' AS Pattern, pLast.[object_name], pLast.counter_name, pLast.instance_name, 
				pFirst.SampleTime AS FirstSampleTime, pFirst.cntr_value AS FirstSampleValue,
				pLast.SampleTime AS LastSampleTime, pLast.cntr_value AS LastSampleValue,
				pLast.cntr_value - pFirst.cntr_value AS ValueDelta,
				((1.0 * pLast.cntr_value - pFirst.cntr_value) / DATEDIFF(ss, pFirst.SampleTime, pLast.SampleTime)) AS ValuePerSecond
				FROM #PerfmonStats pLast
					INNER JOIN #PerfmonStats pFirst ON pFirst.[object_name] = pLast.[object_name] AND pFirst.counter_name = pLast.counter_name AND (pFirst.instance_name = pLast.instance_name OR (pFirst.instance_name IS NULL AND pLast.instance_name IS NULL))
					AND pLast.ID > pFirst.ID
				ORDER BY Pattern, pLast.[object_name], pLast.counter_name, pLast.instance_name


			-------------------------
			--What happened: #FileStats
			-------------------------
			SELECT qsNow.*, qsFirst.*
			FROM #QueryStats qsNow
			  INNER JOIN #QueryStats qsFirst ON qsNow.[sql_handle] = qsFirst.[sql_handle] AND qsNow.statement_start_offset = qsFirst.statement_start_offset AND qsNow.statement_end_offset = qsFirst.statement_end_offset AND qsNow.plan_generation_num = qsFirst.plan_generation_num AND qsNow.plan_handle = qsFirst.plan_handle AND qsFirst.Pass = 1
			WHERE qsNow.Pass = 2
		END

	DROP TABLE #AskBrentResults;


END /* IF @Question IS NULL */
ELSE IF @Question IS NOT NULL 

/* We're playing Magic SQL 8 Ball, so give them an answer. */
BEGIN
	IF OBJECT_ID('tempdb..#BrentAnswers') IS NOT NULL 
		DROP TABLE #BrentAnswers;
	CREATE TABLE #BrentAnswers(Answer VARCHAR(200) NOT NULL);
	INSERT INTO #BrentAnswers VALUES ('It sounds like a SAN problem.');
	INSERT INTO #BrentAnswers VALUES ('You know what you need? Bacon.');
	INSERT INTO #BrentAnswers VALUES ('Talk to the developers about that.');
	INSERT INTO #BrentAnswers VALUES ('Let''s post that on StackOverflow.com and find out.');
	INSERT INTO #BrentAnswers VALUES ('Have you tried adding an index?');
	INSERT INTO #BrentAnswers VALUES ('Have you tried dropping an index?');
	INSERT INTO #BrentAnswers VALUES ('You can''t prove anything.');
	INSERT INTO #BrentAnswers VALUES ('If you watched our Tuesday webcasts, you''d already know the answer to that.');
	INSERT INTO #BrentAnswers VALUES ('Please phrase the question in the form of an answer.');
	INSERT INTO #BrentAnswers VALUES ('Outlook not so good. Access even worse.');
	INSERT INTO #BrentAnswers VALUES ('Did you try asking the rubber duck? http://www.codinghorror.com/blog/2012/03/rubber-duck-problem-solving.html');
	INSERT INTO #BrentAnswers VALUES ('Oooo, I read about that once.');
	INSERT INTO #BrentAnswers VALUES ('I feel your pain.');
	INSERT INTO #BrentAnswers VALUES ('http://LMGTFY.com');
	INSERT INTO #BrentAnswers VALUES ('No comprende Ingles, senor.');
	INSERT INTO #BrentAnswers VALUES ('I don''t have that problem on my Mac.');
	INSERT INTO #BrentAnswers VALUES ('Is Priority Boost on?');
	INSERT INTO #BrentAnswers VALUES ('Have you tried rebooting your machine?');
	INSERT INTO #BrentAnswers VALUES ('Try defragging your cursors.');
	INSERT INTO #BrentAnswers VALUES ('Why are you wearing that? Do you have a job interview later or something?');
	INSERT INTO #BrentAnswers VALUES ('I''m ashamed that you don''t know the answer to that question.');
	INSERT INTO #BrentAnswers VALUES ('What do I look like, a Microsoft Certified Master? Oh, wait...');
	INSERT INTO #BrentAnswers VALUES ('Duh, Debra.');
	SELECT TOP 1 Answer FROM #BrentAnswers ORDER BY NEWID();
END

END /* ELSE IF @OutputType = 'SCHEMA' */


SET NOCOUNT OFF;
GO


EXEC dbo.sp_AskBrent 

/* Other tests:
EXEC dbo.sp_AskBrent @ExpertMode = 1;
EXEC dbo.sp_AskBrent @ExpertMode = 0;
EXEC dbo.sp_AskBrent 'This is a test question';
*/