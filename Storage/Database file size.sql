/*
Database file size


It’s important to measure the growth of databases so you can plan future space requirements, prepare for time periods when heavy volume traffic is expected, and take action in advance to prevent problems such as highly fragmented databases. It should also help prevent multiple autogrowth events which can negatively affect performance.

The metric data collected can be analyzed over time, so you can calculate the database’s maximum file size in advance, and then configure autogrowth size accordingly.
*/


SELECT cntr_value
  FROM sys.dm_os_performance_counters
  WHERE [instance_name] = DB_NAME()
    AND object_name = CASE WHEN SERVERPROPERTY('InstanceName') IS NULL
                           THEN 'SQLServer'
                           ELSE 'MSSQL$'
                                + CAST(SERVERPROPERTY('InstanceName') AS VARCHAR)
                      END + ':Databases'
    AND [counter_name] = 'Data File(s) Size (KB)';