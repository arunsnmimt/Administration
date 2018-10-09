DECLARE @ServerName AS VARCHAR(128)
DECLARE @InstanceName AS VARCHAR(128)
DECLARE @DatabaseName AS VARCHAR(128)
DECLARE @SQL AS VARCHAR(500)
DECLARE @RestoreString AS VarChar(100)
DECLARE @RestorePath AS VARCHAR(100)
DECLARE @cmd AS VARCHAR(500)

SET @ServerName = LEFT(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)-1)
SET @InstanceName = SUBSTRING(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)+1, LEN(@@SERVERNAME))
SET @RestorePath = '\\VBOXSVR\Dropbox\SQL Server Backups\'+@ServerName

IF @InstanceName = 'SQL2005'
BEGIN
	SET @DatabaseName = 'AdventureWorks'
END

IF @InstanceName = 'SQL2008R2'
BEGIN
	SET @DatabaseName = 'AdventureWorks2008R2'
END

IF @InstanceName = 'SQL2012'
BEGIN
	SET @DatabaseName = 'AdventureWorks2012'
END

IF @InstanceName = 'SQL2014'
BEGIN
	SET @DatabaseName = 'AdventureWorks2014'
END

-- Kill Active connections

IF @InstanceName = 'SQL2005'
BEGIN
	SET @RestoreString = @RestorePath+'\'+@DatabaseName
	
	SET @cmd = 'C:\SoftwarePortable\PortableApps\7-ZipPortable\App\7-Zip\7z.exe e "' + @RestoreString + '.zip" -o"' + @RestorePath +'"'
--	PRINT @cmd	
	EXEC xp_cmdshell @cmd

	--SET @cmd = 'DEL "' + @BackupString + '.bak"'
	--EXEC xp_cmdshell @cmd
END

SELECT @SQL=coalesce(@SQL,'' )+'KILL '+convert(VARCHAR, spid)+ '; '
FROM master..sysprocesses WHERE dbid=db_id(@DatabaseName)

IF LEN(@SQL) > 0
BEGIN
-- print @SQL
	EXEC(@SQL)
END

SET @RestoreString = '\\VBOXSVR\Dropbox\SQL Server Backups\'+@ServerName+'\'+@DatabaseName+'.bak'

SET @SQL = 'RESTORE DATABASE '+@DatabaseName+' FROM DISK = '''+ @RestoreString + ''''

EXEC(@SQL)

IF @InstanceName = 'SQL2005'
BEGIN
	
	SET @RestoreString = @RestorePath+'\'+@DatabaseName

	SET @cmd = 'DEL "' + @RestoreString + '.bak"'
	EXEC xp_cmdshell @cmd
END