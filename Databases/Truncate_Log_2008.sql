USE Processed_Data

/*
	SQL Server 2008
*/




ALTER DATABASE Processed_Data SET RECOVERY SIMPLE
GO

DBCC SHRINKFILE(Processed_Data_log, 150)
GO

ALTER DATABASE Processed_Data SET RECOVERY FULL
GO


USE Audit

ALTER DATABASE Audit SET RECOVERY SIMPLE
GO

DBCC SHRINKFILE(ErrorLog_Log, 150)
GO

ALTER DATABASE Audit SET RECOVERY FULL
GO




USE NetPerfMon
DBCC SHRINKFILE(NetPerfMon_log, 150)
GO

USE ProGeneral
DBCC SHRINKFILE('ProGeneral_Log.ldf', 150)
GO

USE msdb
DBCC SHRINKFILE('MSDBLog', 150)
GO

USE ProAchieve
DBCC SHRINKFILE('ProAchieve_Log.ldf', 150)
GO


USE LAD
DBCC SHRINKFILE('LAD_log', 150)
GO

USE ILRAnalyserNew2
DBCC SHRINKFILE('ILRAnalyser_log', 150)
GO




SELECT name, physical_name, size FROM sys.database_files