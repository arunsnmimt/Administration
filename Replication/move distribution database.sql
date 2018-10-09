-- SQL Script to move distribution database from one drive to another drive

/*

First we need to stop the Log Reader Agent and Distribution Agent.For stopping the log reader agent, expand publisher and right click on the publication and view log reader agent status and click stop. Take the distribution database offline from ssms. For stopping the distribution agent, go to sql server agent and expand jobs identify the distribution agent job and right click stop.

*/

ALTER DATABASE distribution SET OFFLINE

-- Copy the data and log file of the distribution database to the new location.

 ALTER DATABASE distribution MODIFY FILE ( NAME = distribution , FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\distmovetest\distribution.mdf')
 ALTER DATABASE distribution MODIFY FILE ( NAME = distribution_log , FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\distmovetest\distribution.ldf')
 --Get the database online
 ALTER DATABASE distribution SET ONLINE
 
 
 -- Start the Log Reader Agent and Distribution Agent.
 

