CREATE TRIGGER CreateDatabaseTrigger
ON ALL SERVER 
FOR CREATE_DATABASE 
AS 
	RAISERROR ('This server is at maximum capacity and the creation of the new database has been aborted. Please contact the DBA team for further assistance.', 16, 1);
	ROLLBACK TRANSACTION;
GO


--DROP TRIGGER ddl_trig_database
--ON ALL SERVER;
--GO