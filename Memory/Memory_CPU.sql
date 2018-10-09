-- #######################################################################################################################################################
-- System memory usage.
-- #######################################################################################################################################################

SELECT  total_physical_memory_kb / 1024 AS total_physical_memory_mb ,
        available_physical_memory_kb / 1024 AS available_physical_memory_mb ,
        total_page_file_kb / 1024 AS total_page_file_mb ,
        available_page_file_kb / 1024 AS available_page_file_mb ,
        system_memory_state_desc
FROM    sys.dm_os_sys_memory

-- 

-- #######################################################################################################################################################
-- Memory usage by the SQL Server process.
-- SQL Server Process Address space info (SQL 2008 and 2008 R2 only) 
-- #######################################################################################################################################################

SELECT  physical_memory_in_use_kb /1024 AS physical_memory_in_use_mb ,
        locked_page_allocations_kb ,
        memory_utilization_percentage ,
        available_commit_limit_kb ,
        virtual_address_space_committed_kb /1024 AS virtual_address_space_committed_mb ,
        virtual_address_space_available_kb /1024 AS virtual_address_space_available_kb ,
        page_fault_count ,
        process_physical_memory_low ,
        process_virtual_memory_low
FROM    sys.dm_os_process_memory

-- #######################################################################################################################################################
-- Page Life expectancy
-- #######################################################################################################################################################

SELECT [object_name],
	   [counter_name],
	   [cntr_value] -- > Minimum of 300 seconds
  FROM sys.dm_os_performance_counters
 WHERE [object_name] LIKE '%Manager%'
   AND [counter_name] = 'Page life expectancy'
   
-- #######################################################################################################################################################
-- Look at the number of items in different parts of the cache 
-- #######################################################################################################################################################
SELECT  name ,
        [type] ,
        entries_count ,
        single_pages_kb ,
        single_pages_in_use_kb ,
        multi_pages_kb ,
        multi_pages_in_use_kb 
FROM    sys.dm_os_memory_cache_counters
WHERE   [type] = 'CACHESTORE_SQLCP'
        OR [type] = 'CACHESTORE_OBJCP'
ORDER BY multi_pages_kb DESC ;   

-- #######################################################################################################################################################
-- Get total buffer usage by database
-- #######################################################################################################################################################
SELECT  DB_NAME(database_id) AS [Database Name] ,
        COUNT(*) * 8 / 1024.0 AS [Cached Size (MB)]
FROM    sys.dm_os_buffer_descriptors
WHERE   database_id > 4 -- exclude system databases
        AND database_id <> 32767 -- exclude ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC ;

-- Breaks down buffers by object (table, index) in the buffer pool
SELECT  OBJECT_NAME(p.[object_id]) AS [ObjectName] ,
        p.index_id ,
        COUNT(*) / 128 AS [Buffer size(MB)] ,
        COUNT(*) AS [Buffer_count]
FROM    sys.allocation_units AS a
        INNER JOIN sys.dm_os_buffer_descriptors
                 AS b ON a.allocation_unit_id = b.allocation_unit_id
        INNER JOIN sys.partitions AS p ON a.container_id = p.hobt_id
WHERE   b.database_id = DB_ID()
        AND p.[object_id] > 100 -- exclude system objects
GROUP BY p.[object_id] ,
        p.index_id
ORDER BY buffer_count DESC ;


-- #######################################################################################################################################################
-- Buffer Pool Usage for instance
-- #######################################################################################################################################################
SELECT TOP(20) [type], SUM(single_pages_kb) AS [SPA Mem, Kb]
FROM sys.dm_os_memory_clerks
GROUP BY [type]
ORDER BY SUM(single_pages_kb) DESC;



-- #######################################################################################################################################################
-- Shows the memory required by both running (non-null grant_time)
-- and waiting queries (null grant_time)
-- SQL Server 2008 version
-- #######################################################################################################################################################
SELECT  DB_NAME(st.dbid) AS [DatabaseName] ,
        mg.requested_memory_kb ,
        mg.ideal_memory_kb ,
        mg.request_time ,
        mg.grant_time ,
        mg.query_cost ,
        mg.dop ,
        st.[text]
FROM    sys.dm_exec_query_memory_grants AS mg
        CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE   mg.request_time < COALESCE(grant_time, '99991231')
ORDER BY mg.requested_memory_kb DESC ;

-- Shows the memory required by both running (non-null grant_time)
-- and waiting queries (null grant_time)
-- SQL Server 2005 version
SELECT  DB_NAME(st.dbid) AS [DatabaseName] ,
        mg.requested_memory_kb ,
        mg.request_time ,

        mg.grant_time ,
        mg.query_cost ,
        mg.dop ,
        st.[text]
FROM    sys.dm_exec_query_memory_grants AS mg
        CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE   mg.request_time < COALESCE(grant_time, '99991231')
ORDER BY mg.requested_memory_kb DESC ;


-- #######################################################################################################################################################
-- CPU Utilization History
-- Get CPU Utilization History for last 30 minutes (in one minute intervals) 
-- This version works with SQL Server 2008 and SQL Server 2008 R2 only 
-- #######################################################################################################################################################

DECLARE @ts_now BIGINT = ( SELECT   cpu_ticks / ( cpu_ticks / ms_ticks )
                           FROM     sys.dm_os_sys_info) ; 
                           
SELECT TOP ( 30 )
        SQLProcessUtilization AS [SQL Server Process CPU Utilization] ,
        SystemIdle AS [System Idle Process] ,
        100 - SystemIdle - SQLProcessUtilization
                   AS [Other Process CPU Utilization] ,
        DATEADD(ms, -1 * ( @ts_now - [timestamp] ), GETDATE()) AS [Event Time] 
FROM    ( SELECT    record.value('(./Record/@id)[1]', 'int')  AS record_id, 
                    record.value('(./Record/SchedulerMonitorEvent/
                                    SystemHealth/SystemIdle)[1]','int')
                                                              AS [SystemIdle] ,
                    record.value('(./Record/SchedulerMonitorEvent/
                                    SystemHealth/ProcessUtilization)[1]','int') AS [SQLProcessUtilization] ,
                    [timestamp] 
          FROM      ( SELECT  [timestamp] ,
                              CONVERT(XML, record) AS [record]
                      FROM  sys.dm_os_ring_buffers
                      WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
                        AND record LIKE N'%<SystemHealth>%'
                    ) AS x
        ) AS y
ORDER BY record_id DESC ;        