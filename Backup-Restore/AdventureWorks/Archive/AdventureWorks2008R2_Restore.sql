DECLARE @ServerName AS VARCHAR(128)
DECLARE @InstanceName AS VARCHAR(128)
DECLARE @DatabaseName AS VARCHAR(128)
DECLARE @SQL AS VARCHAR(500)
DECLARE @RestoreString AS VarChar(100)

SET @ServerName = LEFT(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)-1)
SET @InstanceName = SUBSTRING(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)+1, LEN(@@SERVERNAME))


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

SET @RestoreString = '\\VBOXSVR\c_drive\Files\Dropbox\SQL Server Backups\'+@ServerName+'\'+@DatabaseName+'.bak'

SET @SQL = 'RESTORE DATABASE '+@DatabaseName+' FROM DISK = ''' + @RestoreString + ''''

EXEC(@SQL)