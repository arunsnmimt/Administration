/*
  1. For each file to be moved, run the following statement.
*/
/*
--  ALTER DATABASE model MODIFY FILE ( NAME = modeldev , FILENAME = 'D:\MSSQL\DATA\model.mdf' )
--  ALTER DATABASE model MODIFY FILE ( NAME = modellog , FILENAME = 'E:\MSSQL\DATA\modellog.ldf' )
--  ALTER DATABASE tempdb MODIFY FILE ( NAME = tempdev , FILENAME = 'D:\MSSQL\DATA\tempdb.mdf' )
--  ALTER DATABASE tempdb MODIFY FILE ( NAME = templog , FILENAME = 'E:\MSSQL\DATA\templog.ldf' )
--  ALTER DATABASE msdb MODIFY FILE ( NAME = MSDBData , FILENAME = 'D:\MSSQL\DATA\MSDBData.mdf' )
--  ALTER DATABASE msdb MODIFY FILE ( NAME = MSDBLog , FILENAME = 'E:\MSSQL\DATA\MSDBLog.ldf' )

--  ALTER DATABASE ReportServer MODIFY FILE ( NAME = ReportServer, FILENAME = 'D:\MSSQL\DATA\ReportServer.mdf' )
--  ALTER DATABASE ReportServer MODIFY FILE ( NAME = ReportServer_log , FILENAME = 'E:\MSSQL\DATA\ReportServer_log.ldf' )
--  ALTER DATABASE ReportServerTempDB MODIFY FILE ( NAME = ReportServerTempDB, FILENAME = 'D:\MSSQL\DATA\ReportServerTempDB.mdf' )
--  ALTER DATABASE ReportServerTempDB MODIFY FILE ( NAME = ReportServerTempDB_log , FILENAME = 'E:\MSSQL\DATA\ReportServerTempDB_log.ldf' )


	ALTER DATABASE mssqlsystemresource MODIFY FILE (NAME=data, FILENAME= 'D:\MSSQL\DATA\mssqlsystemresource.mdf')
	ALTER DATABASE mssqlsystemresource MODIFY FILE (NAME=log, FILENAME= 'E:\MSSQL\DATA\mssqlsystemresource.ldf')

	ALTER DATABASE mssqlsystemresource SET READ_ONLY

--  ALTER DATABASE xxxx MODIFY FILE ( NAME = xxxx , FILENAME = 'D:\MSSQL\DATA\xxxx.mdf' )
--  ALTER DATABASE xxxx MODIFY FILE ( NAME = xxxx , FILENAME = 'E:\MSSQL\DATA\xxxx.ldf' )


*/

/*
  2. Stop the instance of SQL Server or shut down the system to perform maintenance. For more information, see Stopping Services.
  3. Move the file or files to the new location.
  4. Restart the instance of SQL Server or the server. For more information, see Starting and Restarting Services.
  5. Verify the file change by running the following query.
*/

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id IN (DB_ID(N'ReportServer'))

--If the msdb database is moved and the instance of SQL Server is configured for Database Mail, complete these additional steps.

SELECT SERVERPROPERTY('ResourceVersion');

