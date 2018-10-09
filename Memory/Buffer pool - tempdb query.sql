-- tempdb query in buffer pool ????


SELECT es.host_name , es.login_name , es.program_name,
st.dbid as QueryExecContextDBID, 
DB_NAME(st.dbid) as QueryExecContextDBNAME, st.objectid as ModuleObjectId,
SUBSTRING(st.text, er.statement_start_offset/2 + 1,(CASE WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max),st.text)) * 2 ELSE er.statement_end_offset 
END - er.statement_start_offset)/2) as Query_Text,
tsu.session_id ,tsu.request_id, tsu.exec_context_id, 
(tsu.user_objects_alloc_page_count - tsu.user_objects_dealloc_page_count) as OutStanding_user_objects_page_counts,
(tsu.internal_objects_alloc_page_count - tsu.internal_objects_dealloc_page_count) as OutStanding_internal_objects_page_counts,
er.start_time, er.command, er.open_transaction_count, er.percent_complete, er.estimated_completion_time, er.cpu_time, er.total_elapsed_time, er.reads,er.writes, 
er.logical_reads, er.granted_query_memory
FROM sys.dm_db_task_space_usage tsu inner join sys.dm_exec_requests er 
 ON ( tsu.session_id = er.session_id and tsu.request_id = er.request_id) 
inner join sys.dm_exec_sessions es ON ( tsu.session_id = es.session_id ) 
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE (tsu.internal_objects_alloc_page_count+tsu.user_objects_alloc_page_count) > 0
ORDER BY (tsu.user_objects_alloc_page_count - tsu.user_objects_dealloc_page_count)+(tsu.internal_objects_alloc_page_count - tsu.internal_objects_dealloc_page_count) 
DESC

/*
================================================================================================================================================
*/

SELECT t1.session_id,
(t1.internal_objects_alloc_page_count + task_alloc) as allocated,
(t1.internal_objects_dealloc_page_count + task_dealloc) as deallocated
 , t3.sql_handle, t3.statement_start_offset
 , t3.statement_end_offset, t3.plan_handle
 , QP.*
from sys.dm_db_session_space_usage as t1
inner join sys.dm_exec_requests t3
on t1.session_id = t3.session_id
inner join (select session_id, 
      sum(internal_objects_alloc_page_count) as task_alloc,
      sum (internal_objects_dealloc_page_count) as task_dealloc
      from sys.dm_db_task_space_usage group by session_id) as t2
on t1.session_id = t2.session_id 
and t1.session_id >50
and t1.database_id = 2   --- tempdb is database_id=2
CROSS APPLY sys.dm_exec_query_plan(t3.plan_handle) QP

order by allocated DESC


/*
================================================================================================================================================
*/


/* WP Working with tempdb in SQLServer 2005 - WorkingWithTempDB.doc */
use tempdb 
/* In SQL Server 2005, this view is applicable only to the tempdb database. */
select  db_name(database_id) as DbName
      , cast(user_object_reserved_page_count * 8 / 1024 as decimal(9, 2)) as user_object_reserved_MB
      , cast(internal_object_reserved_page_count * 8.0 / 1024 as decimal(9, 2)) as internal_object_reserved_MB
      , cast(version_store_reserved_page_count * 8.0 / 1024 as decimal(9, 2)) as version_store_reserved_MB
      , cast(unallocated_extent_page_count * 8.0 / 1024 as decimal(9, 2)) as unallocated_extent_MB
      , cast(mixed_extent_page_count * 8.0 / 1024 as decimal(9, 2)) as mixed_extent_MB
      , *
from    sys.dm_db_file_space_usage
order by DbName
      , [file_id]



