USE [master];
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Locks]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE dbo.sp_Locks;
GO
  
  
CREATE PROCEDURE dbo.sp_Locks
(
	 @Mode int = 2
	,@Wait_Duration_ms int = 1000 /* 1 seconds */
)
/*    
	19/04/2008 Yaniv Etrogi   
	http://www.sqlserverutilities.com	
*/    
AS    
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


--EXEC sp_Locks @Mode = 3, @Wait_Duration_ms = 1000


/* return the one result set */
IF @Mode = 1
BEGIN;
SELECT
    t.blocking_session_id						AS blocking
   ,t.session_id										AS blocked
   ,p2.[program_name]								AS program_blocking
   ,p1.[program_name]								AS program_blocked   
   ,DB_NAME(l.resource_database_id) AS [database]
   ,p2.[hostname]										AS host_blocking
   ,p1.[hostname]										AS host_blocked   
   ,t.wait_duration_ms
   ,l.request_mode
   ,l.resource_type
   ,t.wait_type  
   ,(SELECT SUBSTRING(st.text, (r.statement_start_offset/2) + 1, ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) FROM sys.dm_exec_requests AS r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st WHERE r.session_id = l.request_session_id) AS statement_blocked
   ,CASE WHEN t.blocking_session_id > 0 THEN (SELECT st.text FROM sys.sysprocesses AS p CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) AS st WHERE p.spid = t.blocking_session_id) ELSE NULL END AS statement_blocking  
   --,t.resource_description				AS blocking_resource_description
   --,l.resource_associated_entity_id
FROM sys.dm_os_waiting_tasks AS t
INNER JOIN sys.dm_tran_locks AS l ON t.resource_address = l.lock_owner_address
INNER JOIN sys.sysprocesses p1 ON p1.spid = t.session_id
INNER JOIN sys.sysprocesses p2 ON p2.spid = t.blocking_session_id
WHERE t.session_id > 50
AND t.wait_duration_ms > @Wait_Duration_ms;
END;


/* return the first two result sets */
IF @Mode = 2
BEGIN;
SELECT 
	 spid
	,[status]
	,CONVERT(CHAR(3), blocked) AS blocked
	,loginame 
	,SUBSTRING([program_name] ,1,25) AS program
	,SUBSTRING(DB_NAME(p.dbid),1,10) AS [database]
	,SUBSTRING(hostname, 1, 12) AS host
	,cmd
	,waittype
	,t.[text]
FROM sys.sysprocesses p
CROSS APPLY sys.dm_exec_sql_text (p.sql_handle) t
WHERE spid IN (SELECT blocked FROM sys.sysprocesses WHERE blocked <> 0) AND blocked = 0;


SELECT
    t.blocking_session_id						AS blocking
   ,t.session_id										AS blocked
   ,p2.[program_name]								AS program_blocking
   ,p1.[program_name]								AS program_blocked   
   ,DB_NAME(l.resource_database_id) AS [database]
   ,p2.[hostname]										AS host_blocking
   ,p1.[hostname]										AS host_blocked   
   ,t.wait_duration_ms
   ,l.request_mode
   ,l.resource_type
   ,t.wait_type  
   ,(SELECT SUBSTRING(st.text, (r.statement_start_offset/2) + 1, ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) FROM sys.dm_exec_requests AS r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st WHERE r.session_id = l.request_session_id) AS statement_blocked
   ,CASE WHEN t.blocking_session_id > 0 THEN (SELECT st.text FROM sys.sysprocesses AS p CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) AS st WHERE p.spid = t.blocking_session_id) ELSE NULL END AS statement_blocking  
FROM sys.dm_os_waiting_tasks AS t
INNER JOIN sys.dm_tran_locks AS l ON t.resource_address = l.lock_owner_address
INNER JOIN sys.sysprocesses p1 ON p1.spid = t.session_id
INNER JOIN sys.sysprocesses p2 ON p2.spid = t.blocking_session_id
WHERE t.session_id > 50
AND t.wait_duration_ms > @Wait_Duration_ms;
END;


