/*
Number of queries running


This metric counts how many queries are running, and alerts you if the value goes above a defined threshold. If an alert is raised, you can run the query manually against the database server to see what is happening.
Metric definition
Metric Name:
	
*/
 
SELECT st.[text] AS [Command Text], s.login_time, [host_name], s.cpu_time, s.total_elapsed_time, r.session_id, c.client_net_address,
r.[status], r.command, DB_NAME(r.database_id) AS [DatabaseName]
FROM sys.dm_exec_requests AS r WITH (NOLOCK)
INNER JOIN sys.dm_exec_connections AS c WITH (NOLOCK)
ON r.session_id = c.session_id
INNER JOIN sys.dm_exec_sessions AS s WITH (NOLOCK)
ON s.session_id = r.session_id
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st
WHERE s.is_user_process = 1
AND r.session_id <> @@SPID

			