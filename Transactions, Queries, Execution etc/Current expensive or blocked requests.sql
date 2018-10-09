USE master

-- Look at currently executing requests, status and wait type 
SELECT  r.session_id ,
        r.[status] ,
        r.wait_type ,
        r.scheduler_id ,
        SUBSTRING(qt.[text], r.statement_start_offset / 2,
            ( CASE WHEN r.statement_end_offset = -1
                   THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2
                   ELSE r.statement_end_offset
              END - r.statement_start_offset ) / 2) AS [statement_executing] ,
		qt.[text],
		DB_NAME(r.[database_id]) AS [DatabaseName],
--        DB_NAME(qt.[dbid]) AS [DatabaseName] ,
        OBJECT_NAME(qt.objectid) AS [ObjectName] ,
        r.cpu_time ,
        r.total_elapsed_time ,
        r.reads ,
        r.writes ,
        r.logical_reads ,
        r.plan_handle,
        deqp.query_plan
FROM    sys.dm_exec_requests AS r
        CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS qt
         CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) deqp
WHERE   r.session_id > 50
--AND text LIKE '%tbl_JourneyDrops%' AND r.logical_reads > 500
--AND qt.[dbid] = DB_ID('DAF_telematics_Live_Amber')
--AND r.database_id = DB_ID('TMC_DHL_NEXT')
AND r.session_id <> @@SPID
ORDER BY r.scheduler_id ,
        r.[status] ,
        r.session_id ;
        /*       
          
 SELECT (SELECT SUM(CAST(df.size as float)) FROM sys.database_files AS df WHERE df.type in ( 0, 2, 4 ) ) AS [DbSize], SUM(a.total_pages) AS [SpaceUsed], (SELECT SUM(CAST(df.size as float)) FROM sys.database_files AS df WHERE df.type in (1, 3)) AS [LogSize], SUM(CASE WHEN a.type <> 1 THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END) AS [DataSpaceUsage], SUM(a.used_pages) AS [IndexSpaceTotal], (select count(1) from sys.services where name ='InternalMailService') AS [IsMailHost], (select top 1 ds.name from sys.data_spaces as ds where ds.is_default = 1 and ds.type = 'FG' ) AS [DefaultFileGroup] FROM sys.allocation_units AS a INNER JOIN sys.partitions AS p ON (a.type = 2 AND p.partition_id = a.container_id) OR (a.type IN (1,3) AND p.hobt_id = a.container_id          
 
 */
