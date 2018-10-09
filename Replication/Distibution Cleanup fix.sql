-- Source  http://www.replicationanswers.com/TransactionalOptimisation.asp

-- To Be run from the TMC database on the Publication Server

-- Check to see if "immediate sync" is set to 1.
--  This will cause transactions to be held in MSRepl_commands 
-- rather than deleted when distributed. 
exec dbo.sp_helppublication @publication = '' -- put your publication name here 

-- How to alter the setting to 0. 
EXEC sp_changepublication 
    @publication = '', -- put your publication name here 
    @property = 'allow_anonymous', 
    @value = 'false' 
GO 

EXEC sp_changepublication 
    @publication = '', -- put your publication name here 
    @property = 'immediate_sync', 
    @value = 'false' 
GO 

-- To be run on the Distribution server

Select * from distribution.dbo.MSsubscriptions 
where subscriber_db = 'virtual'					 --will show no virtual subscriptions.



