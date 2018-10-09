USE [master]
GO

-- SQL Server 2005 or greater 

CREATE LOGIN [CENTRE1\michael.giles] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [CENTRE1\Sreekanth.Madambath] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [CENTRE1\Richard.Gnanamuttu] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [CENTRE1\Vimal.Kochiyil] FROM WINDOWS WITH DEFAULT_DATABASE=[master]

-- SQL Server 2000

/*
EXEC master..sp_grantlogin [CENTRE1\michael.giles]  
EXEC master..sp_grantlogin [CENTRE1\Sreekanth.Madambath]  
EXEC master..sp_grantlogin [CENTRE1\Richard.Gnanamuttu]  
EXEC master..sp_grantlogin [CENTRE1\Vimal.Kochiyil]  
*/

EXEC master..sp_addsrvrolemember @loginame = N'CENTRE1\michael.giles', @rolename = N'sysadmin'
EXEC master..sp_addsrvrolemember @loginame = N'CENTRE1\Sreekanth.Madambath', @rolename = N'sysadmin'
EXEC master..sp_addsrvrolemember @loginame = N'CENTRE1\Richard.Gnanamuttu', @rolename = N'sysadmin'
EXEC master..sp_addsrvrolemember @loginame = N'CENTRE1\Vimal.Kochiyil', @rolename = N'sysadmin'
