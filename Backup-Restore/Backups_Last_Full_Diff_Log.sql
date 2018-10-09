USE master

SELECT SUBSTRING(s.name,1,50) AS 'DATABASE Name', databasepropertyex(s.name, 'Recovery') as RecoveryModel, 
b.backup_start_date AS 'Full DB Backup Status',
c.backup_start_date AS 'Differential DB Backup Status',
d.backup_start_date AS 'Transaction Log Backup Status'
--INTO #Backup_Report
FROM MASTER..sysdatabases s
LEFT OUTER JOIN msdb..backupset b
ON s.name = b.database_name
AND b.backup_start_date =
(SELECT MAX(backup_start_date)AS 'Full DB Backup Status'
FROM msdb..backupset
WHERE database_name = b.database_name
AND TYPE = 'D') -- full database backups only, not log backups
LEFT OUTER JOIN msdb..backupset c
ON s.name = c.database_name
AND c.backup_start_date =
(SELECT MAX(backup_start_date)'Differential DB Backup Status'
FROM msdb..backupset
WHERE database_name = c.database_name
AND TYPE = 'I')
LEFT OUTER JOIN msdb..backupset d
ON s.name = d.database_name
AND d.backup_start_date =
(SELECT MAX(backup_start_date)'Transaction Log Backup Status'
FROM msdb..backupset
WHERE database_name = d.database_name
AND TYPE = 'L')
WHERE s.name NOT IN ('tempdb','model')
--AND b.backup_start_date  < DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0) 
--and s.name = 'NexphaseV6'
ORDER BY s.name

