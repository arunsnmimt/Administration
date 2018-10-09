SELECT  db.name, CAST((SUM(mf.size)*8)/1024/1024. AS DECIMAL(10,2)) AS SizeGB, LEFT(Physical_Name,1) AS Drive
FROM    sys.databases db 
INNER JOIN sys.master_files mf
ON db.database_id = mf.database_id
WHERE db.name NOT IN ('master','msdb','tempdb','distribution','model','ReportServer','ReportServerTempDB')
AND db.name NOT LIKE 'ARC%'
AND LEFT(Physical_Name,1) = 'F'
--/*
AND db.name NOT IN (
SELECT DISTINCT DB_NAME(dbid) AS Database_Name --, spid, kpid, blocked, waittime, uid, cpu, physical_io, memusage, login_time, last_batch, open_tran, status, hostname, program_name, hostprocess, cmd 
FROM sys.sysprocesses)
--*/
AND RIGHT(Physical_Name,3) = 'mdf'
GROUP BY db.name, LEFT(Physical_Name,1)
ORDER BY CAST((SUM(mf.size)*8)/1024/1024. AS DECIMAL(10,2)) DESC


--SELECT db.name, CAST((SUM(mf.size)*8)/1024/1024. AS DECIMAL(10,2)) AS SizeGB, (SUM(mf.size) * 8)/1024 AS db_Size_MB
--FROM sys.databases db 
--INNER JOIN sys.master_files mf
--ON db.database_id = mf.database_id
----and db.state_desc = 'OFFLINE'
--and db.name LIKE 'TMC%'
--GROUP BY  db.name
