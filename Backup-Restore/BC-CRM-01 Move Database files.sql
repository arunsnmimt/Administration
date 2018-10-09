/*
	1. User Databases

*/

	ALTER DATABASE CastleCollege_MSCRM SET OFFLINE
	ALTER DATABASE MSCRM_CONFIG SET OFFLINE
	ALTER DATABASE ReportServer SET OFFLINE
	ALTER DATABASE ReportServerTempDB SET OFFLINE

/*
   ######################  HALT  ######################

	Move physical files to new location

*/


	ALTER DATABASE CastleCollege_MSCRM MODIFY FILE (NAME = mscrm , FILENAME = 'D:\MSSQL\DATA\CastleCollege_MSCRM.mdf' )
	ALTER DATABASE CastleCollege_MSCRM MODIFY FILE (NAME = mscrm_log , FILENAME = 'E:\MSSQL\DATA\CastleCollege_MSCRM_log.ldf' )

	ALTER DATABASE MSCRM_CONFIG MODIFY FILE (NAME = MSCRM_CONFIG , FILENAME = 'D:\MSSQL\DATA\MSCRM_CONFIG.mdf' )
	ALTER DATABASE MSCRM_CONFIG MODIFY FILE (NAME = MSCRM_CONFIG_log , FILENAME = 'E:\MSSQL\DATA\MSCRM_CONFIG_log.ldf' )

	ALTER DATABASE ReportServer MODIFY FILE (NAME = ReportServer , FILENAME = 'D:\MSSQL\DATA\ReportServer.mdf' )
	ALTER DATABASE ReportServer MODIFY FILE (NAME = ReportServer_log , FILENAME = 'E:\MSSQL\DATA\ReportServer_log.ldf' )

	ALTER DATABASE ReportServerTempDB MODIFY FILE (NAME = ReportServerTempDB , FILENAME = 'D:\MSSQL\DATA\ReportServerTempDB.mdf' )
	ALTER DATABASE ReportServerTempDB MODIFY FILE (NAME = ReportServerTempDB_log , FILENAME = 'E:\MSSQL\DATA\ReportServerTempDB_log.ldf' )


	ALTER DATABASE CastleCollege_MSCRM SET ONLINE
	ALTER DATABASE MSCRM_CONFIG SET ONLINE
	ALTER DATABASE ReportServer SET ONLINE
	ALTER DATABASE ReportServerTempDB SET ONLINE


/*
   ######################  HALT  ######################

	2. Move system databaes (Except Master and Resource)

*/

	ALTER DATABASE model MODIFY FILE (NAME = modeldev , FILENAME = 'D:\MSSQL\DATA\model.mdf')
	ALTER DATABASE model MODIFY FILE (NAME = modellog , FILENAME = 'E:\MSSQL\DATA\modellog.ldf')
	ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev , FILENAME = 'D:\MSSQL\DATA\tempdb.mdf')
	ALTER DATABASE tempdb MODIFY FILE (NAME = templog , FILENAME = 'E:\MSSQL\DATA\templog.ldf')
	ALTER DATABASE msdb MODIFY FILE (NAME = MSDBData , FILENAME = 'D:\MSSQL\DATA\MSDBData.mdf')
	ALTER DATABASE msdb MODIFY FILE (NAME = MSDBLog , FILENAME = 'E:\MSSQL\DATA\MSDBLog.ldf')


/*
   ######################  HALT  ######################

> Stop the instance of SQL Server
> Move the file or files to the new location.
> Restart the instance of SQL Server or the server

*/

/*
	3. Move master and Resource databases

> From the Start menu, point to All Programs, point to Microsoft SQL Server 2005, point to Configuration Tools, and then click 
  SQL Server Configuration Manager.
> In the SQL Server 2005 Services node, right-click the instance of SQL Server (for example, SQL Server (MSSQLSERVER)) and choose Properties.
> In the SQL Server (instance_name) Properties dialog box, click the Advanced tab.
> Edit the Startup Parameters values to point to the planned location for the master database data and log files, and click OK. 
  Moving the error log file is optional.

The parameter value for the data file must follow the -d parameter and the value for the log file must follow the -l parameter. 
The following example shows the parameter values for the default location of the master data and log files.

-dC:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\master.mdf;-eC:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG\ERRORLOG;-lC:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\mastlog.ldf
 
If the planned relocation for the master data and log files is E:\SQLData, the parameter values would be changed as follows:

-dD:\MSSQL\Data\master.mdf;-eC:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG\ERRORLOG;-lE:\MSSQL\Data\mastlog.ldf
 
> Stop the instance of SQL Server by right-clicking the instance name and choosing Stop.
> Move the master.mdf and mastlog.ldf files to the new location.
> Start the instance of SQL Server in master-only recovery mode by entering one of the following commands at the command prompt. 
  The parameters specified in these commands are case sensitive. The commands fail when the parameters are not specified as shown.


For the default (MSSQLSERVER) instance, run the following command.

NET START MSSQLSERVER /f /T3608
 
Using sqlcmd commands or SQL Server Management Studio, run the following statements. Change the FILENAME path to match the new location of the master data file. Do not change the name of the database or the file names.

   ######################  HALT  ######################

*/
	ALTER DATABASE mssqlsystemresource MODIFY FILE (NAME=data, FILENAME= 'D:\MSSQL\DATA\mssqlsystemresource.mdf')
	ALTER DATABASE mssqlsystemresource MODIFY FILE (NAME=log, FILENAME= 'E:\MSSQL\DATA\mssqlsystemresource.ldf')

/* 


> Move the mssqlsystemresource.mdf and mssqlsystemresource.ldf files to the new location.
> Set the Resource database to read-only by running the following statement.

   ######################  HALT  ######################

*/
	ALTER DATABASE mssqlsystemresource SET READ_ONLY;

/*


> Exit the sqlcmd utility or SQL Server Management Studio.
> Stop the instance of SQL Server.
> Restart the instance of SQL Server.
> Verify the file change for the master database by running the following query. The Resource database metadata cannot be viewed by using the system catalog views or system tables.
*/
	SELECT name, physical_name AS CurrentLocation, state_desc
	FROM sys.master_files

	SELECT SERVERPROPERTY('ResourceVersion');

/*

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

