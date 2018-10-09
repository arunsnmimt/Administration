/*
The process could not execute 'sp_repldone/sp_replcounters' on 'SQLGUY'. (Source: MSSQL_REPL, Error number: MSSQL_REPL20011)
Get help: http://help/MSSQL_REPL20011
The log scan number (23:49:3) passed to log scan in database 'PUBLISHER' is not valid. This error may indicate data corruption or that the log file (.ldf) does not match the data file (.mdf). If this error occurred during replication, re-create the publication. Otherwise, restore from backup if the problem results in a failure during startup.  (Source: MSSQLServer, Error number: 9003)
Get help: http://help/9003
The process could not set the last distributed transaction. (Source: MSSQL_REPL, Error number: MSSQL_REPL22017)
Get help: http://help/MSSQL_REPL22017
The process could not execute 'sp_repldone/sp_replcounters' on 'SQLGUY'. (Source: MSSQL_REPL, Error number: MSSQL_REPL22037)
Get help: http://help/MSSQL_REPL22037
*/

/*
If an old backup was restored on top of published database then use sp_replrestart
If going back to the most recent transaction log backup is not an option then execute sp_replrestart  on publisher in published database. This stored procedure is used when the highest log sequence number (LSN) value at the Distributor does match the highest LSN value at the Publisher.

This stored procedure will insert compensating LSNs (No Operation) in the publisher 
*/


sp_replrestart