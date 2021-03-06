/*

Search and Replace the following

TMC_<Database>  with the TMC database name

<Server> with the publishers server name

<Publication Name> with the Publication Name  -- e.g Microlise_TMC_<Database>_RP_Pub

*/



use [TMC_<Database>]
exec sp_replicationdboption @dbname = N'TMC_<Database>', @optname = N'publish', @value = N'true'
GO
use [TMC_<Database>]
exec [TMC_<Database>].sys.sp_addlogreader_agent @job_login = N'MMS\sqladmin', @job_password = 'S3cretsql', @publisher_security_mode = 1, @job_name = null
GO
-- Adding the transactional publication
use [TMC_<Database>]
exec sp_addpublication @publication = N'<Publication Name>', @description = N'Transactional publication of database ''TMC_<Database>'' from Publisher ''<Server>''.', @sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', @independent_agent = N'true', @immediate_sync = N'true', @allow_sync_tran = N'false', @autogen_sync_procs = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 1, @allow_initialize_from_backup = N'false', @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'
GO


exec sp_addpublication_snapshot @publication = N'<Publication Name>', @frequency_type = 1, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = N'MMS\sqladmin', @job_password = 'S3cretsql', @publisher_security_mode = 1


use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_BusinessRules', @source_owner = N'dbo', @source_object = N'tbl_BusinessRules', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_BusinessRules', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_BusinessRules', @del_cmd = N'CALL sp_MSdel_dbotbl_BusinessRules', @upd_cmd = N'SCALL sp_MSupd_dbotbl_BusinessRules'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ConfirmationStatus', @source_owner = N'dbo', @source_object = N'tbl_ConfirmationStatus', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ConfirmationStatus', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ConfirmationStatus', @del_cmd = N'CALL sp_MSdel_dbotbl_ConfirmationStatus', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ConfirmationStatus'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ConfirmedTimesSource', @source_owner = N'dbo', @source_object = N'tbl_ConfirmedTimesSource', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ConfirmedTimesSource', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ConfirmedTimesSource', @del_cmd = N'CALL sp_MSdel_dbotbl_ConfirmedTimesSource', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ConfirmedTimesSource'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ConsignmentDetail', @source_owner = N'dbo', @source_object = N'tbl_ConsignmentDetail', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ConsignmentDetail', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ConsignmentDetail', @del_cmd = N'CALL sp_MSdel_dbotbl_ConsignmentDetail', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ConsignmentDetail'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ConsignmentHeader', @source_owner = N'dbo', @source_object = N'tbl_ConsignmentHeader', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ConsignmentHeader', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ConsignmentHeader', @del_cmd = N'CALL sp_MSdel_dbotbl_ConsignmentHeader', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ConsignmentHeader'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ConsignmentSite', @source_owner = N'dbo', @source_object = N'tbl_ConsignmentSite', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ConsignmentSite', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ConsignmentSite', @del_cmd = N'CALL sp_MSdel_dbotbl_ConsignmentSite', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ConsignmentSite'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Country', @source_owner = N'dbo', @source_object = N'tbl_Country', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Country', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Country', @del_cmd = N'CALL sp_MSdel_dbotbl_Country', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Country'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Department', @source_owner = N'dbo', @source_object = N'tbl_Department', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Department', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Department', @del_cmd = N'CALL sp_MSdel_dbotbl_Department', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Department'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Drivers', @source_owner = N'dbo', @source_object = N'tbl_Drivers', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Drivers', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Drivers', @del_cmd = N'CALL sp_MSdel_dbotbl_Drivers', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Drivers'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_DropPoints', @source_owner = N'dbo', @source_object = N'tbl_DropPoints', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_DropPoints', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_DropPoints', @del_cmd = N'CALL sp_MSdel_dbotbl_DropPoints', @upd_cmd = N'SCALL sp_MSupd_dbotbl_DropPoints'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_EmployeeType', @source_owner = N'dbo', @source_object = N'tbl_EmployeeType', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_EmployeeType', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_EmployeeType', @del_cmd = N'CALL sp_MSdel_dbotbl_EmployeeType', @upd_cmd = N'SCALL sp_MSupd_dbotbl_EmployeeType'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_GroupDefinition', @source_owner = N'dbo', @source_object = N'tbl_GroupDefinition', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_GroupDefinition', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_GroupDefinition', @del_cmd = N'CALL sp_MSdel_dbotbl_GroupDefinition', @upd_cmd = N'SCALL sp_MSupd_dbotbl_GroupDefinition'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_GroupJourneys', @source_owner = N'dbo', @source_object = N'tbl_GroupJourneys', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_GroupJourneys', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_GroupJourneys', @del_cmd = N'CALL sp_MSdel_dbotbl_GroupJourneys', @upd_cmd = N'SCALL sp_MSupd_dbotbl_GroupJourneys'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Haulier', @source_owner = N'dbo', @source_object = N'tbl_Haulier', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Haulier', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Haulier', @del_cmd = N'CALL sp_MSdel_dbotbl_Haulier', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Haulier'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_images', @source_owner = N'dbo', @source_object = N'tbl_images', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_images', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_images', @del_cmd = N'CALL sp_MSdel_dbotbl_images', @upd_cmd = N'SCALL sp_MSupd_dbotbl_images'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_JourneyDropActivitySource', @source_owner = N'dbo', @source_object = N'tbl_JourneyDropActivitySource', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_JourneyDropActivitySource', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_JourneyDropActivitySource', @del_cmd = N'CALL sp_MSdel_dbotbl_JourneyDropActivitySource', @upd_cmd = N'SCALL sp_MSupd_dbotbl_JourneyDropActivitySource'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_JourneyDropActivityType', @source_owner = N'dbo', @source_object = N'tbl_JourneyDropActivityType', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_JourneyDropActivityType', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_JourneyDropActivityType', @del_cmd = N'CALL sp_MSdel_dbotbl_JourneyDropActivityType', @upd_cmd = N'SCALL sp_MSupd_dbotbl_JourneyDropActivityType'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_JourneyDropReportingGroupHierarchySnapshot', @source_owner = N'dbo', @source_object = N'tbl_JourneyDropReportingGroupHierarchySnapshot', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_JourneyDropReportingGroupHierarchySnapshot', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_JourneyDropReportingGroupHierarchySnapshot', @del_cmd = N'CALL sp_MSdel_dbotbl_JourneyDropReportingGroupHierarchySnapshot', @upd_cmd = N'SCALL sp_MSupd_dbotbl_JourneyDropReportingGroupHierarchySnapshot'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_JourneyDropResource', @source_owner = N'dbo', @source_object = N'tbl_JourneyDropResource', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_JourneyDropResource', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_JourneyDropResource', @del_cmd = N'CALL sp_MSdel_dbotbl_JourneyDropResource', @upd_cmd = N'SCALL sp_MSupd_dbotbl_JourneyDropResource'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_JourneyDrops', @source_owner = N'dbo', @source_object = N'tbl_JourneyDrops', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_JourneyDrops', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_JourneyDrops', @del_cmd = N'CALL sp_MSdel_dbotbl_JourneyDrops', @upd_cmd = N'SCALL sp_MSupd_dbotbl_JourneyDrops'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_JourneyDropSystemEvent', @source_owner = N'dbo', @source_object = N'tbl_JourneyDropSystemEvent', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_JourneyDropSystemEvent', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_JourneyDropSystemEvent', @del_cmd = N'CALL sp_MSdel_dbotbl_JourneyDropSystemEvent', @upd_cmd = N'SCALL sp_MSupd_dbotbl_JourneyDropSystemEvent'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Journeys', @source_owner = N'dbo', @source_object = N'tbl_Journeys', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Journeys', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Journeys', @del_cmd = N'CALL sp_MSdel_dbotbl_Journeys', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Journeys'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_MDTs', @source_owner = N'dbo', @source_object = N'tbl_MDTs', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_MDTs', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_MDTs', @del_cmd = N'CALL sp_MSdel_dbotbl_MDTs', @upd_cmd = N'SCALL sp_MSupd_dbotbl_MDTs'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Notations', @source_owner = N'dbo', @source_object = N'tbl_Notations', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Notations', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Notations', @del_cmd = N'CALL sp_MSdel_dbotbl_Notations', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Notations'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_PODClauseLookup', @source_owner = N'dbo', @source_object = N'tbl_PODClauseLookup', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_PODClauseLookup', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_PODClauseLookup', @del_cmd = N'CALL sp_MSdel_dbotbl_PODClauseLookup', @upd_cmd = N'SCALL sp_MSupd_dbotbl_PODClauseLookup'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ProductType', @source_owner = N'dbo', @source_object = N'tbl_ProductType', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ProductType', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ProductType', @del_cmd = N'CALL sp_MSdel_dbotbl_ProductType', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ProductType'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_PunctualityStatus', @source_owner = N'dbo', @source_object = N'tbl_PunctualityStatus', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_PunctualityStatus', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_PunctualityStatus', @del_cmd = N'CALL sp_MSdel_dbotbl_PunctualityStatus', @upd_cmd = N'SCALL sp_MSupd_dbotbl_PunctualityStatus'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Region', @source_owner = N'dbo', @source_object = N'tbl_Region', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Region', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Region', @del_cmd = N'CALL sp_MSdel_dbotbl_Region', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Region'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ReportingGroup', @source_owner = N'dbo', @source_object = N'tbl_ReportingGroup', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ReportingGroup', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ReportingGroup', @del_cmd = N'CALL sp_MSdel_dbotbl_ReportingGroup', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ReportingGroup'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ReportingGroupHierarchy', @source_owner = N'dbo', @source_object = N'tbl_ReportingGroupHierarchy', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ReportingGroupHierarchy', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ReportingGroupHierarchy', @del_cmd = N'CALL sp_MSdel_dbotbl_ReportingGroupHierarchy', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ReportingGroupHierarchy'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ReportingGroupHierarchyLevel', @source_owner = N'dbo', @source_object = N'tbl_ReportingGroupHierarchyLevel', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ReportingGroupHierarchyLevel', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ReportingGroupHierarchyLevel', @del_cmd = N'CALL sp_MSdel_dbotbl_ReportingGroupHierarchyLevel', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ReportingGroupHierarchyLevel'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_ResourceCalendar', @source_owner = N'dbo', @source_object = N'tbl_ResourceCalendar', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_ResourceCalendar', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_ResourceCalendar', @del_cmd = N'CALL sp_MSdel_dbotbl_ResourceCalendar', @upd_cmd = N'SCALL sp_MSupd_dbotbl_ResourceCalendar'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Resources', @source_owner = N'dbo', @source_object = N'tbl_Resources', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Resources', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Resources', @del_cmd = N'CALL sp_MSdel_dbotbl_Resources', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Resources'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_RouteClasses', @source_owner = N'dbo', @source_object = N'tbl_RouteClasses', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_RouteClasses', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_RouteClasses', @del_cmd = N'CALL sp_MSdel_dbotbl_RouteClasses', @upd_cmd = N'SCALL sp_MSupd_dbotbl_RouteClasses'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_SiteCategories', @source_owner = N'dbo', @source_object = N'tbl_SiteCategories', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_SiteCategories', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_SiteCategories', @del_cmd = N'CALL sp_MSdel_dbotbl_SiteCategories', @upd_cmd = N'SCALL sp_MSupd_dbotbl_SiteCategories'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_SiteType', @source_owner = N'dbo', @source_object = N'tbl_SiteType', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_SiteType', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_SiteType', @del_cmd = N'CALL sp_MSdel_dbotbl_SiteType', @upd_cmd = N'SCALL sp_MSupd_dbotbl_SiteType'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Status', @source_owner = N'dbo', @source_object = N'tbl_Status', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Status', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Status', @del_cmd = N'CALL sp_MSdel_dbotbl_Status', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Status'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_SystemEvents', @source_owner = N'dbo', @source_object = N'tbl_SystemEvents', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_SystemEvents', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_SystemEvents', @del_cmd = N'CALL sp_MSdel_dbotbl_SystemEvents', @upd_cmd = N'SCALL sp_MSupd_dbotbl_SystemEvents', @filter_clause = N'[RULEID] IN 
(''JEDI'',''LEDI'',''JIDI'',''LIDI'',''SEQ'',''CLD'',''CED'',''CTLA'',''CTEA'',''JEDU'',''LEDU'',''JIDU'',''LIDU'', ''EJ'', ''JLF'')'

