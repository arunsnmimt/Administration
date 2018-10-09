CREATE PROC sp_RestoreFromAllFilesInDirectory
@SourceDirBackupFiles NVARCHAR(200), @DestDirDbFiles NVARCHAR(200),@DestDirLogFiles NVARCHAR(200)
AS
BEGIN
--Copyright Tibor Karaszi, Nucleus Datakonsult, 2004. Use at own risk.
--Restores from all files in a certain directory. Assumes that:
--There's only one backup on each backup device.
--Each database uses only two database files and the mdf file is returned first from the RESTORE FILELISTONLY command.
--Modified to work with SQL Server 2005 [Andreas Moe, Ole Robin 2008]:
--  Added posibility to put log files in different location than database file, altered if statement
--  Updated Table creating #bedev and #dbfiles to suite SQL2005(also works with SQL2000), more columns added
--Sample execution:
-- EXEC sp_RestoreFromAllFilesInDirectory 'C:\Mybakfiles\', 'D:\Mydatabasesdirectory\' ,’C:\MylogDirectory\’
	SET NOCOUNT ON

	--Table to hold each backup file name in
	CREATE TABLE #files(fname VARCHAR(200),depth INT, file_ INT)
	INSERT #files
	EXECUTE master.dbo.xp_dirtree @SourceDirBackupFiles, 1, 1

	--Table to hold the result from RESTORE HEADERONLY. Needed to get the database name out from
	CREATE TABLE #bdev(
	 BackupName NVARCHAR(128)
	,BackupDescription NVARCHAR(255)
	,BackupType smallint
	,ExpirationDate datetime
	,Compressed tinyint
	,Position smallint
	,DeviceType tinyint
	,UserName NVARCHAR(128)
	,ServerName NVARCHAR(128)
	,DatabaseName NVARCHAR(128)
	,DatabaseVersion INT
	,DatabaseCreationDate datetime
	,BackupSize numeric(20,0)
	,FirstLSN numeric(25,0)
	,LastLSN numeric(25,0)
	,CheckpointLSN numeric(25,0)
	,DatabaseBackupLSN numeric(25,0)
	,BackupStartDate datetime
	,BackupFinishDate datetime
	,SortOrder smallint
	,CodePage smallint
	,UnicodeLocaleId INT
	,UnicodeComparisonStyle INT
	,CompatibilityLevel tinyint
	,SoftwareVendorId INT
	,SoftwareVersionMajor INT
	,SoftwareVersionMinor INT
	,SoftwareVersionBuild INT
	,MachineName NVARCHAR(128)
	,Flags INT
	,BindingID uniqueidentifier
	,RecoveryForkID uniqueidentifier
	,Collation NVARCHAR(128)
	,FamilyGUID uniqueidentifier
	,HasBulkLoggedData INT
	,IsSnapshot INT
	,IsReadOnly INT
	,IsSingleUser INT
	,HasBackupChecksums INT
	,IsDamaged INT
	,BegibsLogChain INT
	,HasIncompleteMetaData INT
	,IsForceOffline INT
	,IsCopyOnly INT
	,FirstRecoveryForkID uniqueidentifier
	,ForkPointLSN numeric(25,0)
	,RecoveryModel NVARCHAR(128)
	,DifferentialBaseLSN numeric(25,0)
	,DifferentialBaseGUID uniqueidentifier
	,BackupTypeDescription NVARCHAR(128)
	,BackupSetGUID uniqueidentifier
	)

	--Table to hold result from RESTORE FILELISTONLY. Need to generate the MOVE options to the RESTORE command
	CREATE TABLE #dbfiles(
	 LogicalName NVARCHAR(128)
	,PhysicalName NVARCHAR(260)
	,Type CHAR(1)
	,FileGroupName NVARCHAR(128)
	,Size numeric(20,0)
	,MaxSize numeric(20,0)
	,FileId INT
	,CreateLSN numeric(25,0)
	,DropLSN numeric(25,0)
	,UniqueId uniqueidentifier
	,ReadOnlyLSN numeric(25,0)
	,ReadWriteLSN numeric(25,0)
	,BackupSizeInBytes INT
	,SourceBlockSize INT
	,FilegroupId INT
	,LogGroupGUID uniqueidentifier
	,DifferentialBaseLSN numeric(25)
	,DifferentialBaseGUID uniqueidentifier
	,IsReadOnly INT
	,IsPresent INT
	)


	DECLARE @fname VARCHAR(200)
	DECLARE @dirfile VARCHAR(300)
	DECLARE @LogicalName NVARCHAR(128)
	DECLARE @PhysicalName NVARCHAR(260)
	DECLARE @type CHAR(1)
	DECLARE @DbName sysname
	DECLARE @sql NVARCHAR(1000)

	DECLARE files CURSOR FOR
	SELECT fname FROM #files

	DECLARE dbfiles CURSOR FOR
	SELECT LogicalName, PhysicalName, Type FROM #dbfiles

	OPEN files
	FETCH NEXT FROM files INTO @fname
	WHILE @@FETCH_STATUS = 0
	BEGIN
	SET @dirfile = @SourceDirBackupFiles + @fname

	--Get database name from RESTORE HEADERONLY, assumes there's only one backup on each backup file.
	TRUNCATE TABLE #bdev
	INSERT #bdev
	EXEC('RESTORE HEADERONLY FROM DISK = ''' + @dirfile + '''')
	SET @DbName = (SELECT DatabaseName FROM #bdev)

	--Construct the beginning for the RESTORE DATABASE command
	SET @sql = 'RESTORE DATABASE ' + @DbName + ' FROM DISK = ''' + @dirfile + ''' WITH MOVE '

	--Get information about database files from backup device into temp table
	TRUNCATE TABLE #dbfiles
	INSERT #dbfiles
	EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @dirfile + '''')

	OPEN dbfiles
	FETCH NEXT FROM dbfiles INTO @LogicalName, @PhysicalName, @type
	--For each database file that the database uses
	WHILE @@FETCH_STATUS = 0
	BEGIN
	IF @type = 'D'
	SET @sql = @sql + '''' + @LogicalName + ''' TO ''' + @DestDirDbFiles + @LogicalName  + '.mdf'', MOVE '
	ELSE IF @type = 'L'
	SET @sql = @sql + '''' + @LogicalName + ''' TO ''' + @DestDirLogFiles + @LogicalName  + '.ldf'''
	FETCH NEXT FROM dbfiles INTO @LogicalName, @PhysicalName, @type
	END

	--Here's the actual RESTORE command
	PRINT @sql
	--Remove the comment below if you want the procedure to actually execute the restore command.
	EXEC(@sql)
	CLOSE dbfiles
	FETCH NEXT FROM files INTO @fname
	END
	CLOSE files
	DEALLOCATE dbfiles
	DEALLOCATE files

END


















RESTORE DATABASE AdventureWorks FROM DISK AdventureWorksBackups
      MOVE 'AdventureWorks_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\NewAdvWorks.mdf', 
      MOVE 'AdventureWorks_Log'  TO 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\NewAdvWorks.ldf';


DEC

RESTORE HEADERONLY FROM DISK = 'E:\MSSQL\Backups\SQL-02\CastleCitrix\CastleCitrix_backup_200906240201.bak'
RESTORE FILELISTONLY FROM DISK = 'E:\MSSQL\Backups\SQL-02\CastleCitrix\CastleCitrix_backup_200906240201.bak'
RESTORE FILELISTONLY FROM DISK = 'E:\MSSQL\Backups\SQL-02\CastleCitrix\CastleCitrix_backup_200906240201.bak'

CREATE TABLE #foo  
(
DatabaseName VARCHAR(50) NULL,
LogicalName VARCHAR(50) NULL,
PhysicalName VARCHAR(100) NULL
)


INSERT INTO
SELECT 'CastleCitrix', LogicalName, PhysicalName FROM exec('RESTORE FILELISTONLY FROM DISK = ''E:\MSSQL\Backups\SQL-02\CastleCitrix\CastleCitrix_backup_200906240201.bak''')


select * from #foo