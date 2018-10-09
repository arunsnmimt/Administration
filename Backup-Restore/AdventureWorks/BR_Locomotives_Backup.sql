DECLARE @ServerName AS VARCHAR(128)
DECLARE @InstanceName AS VARCHAR(128)
DECLARE @DatabaseName AS VARCHAR(128)
DECLARE @Compression AS VARCHAR(20)
DECLARE @SQL AS VARCHAR(500)
DECLARE @BackupString AS VarChar(100)

--SET @ServerName = LEFT(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)-1)
SET @InstanceName = @@SERVERNAME --SUBSTRING(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)+1, LEN(@@SERVERNAME))

SET @DatabaseName = 'BR_Locomotives'
SET @Compression = 'COMPRESSION'

SET @BackupString = REPLACE(CONVERT(Varchar(30),GETDATE(),120),':','');
SET @BackupString = REPLACE(@BackupString,' ','_');
SET @BackupString = REPLACE(@BackupString,'-','');
SET @BackupString = '\\VBOXSVR\files\Backups\SQL Server\'+@DatabaseName+'_' + @BackupString + '.bak';

SET @SQL = 'BACKUP DATABASE ' + @DatabaseName + ' To DISK = '''+ @BackupString + ''' WITH  NOFORMAT, INIT, '+@Compression+', NAME = N'''+@DatabaseName+'-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;'

PRINT @SQL

EXEC(@SQL)

--SET @BackupString = '\\VBOXSVR\Dropbox\SQL Server Backups\'+@ServerName+'\'+@DatabaseName+'.bak'

--SET @SQL = 'BACKUP DATABASE ' + @DatabaseName + ' To DISK = '''+ @BackupString + ''' WITH  NOFORMAT, INIT, '+@Compression+' NAME = N'''+@DatabaseName+'-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;'

--EXEC(@SQL)

--IF @InstanceName = 'SQL2005'
--BEGIN
--	DECLARE @cmd AS VARCHAR(500)
--	SET @BackupString = '\\VBOXSVR\Dropbox\SQL Server Backups\'+@ServerName+'\'+@DatabaseName
	
--	SET @cmd = 'DEL "' + @BackupString + '.zip"'
--	EXEC xp_cmdshell @cmd	
	
--	SET @cmd = 'C:\SoftwarePortable\PortableApps\7-ZipPortable\App\7-Zip\7z.exe a "' + @BackupString + '.zip" "' + @BackupString + '.bak"'
--	EXEC xp_cmdshell @cmd

--	SET @cmd = 'DEL "' + @BackupString + '.bak"'
--	EXEC xp_cmdshell @cmd
--END
