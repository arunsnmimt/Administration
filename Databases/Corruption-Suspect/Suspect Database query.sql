-- Determine the original database status
SELECT [Name], DBID, Status
FROM master.dbo.sysdatabases 
GO

-- Enable system changes
sp_configure 'allow updates',1
GO
RECONFIGURE WITH OVERRIDE
GO

-- Update the database status
UPDATE master.dbo.sysdatabases 
SET Status = 24 
WHERE [Name] = 'dbMeetings'
GO

-- Disable system changes
sp_configure 'allow updates',0
GO
RECONFIGURE WITH OVERRIDE
GO

-- Determine the final database status
SELECT [Name], DBID, Status
FROM master.dbo.sysdatabases 
GO

--dbMeetings	72	272
DBCC CHECKDB ('dbMeetings')
DBCC CHECKCATALOG  ('dbMeetings')
