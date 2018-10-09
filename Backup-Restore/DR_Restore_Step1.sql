/*
SQL-02

Install With Collation SQL_Latin1_General_CP1_CI_AS and default data locations


Create D and E drives for Virtual Machine

Add these to Virtual Machine

Create Directories D:\MSSQL\Data & E:\MSSQL\DATA
*/

EXECUTE master.dbo.xp_create_subdir 'D:\MSSQL\Data'
EXECUTE master.dbo.xp_create_subdir 'E:\MSSQL\Data'

EXECUTE master.dbo.xp_create_subdir 'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL'

/*
Change Database default locations
*/

/*
	C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA
	C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA

*/

USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultData', REG_SZ, N'D:\MSSQL\DATA'
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultLog', REG_SZ, N'E:\MSSQL\DATA'
GO

/*
	Restart SQL Server
*/

/*
	Create Databases
*/
CREATE DATABASE [ASP_CONFIG] ON PRIMARY (NAME = 'ASP_CONFIG', FILENAME = 'D:\MSSQL\Data\ASP_CONFIG.mdf') LOG ON (NAME = 'ASP_CONFIG_log', FILENAME = 'E:\MSSQL\Data\ASP_CONFIG_log.ldf')
CREATE DATABASE [Audit] ON PRIMARY (NAME = 'ErrorLog', FILENAME = 'D:\MSSQL\Data\ErrorLog.mdf') LOG ON (NAME = 'ErrorLog_log', FILENAME = 'E:\MSSQL\Data\ErrorLog_log.ldf')
CREATE DATABASE [Castle-Citrix-DB] ON PRIMARY (NAME = 'Castle-Citrix-DB', FILENAME = 'D:\MSSQL\Data\Castle-Citrix-DB.mdf') LOG ON (NAME = 'Castle-Citrix-DB_log', FILENAME = 'E:\MSSQL\Data\Castle-Citrix-DB_log.ldf')
CREATE DATABASE [Census] ON PRIMARY (NAME = 'Census', FILENAME = 'D:\MSSQL\Data\Census.mdf') LOG ON (NAME = 'Census_log', FILENAME = 'E:\MSSQL\Data\Census_log.ldf')
CREATE DATABASE [Compliance_Audit] ON PRIMARY (NAME = 'Compliance_Audit', FILENAME = 'D:\MSSQL\Data\Compliance_Audit.mdf') LOG ON (NAME = 'Compliance_Audit_log', FILENAME = 'E:\MSSQL\Data\Compliance_Audit_log.ldf')
CREATE DATABASE [ConfigMgrDashboardSessionDB] ON PRIMARY (NAME = 'ConfigMgrDashboardSessionDB', FILENAME = 'D:\MSSQL\Data\ConfigMgrDashboardSessionDB.mdf') LOG ON (NAME = 'ConfigMgrDashboardSessionDB_log', FILENAME = 'E:\MSSQL\Data\ConfigMgrDashboardSessionDB_log.LDF')
CREATE DATABASE [EBS] ON PRIMARY (NAME = 'EBS', FILENAME = 'D:\MSSQL\Data\EBS.mdf') LOG ON (NAME = 'EBS_log', FILENAME = 'E:\MSSQL\Data\EBS_log.ldf')
CREATE DATABASE [exams-citrix] ON PRIMARY (NAME = 'exams-citrix', FILENAME = 'D:\MSSQL\Data\exams-citrix.mdf') LOG ON (NAME = 'exams-citrix_log', FILENAME = 'E:\MSSQL\Data\exams-citrix_log.ldf')
CREATE DATABASE [Funding_Analyser] ON PRIMARY (NAME = 'Funding_Analyser', FILENAME = 'D:\MSSQL\Data\Funding_Analyser.mdf') LOG ON (NAME = 'Funding_Analyser_log', FILENAME = 'E:\MSSQL\Data\Funding_Analyser_log.ldf')
CREATE DATABASE [ILRAnalyser] ON PRIMARY (NAME = 'ILRAnalyser_Data', FILENAME = 'D:\MSSQL\Data\ILRAnalyser_Data.MDF') LOG ON (NAME = 'ILRAnalyser_Log', FILENAME = 'E:\MSSQL\data\ILRAnalyser_Log.LDF')
CREATE DATABASE [ILRAnalyserNew3] ON PRIMARY (NAME = 'ILRAnalyser_Data', FILENAME = 'D:\MSSQL\Data\ILRAnalyserNew3.MDF') LOG ON (NAME = 'ILRAnalyser_Log', FILENAME = 'E:\MSSQL\data\ILRAnalyserNew3_1.LDF')
CREATE DATABASE [KPI_Reports] ON PRIMARY (NAME = 'Southwark_Reports', FILENAME = 'D:\MSSQL\Data\KPI_Reports.mdf') LOG ON (NAME = 'Southwark_Reports_log', FILENAME = 'E:\MSSQL\Data\KPI_Reports_1.ldf')
CREATE DATABASE [LAD] ON PRIMARY (NAME = 'LAD', FILENAME = 'D:\MSSQL\Data\LAD.mdf') LOG ON (NAME = 'LAD_log', FILENAME = 'E:\MSSQL\Data\LAD_log.LDF')
CREATE DATABASE [LIS_EXP] ON PRIMARY (NAME = 'LIS_EXP_YEAR16', FILENAME = 'D:\MSSQL\Data\LIS_EXP.mdf') LOG ON (NAME = 'LIS_EXP_YEAR16_log', FILENAME = 'E:\MSSQL\Data\LIS_EXP_1.ldf')
CREATE DATABASE [LIS_Warehouse] ON PRIMARY (NAME = 'LIS_Warehouse', FILENAME = 'D:\MSSQL\Data\LIS_Warehouse.mdf') LOG ON (NAME = 'LIS_Warehouse_log', FILENAME = 'E:\MSSQL\Data\LIS_Warehouse_1.ldf')
CREATE DATABASE [liz] ON PRIMARY (NAME = 'liz', FILENAME = 'D:\MSSQL\Data\liz.mdf') LOG ON (NAME = 'liz_log', FILENAME = 'E:\MSSQL\Data\liz_log.ldf')
CREATE DATABASE [Online_Forms] ON PRIMARY (NAME = 'Online_Forms', FILENAME = 'D:\MSSQL\Data\Online_Forms.mdf') LOG ON (NAME = 'Online_Forms_log', FILENAME = 'E:\MSSQL\Data\Online_Forms_log.ldf')
CREATE DATABASE [OnlineEnquiriesArchive] ON PRIMARY (NAME = 'OnlineEnquiriesArchive', FILENAME = 'D:\MSSQL\Data\OnlineEnquiriesArchive.mdf') LOG ON (NAME = 'OnlineEnquiriesArchive_log', FILENAME = 'E:\MSSQL\Data\OnlineEnquiriesArchive_log.ldf')
CREATE DATABASE [ProAchieve] ON PRIMARY (NAME = 'ProAchieve_Dat.mdf', FILENAME = 'D:\MSSQL\Data\ProAchieve_Dat.mdf') LOG ON (NAME = 'ProAchieve_Log.ldf', FILENAME = 'D:\MSSQL\Data\ProAchieve_Log.ldf')
CREATE DATABASE [Processed_Data] ON PRIMARY (NAME = 'Processed_Data', FILENAME = 'D:\MSSQL\Data\Processed_Data.mdf') LOG ON (NAME = 'Processed_Data_log', FILENAME = 'E:\MSSQL\Data\Processed_Data_log.ldf')
CREATE DATABASE [ProGeneral] ON PRIMARY (NAME = 'ProGeneral_Dat.mdf', FILENAME = 'D:\MSSQL\Data\ProGeneral_Dat.mdf') LOG ON (NAME = 'ProGeneral_Log.ldf', FILENAME = 'D:\MSSQL\Data\ProGeneral_Log.ldf')
CREATE DATABASE [QL] ON PRIMARY (NAME = 'qlpdat_Data', FILENAME = 'D:\MSSQL\Data\QL.mdf') LOG ON (NAME = 'qlpdat_Log', FILENAME = 'e:\mssql\data\QL.ldf')
CREATE DATABASE [qlfdat] ON PRIMARY (NAME = 'qlfdata', FILENAME = 'D:\MSSQL\Data\qlfdat.mdf') LOG ON (NAME = 'qlfLog', FILENAME = 'E:\MSSQL\Data\qlfdat.ldf')
CREATE DATABASE [qlpdat] ON PRIMARY (NAME = 'qlpdat_Data', FILENAME = 'D:\MSSQL\Data\qlpdat.MDF') LOG ON (NAME = 'qlpdat_Log', FILENAME = 'E:\MSSQL\Data\qlpdat.ldf')
CREATE DATABASE [qlsdat] ON PRIMARY (NAME = 'qlsdata', FILENAME = 'D:\MSSQL\Data\qlsdat.mdf') LOG ON (NAME = 'qlsLog', FILENAME = 'E:\MSSQL\Data\qlsdat.ldf')
CREATE DATABASE [QLxConnect] ON PRIMARY (NAME = 'QLxConnectData', FILENAME = 'D:\MSSQL\Data\QLxConnect.MDF') LOG ON (NAME = 'QLxConnectLog', FILENAME = 'E:\MSSQL\Data\QLxConnect.LDF')
CREATE DATABASE [RecruitmentArchive] ON PRIMARY (NAME = 'RecruitmentArchive', FILENAME = 'D:\MSSQL\Data\RecruitmentArchive.mdf') LOG ON (NAME = 'RecruitmentArchive_log', FILENAME = 'E:\MSSQL\Data\RecruitmentArchive_log.ldf')
CREATE DATABASE [SUSDB] ON PRIMARY (NAME = 'SUSDB', FILENAME = 'D:\MSSQL\Data\SUSDB.mdf') LOG ON (NAME = 'SUSDB_log', FILENAME = 'E:\MSSQL\Data\SUSDB_log.LDF')
CREATE DATABASE [Xcri] ON PRIMARY (NAME = 'Xcri', FILENAME = 'D:\MSSQL\Data\Xcri.mdf') LOG ON (NAME = 'Xcri_log', FILENAME = 'E:\MSSQL\Data\Xcri_log.ldf')


