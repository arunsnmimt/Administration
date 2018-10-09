-- log_reuse_wait_desc = replication database not setup for replication

SELECT name, log_reuse_wait_desc FROM sys.databases  --log_reuse_wait_desc = Replication

-- Force removal of the replication (must have been caused during a restore at some point).

EXEC sp_removedbreplication TMC_TESCO_UK_ED

 -- Reran the following:

SELECT name, log_reuse_wait_desc FROM sys.databases 

-- Forced to Simple Recovery (just to make sure):

ALTER DATABASE msdb SET RECOVERY SIMPLE