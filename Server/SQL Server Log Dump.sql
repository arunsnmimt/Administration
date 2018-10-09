/*
If you want to view the contents of the SQL Server log by using T-SQL, there's an undocumented (but well known) extended stored procedure called xp_readerrorlog. You can use it to dump the results of the error log to a recordset by:
*/
EXEC xp_readerrorlog;
/*
To read further back, you can give this extended stored procedure an integer parameter which corresponds to the order of the SQL Server log. 0 represents the current log, with each number after that referring to the next one back. So to see the contents of the 3rd log (including the current one) you would pass a parameter of 2 (counting up from 0 - 0, 1, 2 would be the third), you would execute:
*/

EXEC xp_readerrorlog 2;

/*
To search the current error log and only return failed logins you can use the following command.  The first parameter specifies the error log (0=current), the second parameter specifies the type of log (1=SQL Error Log) and the third parameter specifies the message to search for.
*/

 EXEC sp_readerrorlog 0, 1, 'Login failed'  