/*

Restore model, msdb, ReportServer, distribution

*/

RESTORE DATABASE Audit FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Audit.bak' WITH REPLACE, MOVE 'ErrorLog' TO 'D:\MSSQL\Data\ErrorLog.mdf', MOVE 'ErrorLog_log' TO 'E:\MSSQL\Data\ErrorLog_log.ldf'
RESTORE DATABASE distribution FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\distribution.bak' WITH REPLACE, MOVE 'distribution' TO 'D:\MSSQL\Data\distribution.MDF', MOVE 'distribution_log' TO 'E:\MSSQL\Data\distribution.LDF'

/* Shut service down */

RESTORE DATABASE msdb FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\msdb.bak' WITH REPLACE, MOVE 'MSDBData' TO 'D:\MSSQL\DATA\MSDBData.mdf', MOVE 'MSDBLog' TO 'E:\MSSQL\DATA\MSDBLog.ldf'

/* Shut service down */

RESTORE DATABASE ReportServer FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\ReportServer.bak' WITH REPLACE, MOVE 'ReportServer' TO 'D:\MSSQL\DATA\ReportServer.mdf', MOVE 'ReportServer_log' TO 'E:\MSSQL\DATA\ReportServer_log.ldf'

? ALTER DATABASE ReportServerTempDB MODIFY FILE( NAME = ReportServerTempDB, FILENAME = 'D:\MSSQL\DATA\ReportServerTempDB.mdf' )
? ALTER DATABASE ReportServerTempDB MODIFY FILE( NAME = ReportServerTempDB_log, FILENAME = 'E:\MSSQL\DATA\ReportServerTempDB_log.LDF' )


