SELECT * FROM sys.columns
SELECT * FROM sys.indexes
SELECT * FROM sys.sql_modules
SELECT * FROM sys.objects
SELECT * FROM sys.types
SELECT * FROM sys.database_principals

USE master 

SELECT * FROM sys.server_principals
SELECT * FROM sys.messages
SELECT * FROM sys.databases
SELECT * FROM sys.dm_exec_connections
SELECT * FROM sys.dm_exec_sessions
SELECT * FROM sys.dm_exec_requests
SELECT * FROM sys.remote_logins
SELECT * FROM sys.servers


sp_help
sp_table_validation
sp_settriggerorder
sp_lock
sp_configure
sp_who
sp_updatestats
