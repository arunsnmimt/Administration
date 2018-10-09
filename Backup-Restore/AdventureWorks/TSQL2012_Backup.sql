DECLARE @ServerName AS VARCHAR(128)
DECLARE @InstanceName AS VARCHAR(128)
DECLARE @DatabaseName AS VARCHAR(128)
DECLARE @Compression AS VARCHAR(20)
DECLARE @SQL AS VARCHAR(500)
DECLARE @BackupString AS VarChar(100)

SET @ServerName = LEFT(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)-1)
SET @InstanceName = SUBSTRING(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)+1, LEN(@@SERVERNAME))

SET @DatabaseName = 'TSQL2012'
SET @Compression = 'COMPRESSION, '

SET @BackupString = REPLACE(CONVERT(Varchar(30),GETDATE(),120),':','');
SET @BackupString = REPLACE(@BackupString,' ','_');
SET @BackupString = REPLACE(@BackupString,'-','');
SET @BackupString = '\\VBOXSVR\files\Backups\SQL Server\'+@ServerName+'\'+@DatabaseName+'_' + @BackupString + '.bak';

SET @SQL = 'BACKUP DATABASE ' + @DatabaseName + ' To DISK = '''+ @BackupString + ''' WITH  NOFORMAT, INIT, '+@Compression+' NAME = N'''+@DatabaseName+'-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;'

EXEC(@SQL)

--SET @BackupString = '\\VBOXSVR\Dropbox\SQL Server Backups\'+@ServerName+'\'+@DatabaseName+'.bak'
SET @BackupString = '\\VBOXSVR\Dropbox\SQL Server Backups\'+@DatabaseName+'.bak'

SET @SQL = 'BACKUP DATABASE ' + @DatabaseName + ' To DISK = '''+ @BackupString + ''' WITH  NOFORMAT, INIT, '+@Compression+' NAME = N'''+@DatabaseName+'-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;'

EXEC(@SQL)

