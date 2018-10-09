DECLARE @intDBID INT;
SET @intDBID = (SELECT [dbid] 
                FROM master.dbo.sysdatabases 
                WHERE name = 'TMC_TESCO_COM_UAT');

-- Flush the procedure cache for one database only
DBCC FLUSHPROCINDB (@intDBID)
