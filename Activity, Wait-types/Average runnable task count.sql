/*
Average runnable task count

This metric gives an idea of how many tasks are in a runnable state and trying to execute in the system concurrently.

Sustained values for the runnable_tasks_count column are usually a very good indicator of CPU pressure, since it means that many tasks are waiting for CPU time. The longer the queue, and the greater the number of schedulers with requests waiting, the more stressed the CPU subsystem is.

*/

SELECT  AVG(runnable_tasks_count) AS [Avg Runnable Task Count]
FROM    sys.dm_os_schedulers
WHERE   scheduler_id < 255
        AND [status] = 'VISIBLE ONLINE';