/* Sys.dm_db_session_file_usage
This DMV tracks the historical allocation/deallocation of pages in tempdb for the active sessions. 
A session is established when a user connects to the database. 
The session is active until the connection is terminated. 
During the course of the session, the user submits one or more batches. 
This DMV tracks the tempdb space usage only by the completed batches. 
The following code example shows the top five sessions that have allocated 
a maximum space for user objects and internal objects in tempdb. 
This represents the batches that have already completed
, but the code lists sessions with heavy tempdb space use. 
You could look at these first if you want to minimize tempdb consumption. 
Note that this tempdb space usage does not take into account the impact of this session 
on the version store space.
*/
SELECT top 5
        db_name(SSU.database_id) as DbName
      , ES.login_name
      , ES.login_time
      , ES.[host_name]
      , cast(SSU.user_objects_alloc_page_count * 8.0 / 1024 as decimal(9, 2)) as user_object_alloc_MB
      , cast(SSU.user_objects_dealloc_page_count * 8.0 / 1024 as decimal(9, 2)) as user_object_dealloc_MB
      , cast(( SSU.user_objects_alloc_page_count
               - SSU.user_objects_dealloc_page_count ) * 8.0 / 1024 as decimal(9, 2)) as user_object_CURRENT_MB
      , cast(SSU.internal_objects_alloc_page_count * 8.0 / 1024 as decimal(9, 2)) as internal_object_alloc_MB
      , cast(SSU.internal_objects_dealloc_page_count * 8.0 / 1024 as decimal(9, 2)) as internal_object_dealloc_MB
      , *
FROM    sys.dm_db_session_space_usage SSU
inner join sys.dm_exec_sessions ES
        on ES.session_id = SSU.session_id
ORDER BY ( SSU.user_objects_alloc_page_count
           + SSU.internal_objects_alloc_page_count ) DESC

/* Sys.dm_db_task_space_usage
This DMV tracks the allocation/deallocation of tempdb pages by the currently 
executing tasks (also called batches). 
This is extremely useful when you are running out of space in tempdb. 
Using this DMV, you can identify tasks with heavy tempdb space use and optionally kill them. 
You can then analyze why these tasks require heavy tempdb space usage and take corrective action. 
You can join this DMV with other DMVs to identify the SQL statement and its corresponding 
query plan for deeper analysis. The following query shows the top five tasks that are currently 
executing tasks and consuming the most tempdb space. The tempdb space usage returned does not 
allow for the impact on space consumed by the version store.
*/
SELECT top 5
        db_name(TSU.database_id) as DbName
      , ES.login_name
      , ES.login_time
      , ES.[host_name]
      , cast(TSU.user_objects_alloc_page_count * 8.0 / 1024 as decimal(9, 2)) as user_object_alloc_MB
      , cast(TSU.user_objects_dealloc_page_count * 8.0 / 1024 as decimal(9, 2)) as user_object_dealloc_MB
      , cast(( TSU.user_objects_alloc_page_count
               - TSU.user_objects_dealloc_page_count ) * 8.0 / 1024 as decimal(9, 2)) as user_object_CURRENT_MB
      , cast(TSU.internal_objects_alloc_page_count * 8.0 / 1024 as decimal(9, 2)) as internal_object_alloc_MB
      , cast(TSU.internal_objects_dealloc_page_count * 8.0 / 1024 as decimal(9, 2)) as internal_object_dealloc_MB
      , TSU.*
FROM    sys.dm_db_task_space_usage TSU
inner join sys.dm_exec_sessions ES
        on ES.session_id = TSU.session_id
ORDER BY ( TSU.user_objects_alloc_page_count
           + TSU.internal_objects_alloc_page_count ) DESC

/*
The following tools in SQL Server 2005 for monitoring space usage in tempdb 
make it easier to troubleshoot problems. 
Use the new DMVs to analyze which Transact-SQL statements are the top consumers 
of tempdb space as described in Monitoring space in this paper. 
For example you can use the following query that joins the sys.dm_db_task_space_usage 
and sys.dm_exec_requests DMVs to find the currently active requests, 
their associated TSQL statement, and the corresponding query plan that is allocating 
most space resources in tempdb. You may be able to reduce tempdb space usage by 
rewriting the queries and/or the stored procedures, or by creating useful indexes.
*/
SELECT  sTSU.session_id
      , sTSU.request_id
      , sTSU.task_alloc
      , sTSU.task_dealloc
      , ER.sql_handle
      , ER.statement_start_offset
      , ER.statement_end_offset
      , ER.plan_handle
      , ST.text as ProcText
      , P.query_plan
FROM    ( Select    session_id
                  , request_id
                  , SUM(internal_objects_alloc_page_count) AS task_alloc
                  , SUM(internal_objects_dealloc_page_count) AS task_dealloc
          FROM      sys.dm_db_task_space_usage
          GROUP BY  session_id
                  , request_id
        ) AS sTSU
inner join sys.dm_exec_requests ER
        on sTSU.session_id = ER.session_id
           AND sTSU.request_id = ER.request_id
