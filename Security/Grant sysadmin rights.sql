USE [master]
GO
CREATE LOGIN [CENTRE1\Vilius.Zybertas] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
EXEC master..sp_addsrvrolemember @loginame = N'CENTRE1\Vilius.Zybertas', @rolename = N'sysadmin'
GO


USE [master]
GO
EXEC master.dbo.sp_grantlogin @loginame = N'CENTRE1\Vilius.Zybertas'
EXEC master.dbo.sp_defaultdb @loginame = N'CENTRE1\Vilius.Zybertas', @defdb = N'master'
EXEC master.dbo.sp_defaultlanguage @loginame = N'CENTRE1\Vilius.Zybertas'
GO
EXEC master..sp_addsrvrolemember @loginame = N'CENTRE1\Vilius.Zybertas', @rolename = N'sysadmin'
GO