/*
  Physically Move ReportServerTemp files   ???

*/

/*
#  Stop the instance of SQL Server if it is started.
# Start the instance of SQL Server in master-only recovery mode by entering one of the following commands at the command prompt. The parameters specified in these commands are case sensitive. The commands fail when the parameters are not specified as shown.

    * For the default (MSSQLSERVER) instance, run the following command:

      NET START MSSQLSERVER /f /T3608

	  SSMS
	xxxxx Use	sqlcmd and enter following xxxxxx
*/

ALTER DATABASE model MODIFY FILE( NAME = modeldev, FILENAME = 'D:\MSSQL\DATA\model.mdf' )
ALTER DATABASE model MODIFY FILE( NAME = modellog, FILENAME = 'E:\MSSQL\DATA\modellog.ldf' )

/*
Physically Move the model files 
Restart Service

*/


/*
  IN SSMS
*/
RESTORE DATABASE model FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\model.bak' WITH REPLACE


/*

-m;Start the server instance in single-user mode. startup parameter (-m;)

or 

net start MSSQLSERVER /f /m

sqlcmd
*/

RESTORE DATABASE master FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\master.bak' WITH REPLACE

/* 
	Start Service
*/



/*
	Restore folder locations back to default
*/
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultData', REG_SZ, N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA'
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultLog', REG_SZ, N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA'
GO

