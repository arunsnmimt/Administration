/* Databases with no Active connections */

SELECT name
from sys.databases
WHERE name NOT IN (SELECT DISTINCT DB_NAME(dbid)
                      FROM sys.sysprocesses)  
AND name NOT IN ('Admin_DBA', 'model','master','msdb','tempdb','distribution')                      
ORDER BY name
