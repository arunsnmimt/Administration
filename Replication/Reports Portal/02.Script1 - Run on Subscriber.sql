--To be run on the Staging Database before the publication is created.
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'dbo.vw_JourneyDropReportingGroup')) OR
    EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'reports.vw_JourneyDropReportingHierarchy'))
   EXECUTE [dbo].[pr_replic_InitializeSubscription_Pre]
GO