-- Adding the article filter
exec sp_articlefilter @publication = N'<Publication Name>', @article = N'tbl_SystemEvents', @filter_name = N'FLTR_tbl_SystemEvents_1__107', @filter_clause = N'[RULEID] IN 
(''JEDI'',''LEDI'',''JIDI'',''LIDI'',''SEQ'',''CLD'',''CED'',''CTLA'',''CTEA'',''JEDU'',''LEDU'',''JIDU'',''LIDU'', ''EJ'', ''JLF'')', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'<Publication Name>', @article = N'tbl_SystemEvents', @view_name = N'SYNC_tbl_SystemEvents_1__107', @filter_clause = N'[RULEID] IN 
(''JEDI'',''LEDI'',''JIDI'',''LIDI'',''SEQ'',''CLD'',''CED'',''CTLA'',''CTEA'',''JEDU'',''LEDU'',''JIDU'',''LIDU'', ''EJ'', ''JLF'')', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_TemperatureAlerts', @source_owner = N'dbo', @source_object = N'tbl_TemperatureAlerts', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_TemperatureAlerts', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_TemperatureAlerts', @del_cmd = N'CALL sp_MSdel_dbotbl_TemperatureAlerts', @upd_cmd = N'SCALL sp_MSupd_dbotbl_TemperatureAlerts'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_TemperatureAudit', @source_owner = N'dbo', @source_object = N'tbl_TemperatureAudit', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_TemperatureAudit', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_TemperatureAudit', @del_cmd = N'CALL sp_MSdel_dbotbl_TemperatureAudit', @upd_cmd = N'SCALL sp_MSupd_dbotbl_TemperatureAudit'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_TrackerEvents', @source_owner = N'dbo', @source_object = N'tbl_TrackerEvents', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_TrackerEvents', @destination_owner = N'dbo', @vertical_partition = N'true', @ins_cmd = N'CALL sp_MSins_dbotbl_TrackerEvents', @del_cmd = N'CALL sp_MSdel_dbotbl_TrackerEvents', @upd_cmd = N'SCALL sp_MSupd_dbotbl_TrackerEvents'

