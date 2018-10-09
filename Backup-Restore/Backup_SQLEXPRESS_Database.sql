USE MASTER

DECLARE @DateTimeStamp AS VARCHAR(50)
DECLARE @CurrentDateTime AS DATETIME
DECLARE @SQL			AS VARCHAR(4000)

SET @CurrentDateTime = GETDATE()

SET @DateTimeStamp = ' (' + REPLACE(CONVERT(VARCHAR(20),@CurrentDateTime, 120),':','.') + ')'

SET @SQL = 'BACKUP DATABASE ILRAnalyser
TO DISK = ''C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Backup\ILRAnalyser' + @DateTimeStamp + '.bak'' WITH INIT'

EXEC(@SQL)

--BACKUP DATABASE ILRAnalyser
--TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Backup\ILRAnalyser.bak' WITH INIT
--BACKUP DATABASE Test
--TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Backup\Test.bak'