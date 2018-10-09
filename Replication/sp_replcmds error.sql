/*

SQL Server 2008 replication failing with: process could not execute 'sp_replcmds'


I have an issue with SQL replication that I am having trouble fixing. What I am doing is restoring two DBs from a production backup, and then installing replication between them. The replication seems to be configured without any errors, but when I look at the status I see error messages like this:

I have an issue with SQL replication that I am having trouble fixing. What I am doing is restoring two DBs from a production backup, and then installing replication between them. The replication seems to be configured without any errors, but when I look at the status in Replication Monitor I see error messages like this:

    Error messages:

    The process could not execute 'sp_replcmds' on 'MYSERVER1'. Get help: http://help/MSSQL_REPL20011

    Cannot execute as the database principal because the principal "dbo" does not exist, this type of principal cannot be impersonated, or you do not have permission. (Source: MSSQLServer, Error number: 15517) Get help: http://help/15517

    The process could not execute 'sp_replcmds' on 'MYSERVER1'. Get help: http://help/MSSQL_REPL22037
*/

ALTER AUTHORIZATION ON DATABASE::[dm_name] TO [sa]