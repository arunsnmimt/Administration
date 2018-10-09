/*
	SQL Server Installed Date
*/	

SELECT  createdate as Sql_Server_Install_Date 
FROM    sys.syslogins 
where   sid = 0x010100000000000512000000 -- language neutral
        -- loginname = 'NT AUTHORITY\SYSTEM' -- only English language installations

