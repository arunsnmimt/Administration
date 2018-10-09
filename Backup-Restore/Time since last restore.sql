/*
Time since last restore

This metric tracks the number of minutes since the most recent restore of the database.

If your log restores aren’t happening when they’re meant to, you want to know about it. You’ll be relying on restoring from logs should anything happen to your databases, and if you can’t restore to a certain point in time, you risk losing valuable data.

*/

SELECT DATEDIFF(MINUTE, restore_date, GETDATE()) As Mins_Since_Last_Restore
  FROM (SELECT TOP 1 restore_date
          FROM msdb.dbo.restorehistory
          WHERE destination_database_name = DB_NAME()
          ORDER BY restore_date DESC
       ) rd;