-- Adding the article's partition column(s)
exec sp_articlecolumn @publication = N'<Publication Name>', @article = N'tbl_TrackerEvents', @column = N'TrackerEventID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'<Publication Name>', @article = N'tbl_TrackerEvents', @column = N'Speed', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'<Publication Name>', @article = N'tbl_TrackerEvents', @column = N'SiteID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'<Publication Name>', @article = N'tbl_TrackerEvents', @column = N'LocationDescription', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'<Publication Name>', @article = N'tbl_TrackerEvents', @column = N'CBSpeed', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'<Publication Name>', @article = N'tbl_TrackerEvents', @view_name = N'SYNC_tbl_TrackerEvents_1__107', @filter_clause = null, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Users', @source_owner = N'dbo', @source_object = N'tbl_Users', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Users', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Users', @del_cmd = N'CALL sp_MSdel_dbotbl_Users', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Users'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_VehicleLeg', @source_owner = N'dbo', @source_object = N'tbl_VehicleLeg', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_VehicleLeg', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_VehicleLeg', @del_cmd = N'CALL sp_MSdel_dbotbl_VehicleLeg', @upd_cmd = N'SCALL sp_MSupd_dbotbl_VehicleLeg'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_VehicleMovementSummary', @source_owner = N'dbo', @source_object = N'tbl_VehicleMovementSummary', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_VehicleMovementSummary', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_VehicleMovementSummary', @del_cmd = N'CALL sp_MSdel_dbotbl_VehicleMovementSummary', @upd_cmd = N'SCALL sp_MSupd_dbotbl_VehicleMovementSummary'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_VehicleProfile', @source_owner = N'dbo', @source_object = N'tbl_VehicleProfile', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_VehicleProfile', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_VehicleProfile', @del_cmd = N'CALL sp_MSdel_dbotbl_VehicleProfile', @upd_cmd = N'SCALL sp_MSupd_dbotbl_VehicleProfile'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_Vehicles', @source_owner = N'dbo', @source_object = N'tbl_Vehicles', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_Vehicles', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_Vehicles', @del_cmd = N'CALL sp_MSdel_dbotbl_Vehicles', @upd_cmd = N'SCALL sp_MSupd_dbotbl_Vehicles'
GO




use [TMC_<Database>]
exec sp_addarticle @publication = N'<Publication Name>', @article = N'tbl_VehicleSpeedProfile', @source_owner = N'dbo', @source_object = N'tbl_VehicleSpeedProfile', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tbl_VehicleSpeedProfile', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotbl_VehicleSpeedProfile', @del_cmd = N'CALL sp_MSdel_dbotbl_VehicleSpeedProfile', @upd_cmd = N'SCALL sp_MSupd_dbotbl_VehicleSpeedProfile'
GO




