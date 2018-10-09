-- http://www.sql-server-performance.com/2012/recovery-sql-server-suspect-mode/

EXEC sp_resetstatus 'DAF_Truck-Link_Satellite1_VL';

ALTER DATABASE [DAF_Truck-Link_Satellite1_VL] SET EMERGENCY

--DBCC CHECKDB('AutoPublish_DAF');

ALTER DATABASE [DAF_Truck-Link_Satellite1_VL] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

DBCC CHECKDB ([DAF_Truck-Link_Satellite1_VL], REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS; -- can rebuild log file

ALTER DATABASE [DAF_Truck-Link_Satellite1_VL] SET MULTI_USER;

/* Technique used by Steria on SQL Server 2008 R2 express, database set to compatibility 2000 (INC2966094) 

1 change the db into emergency mode 
2 Stop the MSSQLSERVER service. 
3. Rename the existing LOG file 
4. Start the MSSQLSERVER service 
4.REBUILD_LOG 

*/