CROSS APPLY sys.dm_exec_sql_text(ER.plan_handle) ST
CROSS APPLY sys.dm_exec_query_plan(ER.plan_handle) p
ORDER BY sTSU.task_alloc DESC


/*
Note that if a query is executing in parallel, each parallel thread runs under 
the same <session-id, request-id> pair.
You can actively monitor free space in tempdb by using the perfmon free space in 
tempdb (KB) counter. If space in tempdb is critically low, query the sys.dm_db_task_space_usage 
DMV to find out which tasks are consuming the most space in tempdb. You can kill such tasks, 
where appropriate, to free space.
If the version store is not shrinking, it is likely that a long-running transaction is preventing 
version store cleanup. The following query returns the five transactions that have been running 
the longest and that depend on the versions in the version store.
*/
SELECT top 50
        transaction_id
      , transaction_sequence_num
      , elapsed_time_seconds
FROM    sys.dm_tran_active_snapshot_database_transactions
ORDER BY elapsed_time_seconds DESC

/*
tempdb can only be configured in the simple recovery model. 
Typically, the transaction log is cleared with the implicit or the explicit checkpoints. 
An active long-running transaction can prevent transaction log cleanup and can potentially 
use up all available log space. 
To identify a long-running transaction, query the sys.dm_tran_active_transactions DMV 
to find the longest running transaction and, if appropriate, kill it.
*/


/* Monitoring I/O
The first step in solving performance issues is to identify the resources that are experiencing bottlenecks. 
For example, if CPU is 100% used, this indicates a bottleneck in CPU resources. Similarly, an I/O bottleneck 
is indicated if I/O requests are queuing up. 
You can identify I/O bottlenecks by monitoring the following perfmon counters for physical devices 
associated with tempdb.
PhysicalDisk Object: Avg. Disk Queue Length: The average number of physical read and write requests 
that were queued on the selected physical disk during the sampling period. If the I/O system is 
overloaded, more read/write operations will be waiting. If the disk queue length exceeds a specified 
value too frequently during peak usage of SQL Server, there might be an I/O bottleneck. 
Avg. Disk Sec/Read: The average time, in seconds, of a read of data from the disk. Use the following 
to analyze numbers in the output.
•	Less than 10 milliseconds (ms) = very good
•	Between 10-20 ms = okay
•	Between 20-50 ms = slow, needs attention
•	Greater than 50 ms = serious IO bottleneck
Avg. Disk Sec/Write: The average time, in seconds, of a write of data to the disk. 
See the guidelines for the previous item, Avg. Disk Sec/Read.
Physical Disk: %Disk Time: The percentage of elapsed time that the selected disk drive was 
busy servicing read or write requests. 
A general guideline is that if this value > 50 percent, there is an I/O bottleneck. 
Avg. Disk Reads/Sec: The rate of read operations on the disk. Make sure that this number is 
less than 85 percent of disk capacity. Disk access time increases exponentially beyond 85 percent capacity. 
Avg. Disk Writes/Sec: The rate of write operations on the disk. Make sure that this number is less 
than 85 percent of the disk capacity. Disk access time increases exponentially beyond 85 percent capacity.
Database: Log Bytes Flushed/sec: The total number of log bytes flushed. A large value indicates heavy 
		log activity in tempdb. 
Database:Log Flush Waits/sec: The number of commits that are waiting on log flush. Although transactions 
		do not wait for the log to be flushed in tempdb, a high number in this performance counter indicates 
		and I/O bottleneck in the disk(s) associated with the log.
Troubleshooting I/O
If you determine that a query or application slowdown is caused by an I/O bottleneck in tempdb, 
troubleshoot as follows:
•	Identify queries that consume large amounts of space in tempdb and see if alternate query plans 
		can be used to minimize the amount of space required by the query.
•	See if you have a memory bottleneck that is manifesting itself into I/O problem.
•	See if you have a slow I/O subsystem.
Use optimal execution plans
Examine execution plans and see which plans result in more I/O. 
It is possible that by choosing a better plan (for example, by forcing an index usage 
for a better query plan), that you can minimize I/O. 
If there are missing indexes, run Database Engine Tuning Advisor to find the missing indexes. 
In SQL Server 2005, you can use the following DMV to identify and analyze the queries that are 
generating the most I/Os. 
*/
SELECT top 10
        ( total_logical_reads / execution_count ) total_logical_reads_PER_execution_count
      , ( total_logical_writes / execution_count ) total_logical_Writes_PER_execution_count
      , ( total_physical_reads / execution_count ) total_Physical_reads_PER_execution_count
      , Execution_count
      , sql_handle
      , plan_handle
