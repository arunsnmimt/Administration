/* ProAchive SQL Server 2000
	Unable to rename ProAchive database. Error message says that it was being used for replication but
	there is no publication or articles relating to ProAchieve.
	Entry in sysdatabase for ProAchieve has a category of 1 (Published for snapshot or transactional replication.)

	Changed this to zero to overcome orphaned replication problem
*/
USE [master]

SELECT * FROM sysdatabases
WHERE name = 'ProAchieve'

sp_configure 'allow updates', 1
GO
RECONFIGURE WITH override
GO

BEGIN TRANSACTION


UPDATE sysdatabases
SET category = 0
WHERE name = 'ProAchieve'

/*
	Verify that only one row was affected. If the intended row in the sysobjects table was updated, 
	commit the transaction, or roll back the transaction by using the following appropriate command: 
*/
ROLLBACK TRANSACTION
GO
-- or
COMMIT TRANSACTION
GO

sp_configure 'allow updates', 0
GO
RECONFIGURE WITH override
GO

