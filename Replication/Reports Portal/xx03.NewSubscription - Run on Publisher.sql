/*

Search and Replace the following

TMC_<Database>  with the TMC database name

<Server> with the Distribution server name e.g SQLVS25

<Publication Name> with the Publication Name  -- e.g Microlise_TMC_<Database>_RP_Pub

TMC_<Staging_DB> with the name of the Staging database.

*/



-----------------BEGIN: Script to be run at Publisher -----------------
use [TMC_<Database>]
exec sp_addsubscription @publication = N'<Publication Name>', @subscriber = N'<Server>', @destination_db = N'TMC_<Staging_DB>', @subscription_type = N'Push', @sync_type = N'automatic', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'<Publication Name>', @subscriber = N'<Server>', @subscriber_db = N'TMC_<Staging_DB>', @job_login = N'MMS\sqladmin', @job_password = 'S3cretsql', @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20140804, @active_end_date = 99991231, @enabled_for_syncmgr = N'False', @dts_package_location = N'Distributor'
GO
-----------------END: Script to be run at Publisher -----------------



