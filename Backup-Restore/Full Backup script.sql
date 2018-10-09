USE MASTER

SET NOCOUNT ON

DECLARE @DatabaseName AS VARCHAR(50)
DECLARE @BackupString AS VarChar(100)
DECLARE @BackupPath AS VarChar(100)

SET @BackupString = REPLACE(CONVERT(Varchar(30),GETDATE(),120),':','.')
SET @BackupString = REPLACE(@BackupString,' ','(')

DECLARE  DatabaseCursor CURSOR FOR
SELECT name from sys.databases
 WHERE name <> 'tempdb'

OPEN DatabaseCursor

FETCH NEXT FROM DatabaseCursor INTO @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT TOP 6 msdb.dbo.backupset.type
	INTO #Type
	FROM   msdb.dbo.backupmediafamily 
	   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
	WHERE database_name = @DatabaseName
	ORDER BY 
	   msdb.dbo.backupset.backup_finish_date DESC

	DECLARE @RowCount INT

	SET @RowCount = (SELECT COUNT(*)
					   FROM #Type
					WHERE type = 'D')

	IF @RowCount > 0 AND
       @DatabaseName <> 'master'
	BEGIN
		SET @BackupPath = 'D:\SQLBackups\' + @DatabaseName + '\' + @DatabaseName + '_' + @BackupString + ')_Diff.bak'
		BACKUP DATABASE @DatabaseName to DISK = @BackupPath WITH DIFFERENTIAL 

	END
	ELSE
	BEGIN
		SET @BackupPath = 'D:\SQLBackups\' + @DatabaseName + '\' + @DatabaseName + '_' + @BackupString + ')_Full.bak'
		BACKUP DATABASE @DatabaseName to DISK = @BackupPath
	END

	DROP TABLE #Type

	FETCH NEXT FROM DatabaseCursor INTO @DatabaseName
END

CLOSE DatabaseCursor
DEALLOCATE DatabaseCursor