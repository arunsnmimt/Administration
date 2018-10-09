-- Most recent backups

DECLARE @dbname sysname
SET @dbname = NULL --set this to be whatever dbname you want
SELECT bup.user_name AS [User],
 bup.database_name AS [Database],
 bup.server_name AS [Server],
 bup.backup_start_date AS [Backup Started],
 bup.backup_finish_date AS [Backup Finished],
Cast(DAtepart(hour,(bup.backup_finish_date - bup.backup_start_date)) as varchar) + ' hour(s) ' 
+ Cast(DAtepart(mi,(bup.backup_finish_date - bup.backup_start_date)) as varchar) + ' minute(s) '
+ Cast(DAtepart(ss,(bup.backup_finish_date - bup.backup_start_date)) as varchar) + ' second(s) '
AS [Total Time]
FROM msdb.dbo.backupset bup
WHERE bup.backup_set_id IN
  (SELECT MAX(backup_set_id) FROM msdb.dbo.backupset
  WHERE database_name = ISNULL(@dbname, database_name) --if no dbname, then return all
  AND type = 'D' --only interested in the time of last full backup
  GROUP BY database_name) 
/* COMMENT THE NEXT LINE IF YOU WANT ALL BACKUP HISTORY */
AND bup.database_name IN (SELECT name FROM master.dbo.sysdatabases)
ORDER BY bup.database_name


-- list of all backups 

DECLARE @dbname2 sysname
SET @dbname2 = 'SDSDBCENTRAL' -- NULL --set this to be whatever dbname you want
SELECT bup.user_name AS [User],
 bup.database_name AS [Database],
 CASE bup.[type]
   WHEN 'I' THEN 'Differential'
   WHEN 'D' THEN 'Full'
   WHEN 'L' THEN 'Log'
   ELSE 'Unkown' 
 END AS Backup_Type,
 bup.server_name AS [Server],
 bup.backup_start_date AS [Backup Started],
 LEFT(DATENAME ( weekday ,  bup.backup_start_date),3) AS [Backup Started - Week Day],
 bup.backup_finish_date AS [Backup Finished],
Cast(DAtepart(hour,(bup.backup_finish_date - bup.backup_start_date)) as varchar) + ' hour(s) ' 
+ Cast(DAtepart(mi,(bup.backup_finish_date - bup.backup_start_date)) as varchar) + ' minute(s) '
+ Cast(DAtepart(ss,(bup.backup_finish_date - bup.backup_start_date)) as varchar) + ' second(s) '
AS [Total Time]
FROM msdb.dbo.backupset bup
/* COMMENT THE NEXT LINE IF YOU WANT ALL BACKUP HISTORY */
--WHERE bup.database_name IN (SELECT name FROM master.dbo.sysdatabases)
WHERE bup.database_name = @dbname2
AND bup.backup_finish_date > GETDATE() - 8
--AND  bup.[type] <> 'L'
ORDER BY bup.database_name, bup.backup_finish_date