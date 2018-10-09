USE master

DECLARE @ServerName AS VARCHAR(128)
DECLARE @InstanceName AS VARCHAR(128)
DECLARE @DatabaseName AS VARCHAR(128)
DECLARE @SQL AS VARCHAR(500)
DECLARE @RestoreString AS VarChar(100)
DECLARE @RestorePath AS VARCHAR(100)
DECLARE @cmd AS VARCHAR(500)

SET @ServerName = LEFT(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)-1)
SET @InstanceName = SUBSTRING(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)+1, LEN(@@SERVERNAME))
SET @RestorePath = '\\VBOXSVR\Dropbox\SQL Server Backups'  -- \'+@ServerName


SET @DatabaseName = 'TSQL2012'

-- Kill Active connections

SELECT @SQL=coalesce(@SQL,'' )+'KILL '+convert(VARCHAR, spid)+ '; '
FROM master..sysprocesses WHERE dbid=db_id(@DatabaseName)

IF LEN(@SQL) > 0
BEGIN
-- print @SQL
	EXEC(@SQL)
END

--SET @RestoreString = '\\VBOXSVR\Dropbox\SQL Server Backups\'+@ServerName+'\'+@DatabaseName+'.bak'
SET @RestoreString = '\\VBOXSVR\Dropbox\SQL Server Backups\'+@DatabaseName+'.bak'

IF @@SERVERNAME = 'VBOXWIN7'
BEGIN
	SET @SQL = 'RESTORE DATABASE '+@DatabaseName+' FROM DISK = '''+ @RestoreString + ''' WITH REPLACE, 
		MOVE ''TSQL2012'' TO ''C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\TSQL2012.mdf'', 
      MOVE ''TSQL2012_Log'' TO ''C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\TSQL2012_Log.ldf'''
END
ELSE
BEGIN
	SET @SQL = 'RESTORE DATABASE '+@DatabaseName+' FROM DISK = '''+ @RestoreString + ''' WITH REPLACE, 
		MOVE ''TSQL2012'' TO ''C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\TSQL2012.mdf'', 
      MOVE ''TSQL2012_Log'' TO ''C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\TSQL2012_Log.ldf'''
END

--PRINT @SQL
EXEC(@SQL)

