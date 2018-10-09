USE TMC_CULINA								  

--EXECUTE master..sqlbackup '-SQL "BACKUP LOGS [TMC_CULINA] TO DISK = ''\\ARIZONA\LogBackups\LogBackups\SQLVS20\<database>\<AUTO>.sqb'' WITH ERASEFILES_ATSTART = 4, MAILTO_ONERROR = ''dba@microlise.com'', NO_CHECKSUM, DISKRETRYINTERVAL = 30, DISKRETRYCOUNT = 10, COMPRESSION = 2, THREADCOUNT = 2"'

								  
DECLARE @LogResueNothingCount AS TINYINT
DECLARE @LogBackupRequired AS TINYINT
DECLARE @BackupActive AS TINYINT
DECLARE @NoOfAttempts		  AS SMALLINT = 0
DECLARE @LogShrunk AS BIT = 0

-- See if log can be shrunk

WHILE @NoOfAttempts <= 6 AND @LogShrunk = 0
BEGIN
	SET @LogBackupRequired = (SELECT COUNT(*) AS RecCount
								   FROM sys.databases
								  WHERE name = 'TMC_CULINA'
									AND log_reuse_wait_desc = 'LOG_BACKUP')

	IF @LogBackupRequired = 1
	BEGIN
		EXECUTE master..sqlbackup '-SQL "BACKUP LOGS [TMC_CULINA] TO DISK = ''\\ARIZONA\LogBackups\LogBackups\SQLVS20\<database>\<AUTO>.sqb'' WITH ERASEFILES_ATSTART = 4, MAILTO_ONERROR = ''dba@microlise.com'', NO_CHECKSUM, DISKRETRYINTERVAL = 30, DISKRETRYCOUNT = 10, COMPRESSION = 2, THREADCOUNT = 2"'
	END

	WAITFOR DELAY '00:01:00' -- 1 Minutes

	SET @LogResueNothingCount = (SELECT COUNT(*) AS RecCount
								   FROM sys.databases
								  WHERE name = 'TMC_CULINA'
									AND log_reuse_wait_desc = 'NOTHING')

	IF @LogResueNothingCount = 1 -- Ok to shrink
	BEGIN
		USE TMC_CULINA;	DBCC SHRINKFILE(TMC_CULINA_log, 256)
		SET @LogShrunk = 1
	END
	ELSE
	BEGIN
		
		SET @BackupActive = (SELECT COUNT(*) AS RecCount
								   FROM sys.databases
								  WHERE name = 'TMC_CULINA'
									AND log_reuse_wait_desc = 'ACTIVE_BACKUP_OR_RESTORE')
									
		IF @BackupActive = 0									
		BEGIN
			SET @NoOfAttempts = @NoOfAttempts + 1
		END

--		WAITFOR DELAY '00:01:00' -- 1 Minutes
		
	END
END						  