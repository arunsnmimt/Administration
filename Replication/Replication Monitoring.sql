sp_replmonitorhelppublisher

USE distribution
GO

sp_replmonitorhelppublication @publisher = 'SQLCluster05'
GO

sp_replmonitorhelpsubscription @publisher =  'SQLCluster05', @publication_type = 0
GO

sp_replmonitorsubscriptionpendingcmds  @publisher =  'SQLCluster05',  @publisher_db = 'JCB_live_Link_SATELLITE1_CHINA', @publication = 'JCB_CHINA', @subscriber = 'WINDOWS-J8FE64P', @subscriber_db = 'JCB_China_Satellite1', @subscription_type = 0
GO

sp_replmonitorhelppublicationthresholds  @publisher =  'SQLCluster05', @publisher_db = 'JCB_live_Link_SATELLITE1_CHINA', @publication = 'JCB_CHINA'
GO

-- sp_replmonitorchangepublicationthreshold

USE distribution
SELECT * FROM sys.dm_os_performance_counters WHERE OBJECT_NAME LIKE '%Replica%'
AND counter_name LIKE '%Logreader:%latency%'

SELECT *  FROM sys.dm_os_performance_counters WHERE OBJECT_NAME LIKE '%Replica%'
AND counter_name LIKE '%Dist%latency%'