USE Processed_Data

/*
When true, a checkpoint truncates the inactive part of the log when the database is in log truncate mode. 
This is the only option that you can set for the master database.

Important:  
Starting with SQL Server 2000, setting the trunc. log on chkpt. option to true sets the recovery model of the database to SIMPLE. 
Setting the option to false sets the recovery model to FULL. 
*/

--sp_dboption 'distribution', 'trunc. log on chkpt.', FALSE 

SELECT name, physical_name FROM sys.database_files

BACKUP LOG Processed_Data WITH TRUNCATE_ONLY 

--Create a temp table to create bogus transactions
CREATE TABLE t1(f1 INT)
GO

--Load the temp table. This will cause the transaction log to to fill a tiny bit.
--Enough so you can checkpoint, and shrink the tran log.
DECLARE @i INT

SET @i= 1

WHILE @i < 10000
BEGIN
INSERT t1
SELECT @i

SET @i = @i + 1
END

UPDATE t1
SET f1 = f1 + 1
GO

--To get the logical name of the tlog file just use sp_helpfile under the database you want to shrink.
--DBCC SHRINKFILE(distribution_Log, 100)
DBCC SHRINKFILE(Processed_Data_log, 150)
GO

--Truncate the log again. This will cause the file to shrink.
BACKUP LOG Processed_Data WITH TRUNCATE_ONLY
GO

--Reactivate auto truncate
/*
When true, a checkpoint truncates the inactive part of the log when the database is in log truncate mode. 
This is the only option that you can set for the master database.

Important:  
Starting with SQL Server 2000, setting the trunc. log on chkpt. option to true sets the recovery model of the database to SIMPLE. 
Setting the option to false sets the recovery model to FULL. 
*/

--sp_dboption 'distribution', 'trunc. log on chkpt.', TRUE
--GO

--Drop the temp table
DROP TABLE t1
GO 

--sp_dboption 'Processed_Data'