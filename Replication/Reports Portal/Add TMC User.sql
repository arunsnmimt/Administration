-- To be run against both STAGING and DW databases
USE [TMC_XXXX_RP_STAGING]
GO
CREATE USER [TMC] FOR LOGIN [TMC]
GO
EXEC sp_addrolemember N'db_datareader', N'TMC'
GO
EXEC sp_addrolemember N'db_datawriter', N'TMC'
GO
EXEC sp_addrolemember N'db_executor', N'TMC'
GO


USE [TMC_XXXX_RP_DW]
GO
CREATE USER [TMC] FOR LOGIN [TMC]
GO
EXEC sp_addrolemember N'db_datareader', N'TMC'
GO
EXEC sp_addrolemember N'db_datawriter', N'TMC'
GO
EXEC sp_addrolemember N'db_executor', N'TMC'
GO