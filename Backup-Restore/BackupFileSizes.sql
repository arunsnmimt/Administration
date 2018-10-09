--SELECT  *
--FROM  msdb..backupset
--WHERE backup_start_date >= GETDATE() -1 
--AND database_name = 'TMC_GSH'
DECLARE @DatabaseName VARCHAR(100)
DECLARE @Version VARCHAR(2)

SET @DatabaseName = 'NexphaseV6'
SET @Version = CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(2))

PRINT @Version

PRINT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(2))

--IF @Version = '10'
--BEGIN
--    SELECT  DISTINCT b.database_name, b.backup_start_date, b.backup_finish_date, b.type, CAST(((b.compressed_backup_size)* 0.00000095367432) AS DECIMAL(15,2)), a.physical_device_name
--    FROM msdb.dbo.backupmediafamily a JOIN msdb.dbo.backupset b
--    ON (a.media_set_id=b.media_set_id)
--    WHERE b.backup_start_date >= GETDATE() -1 
--	AND b.database_name = @DatabaseName
--END
--ELSE
--BEGIN
    SELECT  DISTINCT b.database_name, b.backup_start_date, b.backup_finish_date, b.type, CAST(((b.backup_size)* 0.00000095367432) AS DECIMAL(15,2)), a.physical_device_name
    FROM msdb.dbo.backupmediafamily a JOIN msdb.dbo.backupset b
    ON (a.media_set_id=b.media_set_id)
    WHERE b.backup_start_date >= GETDATE() - 3 
	AND b.database_name = @DatabaseName
--END
--    WHERE database_name = @dbname AND b.type = 'D'
--    ORDER BY b.backup_start_date DESC