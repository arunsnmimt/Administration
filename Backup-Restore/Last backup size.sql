/*
Last backup size


Backups are at the heart of the activities of any DBA. You have to restore the backup to know it is good, but you can get an early alert that something is wrong if your backup size changes rapidly or unexpectedly in a short period of time. It may be because a large amount of data has been inserted, or deleted if the metrics goes down, and this could be a concern if you were not expecting it. It could also be because the backup process did not complete correctly and you have a different problem that needs your attention.
*/


SELECT TOP 1 [b].[backup_size] / (1024 * 1024.0) AS [LastBackUp_MB]
  FROM [msdb].[dbo].[backupfile] AS b
  INNER JOIN [msdb].[dbo].[backupset] AS b2
  ON
    [b].[backup_set_id] = [b2].[backup_set_id]
  INNER JOIN [sys].[sysfiles] AS s
  ON
    [b].[logical_name] COLLATE DATABASE_DEFAULT = [s].[name]
  WHERE [b].[file_type] = 'D'   -- Log backups have a file-type of 'L' but will have a range of sizes.
  ORDER BY [b2].[backup_start_date] DESC;
-- If you have a mixture of collations on your server you will need to build this join using a COLLATE value to JOIN to MSDB e.g.;
-- if MSDB has a collation of Latin1_General_CI_AS you will need to write the join as "ON [b].[logical_name] = [s].[name] COLLATE Latin1_General_CI_AS"