SELECT name, recovery_model_desc --* --SERVERPROPERTY('productversion') AS ServerBuild, name, state_desc
FROM sys.databases
WHERE (name LIKE '%UAT%' OR name LIKE '%TRAINING%' OR name LIKE '%TEST%')
and state_desc = 'ONLINE'
and recovery_model_desc = 'FULL'
--and name NOT IN ('master','model','msdb','tempdb')



SELECT name, recovery_model_desc --* --SERVERPROPERTY('productversion') AS ServerBuild, name, state_desc
FROM sys.databases
WHERE name LIKE 'TMC_%'
AND name NOT LIKE 'TMC_%Reports%'
AND name NOT LIKE '%UAT%'
AND name NOT LIKE '%TRAIN%' 
AND name NOT LIKE '%TEST%'
and state_desc = 'ONLINE'
and recovery_model_desc = 'SIMPLE'
AND @@SERVERNAME <> 'SQLVS07'
AND @@SERVERNAME <> 'SQLVS13'


--- SQL Server 2000


select name, databasepropertyex(name, 'Recovery') as RecoveryModel from master.dbo.sysdatabases
WHERE name = 'NexphaseV6'

 order by name