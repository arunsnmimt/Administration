/* Details of databases (include corrupt)

SQL Command to list file details when a database is corrupt:
*/

-- MDF Files 
select a.name, b.name as 'Logical filename', b.filename from sysdatabases a inner join sysaltfiles b on a.dbid = b.dbid where fileid = 1

-- LOG Files
select a.name, b.name as 'Logical filename', b.filename from sysdatabases a inner join sysaltfiles b on a.dbid = b.dbid where fileid = 2
 
 
SELECT SERVERPROPERTY('productversion') AS ServerBuild, name, state_desc, log_reuse_wait_desc --, '''' + name + ''','
FROM sys.databases
WHERE name LIKE '%%'
--and PATINDEX('%[0-9]',name) <> 0
--and log_reuse_wait_desc <> 'NOTHING'
--and state_desc = 'ONLINE'
--and name NOT IN ('master','model','msdb','tempdb')
ORDER BY name