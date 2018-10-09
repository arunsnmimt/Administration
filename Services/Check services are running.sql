EXEC xp_servicecontrol N'querystate',N'MsDtsServer' --N'MsDtsServer100' --(2008) --N'MsDtsServer120 --(2014)'
EXEC xp_servicecontrol N'querystate',N'MSSQLServer'
EXEC xp_servicecontrol N'querystate',N'ReportServer'


EXEC xp_servicecontrol N'querystate',N'MSSQLServer'
EXEC xp_servicecontrol N'querystate',N'SQLServerAGENT'
EXEC xp_servicecontrol N'querystate',N'msdtc'
EXEC xp_servicecontrol N'querystate',N'sqlbrowser'
EXEC xp_servicecontrol N'querystate',N'MSSQLServerOLAPService'
EXEC xp_servicecontrol N'querystate',N'ReportServer'


/*
--See below example to start/stop service using SSMS
--EXEC xp_servicecontrol N'stop',N'SQLServerAGENT'
--EXEC xp_servicecontrol N'start',N'SQLServerAGENT'
--See below example to check non-SQL Service
--EXEC xp_servicecontrol querystate, DHCPServer
*/