/*
OS Wait Time: CXPACKET


CXPACKET waits may or may not be an issue for a system, but on an OLTP style system, they can indicate costly queries that are executing and requiring parallelized plans.


CXPACKET waits indicate coordination of multiple threads from queries that have been parallelized and one or more of the subtasks have completed before others. These waits may or may not be an issue, but on an OLTP system, high CXPACKET waits may indicate too many complex queries needing parallel operations. Long wait times captured by this metric may indicate queries that are taking a long time to complete, even using parallel query plans. Note: Values are calculated/accumulated since the last restart of the server, or if they are reset using: DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);
Enter the T-SQL query that will collect data:
*/

SELECT  wait_time_ms / 1000.0 AS wait_time_sec
FROM    sys.dm_os_wait_stats
WHERE   wait_type = 'CXPACKET';