/* ##############################  Got Here ################################ */

/*
	Move Model back to default
	
      NET START MSSQLSERVER /f /T3608

	SSMS
*/

ALTER DATABASE model MODIFY FILE( NAME = modeldev, FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\model.mdf' )
ALTER DATABASE model MODIFY FILE( NAME = modellog, FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\modellog.ldf' )

/*
	Physically Move model files
*/

RESTORE DATABASE [ASP_CONFIG] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\ASP_CONFIG.bak' WITH REPLACE, MOVE 'ASP_CONFIG' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ASP_CONFIG.mdf', MOVE 'ASP_CONFIG_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ASP_CONFIG_log.ldf'
RESTORE DATABASE [Audit] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Audit.bak' WITH REPLACE, MOVE 'ErrorLog' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ErrorLog.mdf', MOVE 'ErrorLog_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ErrorLog_log.ldf'
RESTORE DATABASE [Castle-Citrix-DB] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Castle-Citrix-DB.bak' WITH REPLACE, MOVE 'Castle-Citrix-DB' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Castle-Citrix-DB.mdf', MOVE 'Castle-Citrix-DB_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Castle-Citrix-DB_log.ldf'
RESTORE DATABASE [Census] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Census.bak' WITH REPLACE, MOVE 'Census' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Census.mdf', MOVE 'Census_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Census_log.ldf'
RESTORE DATABASE [Compliance_Audit] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Compliance_Audit.bak' WITH REPLACE, MOVE 'Compliance_Audit' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Compliance_Audit.mdf', MOVE 'Compliance_Audit_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Compliance_Audit_log.ldf'
RESTORE DATABASE [ConfigMgrDashboardSessionDB] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\ConfigMgrDashboardSessionDB.bak' WITH REPLACE, MOVE 'ConfigMgrDashboardSessionDB' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ConfigMgrDashboardSessionDB.mdf', MOVE 'ConfigMgrDashboardSessionDB_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ConfigMgrDashboardSessionDB_log.LDF'
RESTORE DATABASE [EBS] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\EBS.bak' WITH REPLACE, MOVE 'EBS' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\EBS.mdf', MOVE 'EBS_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\EBS_log.ldf'
RESTORE DATABASE [exams-citrix] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\exams-citrix.bak' WITH REPLACE, MOVE 'exams-citrix' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\exams-citrix.mdf', MOVE 'exams-citrix_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\exams-citrix_log.ldf'
RESTORE DATABASE [Funding_Analyser] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Funding_Analyser.bak' WITH REPLACE, MOVE 'Funding_Analyser' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Funding_Analyser.mdf', MOVE 'Funding_Analyser_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Funding_Analyser_log.ldf'
RESTORE DATABASE [ILRAnalyser] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\ILRAnalyser.bak' WITH REPLACE, MOVE 'ILRAnalyser_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ILRAnalyser_Data.MDF', MOVE 'ILRAnalyser_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ILRAnalyser_Log.LDF'
RESTORE DATABASE [ILRAnalyserNew3] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\ILRAnalyserNew3.bak' WITH REPLACE, MOVE 'ILRAnalyser_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ILRAnalyserNew3.MDF', MOVE 'ILRAnalyser_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ILRAnalyserNew3_1.LDF'
RESTORE DATABASE [KPI_Reports] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\KPI_Reports.bak' WITH REPLACE, MOVE 'Southwark_Reports' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\KPI_Reports.mdf', MOVE 'Southwark_Reports_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\KPI_Reports_1.ldf'
RESTORE DATABASE [LAD] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\LAD.bak' WITH REPLACE, MOVE 'LAD' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\LAD.mdf', MOVE 'LAD_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\LAD_log.LDF'
RESTORE DATABASE [LIS_EXP] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\LIS_EXP.bak' WITH REPLACE, MOVE 'LIS_EXP_YEAR16' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\LIS_EXP.mdf', MOVE 'LIS_EXP_YEAR16_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\LIS_EXP_1.ldf'
RESTORE DATABASE [LIS_Warehouse] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\LIS_Warehouse.bak' WITH REPLACE, MOVE 'LIS_Warehouse' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\LIS_Warehouse.mdf', MOVE 'LIS_Warehouse_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\LIS_Warehouse_1.ldf'
RESTORE DATABASE [liz] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\liz.bak' WITH REPLACE, MOVE 'liz' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\liz.mdf', MOVE 'liz_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\liz_log.ldf'
RESTORE DATABASE [Online_Forms] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Online_Forms.bak' WITH REPLACE, MOVE 'Online_Forms' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Online_Forms.mdf', MOVE 'Online_Forms_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Online_Forms_log.ldf'
RESTORE DATABASE [Online_Forms_Dev] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Online_Forms_Dev.bak' WITH REPLACE, MOVE 'Online_Forms' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Online_Forms_Dev.mdf', MOVE 'Online_Forms_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Online_Forms_Dev_1.ldf'
RESTORE DATABASE [OnlineEnquiriesArchive] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\OnlineEnquiriesArchive.bak' WITH REPLACE, MOVE 'OnlineEnquiriesArchive' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\OnlineEnquiriesArchive.mdf', MOVE 'OnlineEnquiriesArchive_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\OnlineEnquiriesArchive_log.ldf'
RESTORE DATABASE [ProAchieve] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\ProAchieve.bak' WITH REPLACE, MOVE 'ProAchieve_Dat.mdf' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ProAchieve_Dat.mdf', MOVE 'ProAchieve_Log.ldf' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ProAchieve_Log.ldf'
RESTORE DATABASE [Processed_Data] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Processed_Data.bak' WITH REPLACE, MOVE 'Processed_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Processed_Data.mdf', MOVE 'Processed_Data_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Processed_Data_log.ldf'
RESTORE DATABASE [ProGeneral] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\ProGeneral.bak' WITH REPLACE, MOVE 'ProGeneral_Dat.mdf' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ProGeneral_Dat.mdf', MOVE 'ProGeneral_Log.ldf' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ProGeneral_Log.ldf'
RESTORE DATABASE [QL] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\QL.bak' WITH REPLACE, MOVE 'qlpdat_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\QL.mdf', MOVE 'qlpdat_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\QL.ldf'
RESTORE DATABASE [qlfdat] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\qlfdat.bak' WITH REPLACE, MOVE 'qlfdata' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\qlfdat.mdf', MOVE 'qlfLog' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\qlfdat.ldf'
RESTORE DATABASE [qlpdat] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\qlpdat.bak' WITH REPLACE, MOVE 'qlpdat_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\qlpdat.MDF', MOVE 'qlpdat_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\qlpdat.ldf'
RESTORE DATABASE [qlsdat] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\qlsdat.bak' WITH REPLACE, MOVE 'qlsdata' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\qlsdat.mdf', MOVE 'qlsLog' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\qlsdat.ldf'
RESTORE DATABASE [QLxConnect] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\QLxConnect.bak' WITH REPLACE, MOVE 'QLxConnectData' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\QLxConnect.MDF', MOVE 'QLxConnectLog' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\QLxConnect.LDF'
RESTORE DATABASE [RecruitmentArchive] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\RecruitmentArchive.bak' WITH REPLACE, MOVE 'RecruitmentArchive' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\RecruitmentArchive.mdf', MOVE 'RecruitmentArchive_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\RecruitmentArchive_log.ldf'
RESTORE DATABASE [SUSDB] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\SUSDB.bak' WITH REPLACE, MOVE 'SUSDB' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\SUSDB.mdf', MOVE 'SUSDB_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\SUSDB_log.LDF'
RESTORE DATABASE [Xcri] FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\Xcri.bak' WITH REPLACE, MOVE 'Xcri' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Xcri.mdf', MOVE 'Xcri_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\Xcri_log.ldf'
/* Physically Move Files */


/* restoring again will put files in defualt location
*/

RESTORE DATABASE distribution FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\distribution.bak' WITH REPLACE, MOVE 'distribution' TO 'D:\MSSQL\Data\distribution.MDF', MOVE 'distribution_log' TO 'E:\MSSQL\Data\distribution.LDF'
RESTORE DATABASE msdb FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\msdb.bak' WITH REPLACE, MOVE 'MSDBData' TO 'D:\MSSQL\DATA\MSDBData.mdf', MOVE 'MSDBLog' TO 'E:\MSSQL\DATA\MSDBLog.ldf'

/* Shut service down */

RESTORE DATABASE ReportServer FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\ReportServer.bak' WITH REPLACE, MOVE 'ReportServer' TO 'D:\MSSQL\DATA\ReportServer.mdf', MOVE 'ReportServer_log' TO 'E:\MSSQL\DATA\ReportServer_log.ldf'



/*
To move a system database data or log file as part of a planned relocation or scheduled maintenance operation, follow these steps. This procedure applies to all system databases except the master and Resource databases.
*/
/*
ALTER DATABASE model MODIFY FILE (NAME=modeldev, FILENAME = 'D:\MSSQL\Data\model.mdf')
ALTER DATABASE model MODIFY FILE (NAME=modellog, FILENAME = 'D:\MSSQL\Data\modellog.ldf')
*/

/*
RESTORE DATABASE model FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\model.bak' WITH REPLACE, MOVE 'modeldev' TO 'D:\MSSQL\Data\model.mdf', MOVE 'modellog' TO 'E:\MSSQL\Data\modellog.ldf';

RESTORE DATABASE msdb FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\msdb.bak' WITH REPLACE
--RESTORE DATABASE tempdb FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\tempdb.bak' WITH REPLACE
RESTORE DATABASE ReportServer FROM DISK = '\\VBOXSVR\Backups_SQL02\Databases\reportserver.bak' WITH REPLACE
*/