FROM    sys.dm_exec_query_stats
ORDER BY ( total_logical_reads + total_logical_writes ) Desc

/*
To get the text of the query, run the following DMV query.

SELECT text 
FROM sys.dm_exec_sql_text (<sql-handle>

You can examine the query plan by using the following DMV query.

SELECT *
FROM sys.dm_exec_query_plan (<plan_handle>\

Check memory configuration
Check the memory configuration of SQL Server. If SQL Server is configured with insufficient memory, it incurs 
more I/O overhead. You can examine following perfmon counters to identify memory pressure:
•	Buffer Cache hit ratio
•	Page Life Expectancy
•	Checkpoint pages/sec
•	Lazywrites/sec
Increase I/O bandwidth
Add more physical drives to the current disk arrays. 
You could also replace your disks with faster drives. 
This helps to boost both read and write access times. 
Do not add more drives to the array than your I/O controller can support.
*/

/*
If you experience allocation bottlenecks..
*/
SELECT  session_id
      , wait_duration_ms
      , resource_description
FROM    sys.dm_os_waiting_tasks
WHERE   wait_type like 'PAGE%LATCH_%'
        AND resource_description like '2:%'

/*
Once you know the page number, you can use the following query to find the type 
of the page and the object it belongs to. 
If you see the contention in PFS, GAM or SGAM pages, it implies contention in allocation structures.
*/
SELECT  P.object_id
      , object_name(P.object_id) as object_name
      , P.index_id
      , BD.page_type
FROM    sys.dm_os_buffer_descriptors BD
inner join sys.allocation_units A
        ON BD.allocation_unit_id = A.allocation_unit_id
inner join sys.partitions P
        ON A.container_id = P.partition_id



/* Zoals SSMS het gebruikt */

create table #tmpspc
    (
      Fileid int
    , FileGroup int
    , TotalExtents int
    , UsedExtents int
    , Name sysname
    , FileName nchar(520)
    )
insert  #tmpspc
        EXEC ( 'dbcc showfilestats' )
		


SELECT  CAST(cast(g.name as varbinary(256)) AS sysname) AS [FileGroup_Name]
      , s.name AS [Name]
      , ( tspc.TotalExtents - tspc.UsedExtents ) * convert(float, 64) AS [AvailableSpace]
      , s.physical_name AS [FileName]
      , CAST(CASE s.is_percent_growth
               WHEN 1 THEN s.growth
               ELSE s.growth * 8
             END AS float) AS [Growth]
      , CAST(CASE when s.growth = 0 THEN 99
                  ELSE s.is_percent_growth
             END AS int) AS [GrowthType]
      , s.file_id AS [ID]
      , CAST(CASE s.file_id
               WHEN 1 THEN 1
               ELSE 0
             END AS bit) AS [IsPrimaryFile]
      , CASE when s.max_size = -1 then -1
             else s.max_size * CONVERT(float, 8)
        END AS [MaxSize]
      , s.size * CONVERT(float, 8) AS [Size]
      , CAST(tspc.UsedExtents * convert(float, 64) AS float) AS [UsedSpace]
      , CAST(case s.state
               when 6 then 1
               else 0
             end AS bit) AS [IsOffline]
      , s.is_read_only AS [IsReadOnly]
      , s.is_media_read_only AS [IsReadOnlyMedia]
      , s.is_sparse AS [IsSparse]
FROM    sys.filegroups AS g
INNER JOIN sys.master_files AS s
        ON ( s.type = 0
             and s.database_id = db_id()
             and ( s.drop_lsn IS NULL )
           )
           AND ( s.data_space_id = g.data_space_id )
INNER JOIN #tmpspc tspc
        ON tspc.Fileid = s.file_id
ORDER BY [FileGroup_Name] ASC
      , [Name] ASC


drop table #tmpspc
		


select * --name, OBJECT_DEFINITION ( object_id ) will always be NULL for temptb of other connections
from sys.all_objects 
where is_ms_shipped = 0
order by name; 

