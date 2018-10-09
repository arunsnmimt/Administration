-- Remove replication objects where publication does not exist


DECLARE @publicationDB AS sysname;
DECLARE @publication AS sysname;
SET @publicationDB = N'TMC_EDDIE_STOBART'; 
--SET @publication = N'AdvWorksProductTran'; 

-- Remove a transactional publication.
--USE [AdventureWorks]
--EXEC sp_droppublication @publication = @publication;

-- Remove replication objects from the database.
USE [master]
EXEC sp_replicationdboption 
  @dbname = @publicationDB, 
  @optname = N'publish', 
  @value = N'false';
GO

