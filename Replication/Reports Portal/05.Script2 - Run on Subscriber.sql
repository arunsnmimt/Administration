--To be run on the Staging Database after subscription has been set-up 
-- and transactions are being replicated
--     ============
  


EXECUTE [dbo].[pr_replic_InitializeSubscription_Post] 
GO
