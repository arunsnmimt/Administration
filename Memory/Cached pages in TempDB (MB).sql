/*

Cached pages in TempDB (MB)


TempDB is a key component in the general performance of a SQL Server. Knowing more about what is stored in it, and by which process, will greatly help diagnose performance issues. This metric helps a DBA analyze how well TempDB is working on their server. Seeing big changes in TempDB commitment between one database and another could be a sign of a wrongly sized TempDB, or indicate that one database is using TempDB in a sub-optimal way.

The amount of space (in MB) consumed by user and internal processes, in TempDB per database. Big changes in allocations (increases or decreases) of space for particular databases can indicate possible problems, such as poorly written T-SQL. Keep a watch on big allocations that are not subsequently de-allocated appropriately. This trace shows the net effect, so increases not followed by decreases show a de-allocation is not taking place, possibly because of a long running transaction using a temporary table. Consider this trace along with the Log size and Log used traces for TempDB and use this information to ensure your TempDB files are sized appropriately.
*/

WITH    TempUsage
          AS ( SELECT [ddtsu].[session_id] ,
                    [ddtsu].[user_objects_alloc_page_count] ,
                    [ddtsu].[user_objects_dealloc_page_count] ,
                    [ddtsu].[internal_objects_alloc_page_count] ,
                    [ddtsu].[internal_objects_dealloc_page_count]
                FROM [sys].[dm_db_task_space_usage] AS ddtsu
               UNION ALL
               SELECT [ddssu].[session_id] ,
                    [ddssu].[user_objects_alloc_page_count] ,
                    [ddssu].[user_objects_dealloc_page_count] ,
                    [ddssu].[internal_objects_alloc_page_count] ,
                    [ddssu].[internal_objects_dealloc_page_count]
                FROM [sys].[dm_db_session_space_usage] AS ddssu
             )
              
    SELECT SUM(( ( tu.[user_objects_alloc_page_count]           -   tu.[user_objects_dealloc_page_count] )
                 + ( tu.[internal_objects_alloc_page_count]     -   tu.[internal_objects_dealloc_page_count] ) ))
            / 128.0 AS [TempDB_Objects_MB]
        FROM [TempUsage] AS tu
            INNER JOIN [sys].[sysprocesses] AS s
                ON tu.[session_id] = [s].[spid]
        WHERE [s].[spid] > 50
            AND [s].[dbid] = DB_ID();
            
            