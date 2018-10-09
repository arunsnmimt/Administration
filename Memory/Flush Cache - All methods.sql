-- Example 1 (Sledgehammer)
-- Remove all elements from the plan cache for the entire instance 
DBCC FREEPROCCACHE;

-- Flush the cache and suppress the regular completion message
-- "DBCC execution completed. If DBCC printed error messages, contact your system administrator." 
DBCC FREEPROCCACHE WITH NO_INFOMSGS;


-- Example 2 (Ballpeen hammer)
-- Remove all elements from the plan cache for one database  
-- Get DBID from one database name first
DECLARE @intDBID INT;
SET @intDBID = (SELECT [dbid] 
                FROM master.dbo.sysdatabases 
                WHERE name = 'PharmacyDashBoard');

-- Flush the procedure cache for one database only
DBCC FLUSHPROCINDB (@intDBID);

-- Example 2a
-- Causes stored procedures and triggers to be recompiled the next time they are run. 

EXEC sp_recompile 'dbo.tbl_ConsignmentHeader' -- Is the qualified or unqualified name of a stored procedure, trigger, table, or view in the current database


-- Example 3 (Scalpel)
-- Remove one plan from the cache
-- Get the plan handle for a cached plan
SELECT cp.plan_handle, st.[text]
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE [text] LIKE N'%/* GetOnlineSearchResultsMonday %';

-- Remove the specific plan from the cache using the plan handle
--DBCC FREEPROCCACHE (0x06000E00E971543A402151CB150000000000000000000000)
DBCC FREEPROCCACHE (0x05000A00A23DE37F404126310A0000000000000000000000)
DBCC FREEPROCCACHE (0x05000A00A23DE37F40A1DB9C080000000000000000000000)
--DBCC FREEPROCCACHE (0x050008004508CD5540019773030000000000000000000000)
--DBCC FREEPROCCACHE (0x05003300CED1B6664081A8D0050000000000000000000000)
--DBCC FREEPROCCACHE (0x050033009953CF1F4021253A0A0000000000000000000000)



