-- Last batch of code invoked by each connection 

SELECT session_id, TEXT
FROM sys.dm_exec_connections
CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) AS ST
WHERE session_id IN (52, 53);
