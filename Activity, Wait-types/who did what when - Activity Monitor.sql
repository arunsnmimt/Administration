--http://www.sqlservercentral.com/scripts/Monitoring/62467/

--details of what's run on each session in the SQLSCRIPT column

select sys.dm_exec_sessions.session_id,sys.dm_exec_sessions.host_name,sys.dm_exec_sessions.program_name,
sys.dm_exec_sessions.client_interface_name,sys.dm_exec_sessions.login_name,
sys.dm_exec_sessions.nt_domain,sys.dm_exec_sessions.nt_user_name

,sys.dm_exec_connections.client_net_address,
sys.dm_exec_connections.local_net_address,sys.dm_exec_connections.connection_id,sys.dm_exec_connections.parent_connection_id,
sys.dm_exec_connections.most_recent_sql_handle,
(select text from master.sys.dm_exec_sql_text(sys.dm_exec_connections.most_recent_sql_handle )) as sqlscript,
(select db_name(dbid) from master.sys.dm_exec_sql_text(sys.dm_exec_connections.most_recent_sql_handle )) as databasename,
(select object_id(objectid) from master.sys.dm_exec_sql_text(sys.dm_exec_connections.most_recent_sql_handle )) as objectname
from sys.dm_exec_sessions inner join sys.dm_exec_connections
on sys.dm_exec_connections.session_id=sys.dm_exec_sessions.session_id