/* return all three result sets */
IF @Mode = 3
BEGIN;
SELECT 
	 spid
	,[status]
	,CONVERT(CHAR(3), blocked) AS blocked
	,loginame 
	,SUBSTRING([program_name], 1, 25)		AS program
	,SUBSTRING(DB_NAME(p.dbid), 1, 10)	AS [database]
	,SUBSTRING(hostname, 1, 12)					AS host
	,cmd
	,waittype
	,t.[text]
FROM sys.sysprocesses p
CROSS APPLY sys.dm_exec_sql_text (p.sql_handle) t
WHERE spid IN (SELECT blocked FROM sys.sysprocesses WHERE blocked <> 0) AND blocked = 0;

	
SELECT
    t.blocking_session_id								AS blocking
   ,t.session_id												AS blocked
   ,SUBSTRING(p2.[program_name], 1, 25)	AS program_blocking
   ,SUBSTRING(p1.[program_name], 1, 25)	AS program_blocked   
   ,DB_NAME(l.resource_database_id)			AS [database]
   ,p2.[hostname]												AS host_blocking
   ,p1.[hostname]												AS host_blocked   
   ,t.wait_duration_ms
   ,l.request_mode
   ,l.resource_type
   ,t.wait_type  
   ,(SELECT SUBSTRING(st.text, (r.statement_start_offset/2) + 1, ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) FROM sys.dm_exec_requests AS r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st WHERE r.session_id = l.request_session_id) AS statement_blocked
   ,CASE WHEN t.blocking_session_id > 0 THEN (SELECT st.text FROM sys.sysprocesses AS p CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) AS st WHERE p.spid = t.blocking_session_id) ELSE NULL END AS statement_blocking  
   --,t.resource_description				AS blocking_resource_description
   --,l.resource_associated_entity_id
FROM sys.dm_os_waiting_tasks AS t
INNER JOIN sys.dm_tran_locks AS l ON t.resource_address = l.lock_owner_address
INNER JOIN sys.sysprocesses p1 ON p1.spid = t.session_id
INNER JOIN sys.sysprocesses p2 ON p2.spid = t.blocking_session_id
WHERE t.session_id > 50
AND t.wait_duration_ms > @Wait_Duration_ms;


SELECT DISTINCT
	 r.session_id							AS spid
	,r.percent_complete				AS [percent]
	,r.open_transaction_count AS open_trans
	,r.[status]
	,r.reads
	,r.logical_reads
	,r.writes
	,s.cpu
	,DB_NAME(r.database_id)		AS [db_name]
	,s.[hostname]
	,s.[program_name] 
--,s.loginame 
--,s.login_time 
	,r.start_time
--,r.wait_type
	,r.wait_time 
	,r.last_wait_type
	,r.blocking_session_id		AS blocking
	,r.command 
	,(SELECT SUBSTRING(text, statement_start_offset/2 + 1,(CASE WHEN statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),text)) * 2 ELSE statement_end_offset END - statement_start_offset)/2) FROM sys.dm_exec_sql_text(r.sql_handle)) AS [statement]
	,t.[text]
--,query_plan 
FROM sys.dm_exec_requests r
INNER JOIN sys.sysprocesses s ON s.spid = r.session_id
CROSS APPLY sys.dm_exec_sql_text (r.sql_handle) t
--CROSS APPLY sys.dm_exec_query_plan (r.plan_handle) 
WHERE r.session_id > 50 AND r.session_id <> @@spid
AND s.[program_name] NOT LIKE 'SQL Server Profiler%'
--AND db_name(r.database_id) NOT LIKE N'distribution'
--AND r.wait_type IN ('SQLTRACE_LOCK', 'IO_COMPLETION', 'TRACEWRITE')
ORDER BY s.CPU DESC;
END;
GO
