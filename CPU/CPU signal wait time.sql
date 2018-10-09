/*
CPU signal wait time

This metric measures the percentage of time spent waiting for CPU resources to service a thread. A high signal wait time for all wait types may indicate that CPUs are being overused, forcing tasks to wait for SQL Server processes. The values are calculated/accumulated as of the last restart of the server, or if they are reset using:
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);

*/


-- Total waits are wait_time_ms (high signal waits indicates CPU pressure)
SELECT  CAST(100.0 * SUM(signal_wait_time_ms) / SUM(wait_time_ms)
                              AS NUMERIC(20,2)) AS signal_cpu_waits
FROM    sys.dm_os_wait_stats ;