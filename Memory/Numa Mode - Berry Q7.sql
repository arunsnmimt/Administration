USE master

-- SQL Server NUMA Node information  (Query 7) (SQL Server NUMA Info)
-- Gives you some useful information about the composition 
-- and relative load on your NUMA nodes

SELECT node_id, node_state_desc, memory_node_id, online_scheduler_count, 
	   active_worker_count, avg_load_balance, resource_monitor_state
FROM sys.dm_os_nodes WITH (NOLOCK) 
WHERE node_state_desc <> N'ONLINE DAC' OPTION (RECOMPILE);

    -- Is NUMA enabled
    SELECT 
      CASE COUNT(DISTINCT parent_node_id)
         WHEN 1 
             THEN 'NUMA disabled' 
             ELSE 'NUMA enabled'
      END
    FROM sys.dm_os_schedulers
    WHERE parent_node_id <> 32;