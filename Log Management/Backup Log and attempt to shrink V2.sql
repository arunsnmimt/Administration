USE TMC_MAN_FRAIKIN

DECLARE @NoOfAttempts		  AS SMALLINT 
SET @NoOfAttempts = 1

DECLARE @BackupActiveChecks AS TINYINT
SET @BackupActiveChecks = 0
DECLARE @BackupActive AS TINYINT

WHILE @NoOfAttempts <= 2 AND @BackupActiveChecks <= 6
BEGIN

	SET @BackupActive = (SELECT COUNT(*) AS RecCount
							   FROM sys.databases
							  WHERE name = 'TMC_MAN_FRAIKIN'
								AND log_reuse_wait_desc = 'ACTIVE_BACKUP_OR_RESTORE')
									
	IF @BackupActive = 0
	BEGIN
		EXECUTE master..sqlbackup '-SQL "BACKUP LOGS [TMC_MAN_FRAIKIN] TO DISK = ''\\spartan\SQLBackup\Logs\SQLVS19\<database>\<AUTO>.sqb'' WITH ERASEFILES_ATSTART = 4, MAILTO_ONERROR = ''dba@microlise.com'', NO_CHECKSUM, DISKRETRYINTERVAL = 30, DISKRETRYCOUNT = 10, COMPRESSION = 2, THREADCOUNT = 2"'

		USE TMC_MAN_FRAIKIN;	DBCC SHRINKFILE(TMC_MAN_FRAIKIN_log, 1024)

		WAITFOR DELAY '00:01:00' -- 1 Minute
		
		SET @NoOfAttempts = @NoOfAttempts + 1
	END
	ELSE
	BEGIN
		WAITFOR DELAY '00:30:00' 
		SET @BackupActiveChecks = @BackupActiveChecks + 1
	END
	
END						  