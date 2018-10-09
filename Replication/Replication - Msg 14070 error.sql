/*
-- Connect Subscriber
use [master]
exec sp_helpreplicationdboption @dbname = N'MyReplDB'
go
use [MyReplDB]
exec sp_subscription_cleanup @publisher = N'TestPubSQL1', @publisher_db = N'MyReplDB', 
@publication = N'MyReplPub'
go
*/
-- Connect Publisher Server
-- Drop Subscription

/*
Msg 20032, Level 16, State 1, Procedure sp_MSdrop_subscription, Line 85
'SQLRPVS01' is not defined as a Subscriber for 'SQLVS19'.
Msg 14070, Level 16, State 1, Procedure sp_MSrepl_changesubstatus, Line 1232
Could not update the distribution database subscription table. The subscription status could not be changed.

use @ignore_distributor parameter for sp_dropsubscription proc
*/


use [TMC_EDDIE_STOBART]
exec sp_dropsubscription @publication = N'TMC_Eddie_Stobart_Pub', @subscriber = N'all', 
@destination_db = N'TMC_BIDVEST_UAT_STAGING', @article = N'all', @ignore_distributor = 1 --use @ignore_distributor parameter for sp_dropsubscription proc
go
-- Drop publication
exec sp_droppublication @publication = N'TMC_Eddie_Stobart_Pub'
-- Disable replication db option
--exec sp_replicationdboption @dbname = N'MyReplDB', @optname = N'publish', @value = N'false'
--GO