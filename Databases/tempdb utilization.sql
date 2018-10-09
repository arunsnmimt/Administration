/*
From http://www.sqlservercentral.com/scripts/tempdb/72007/
*/

;WITH task_space_usage AS (
    -- SUM alloc/delloc pages
    SELECT session_id,
           request_id,
           SUM(internal_objects_alloc_page_count) AS alloc_pages,
           SUM(internal_objects_dealloc_page_count) AS dealloc_pages
    FROM sys.dm_db_task_space_usage WITH (NOLOCK)
    WHERE session_id <> @@SPID
    GROUP BY session_id, request_id
)
SELECT TSU.session_id,
       TSU.alloc_pages * 1.0 / 128 AS [internal object MB space],
       TSU.dealloc_pages * 1.0 / 128 AS [internal object dealloc MB space],
       EST.text,
       -- Extract statement from sql text
       ISNULL(
           NULLIF(
               SUBSTRING(
                 EST.text, 
                 ERQ.statement_start_offset / 2, 
                 CASE WHEN ERQ.statement_end_offset < ERQ.statement_start_offset 
                  THEN 0 
                 ELSE( ERQ.statement_end_offset - ERQ.statement_start_offset ) / 2 END
               ), ''
           ), EST.text
       ) AS [statement text],
       EQP.query_plan
FROM task_space_usage AS TSU
INNER JOIN sys.dm_exec_requests ERQ WITH (NOLOCK)
    ON  TSU.session_id = ERQ.session_id
    AND TSU.request_id = ERQ.request_id
OUTER APPLY sys.dm_exec_sql_text(ERQ.sql_handle) AS EST
OUTER APPLY sys.dm_exec_query_plan(ERQ.plan_handle) AS EQP
WHERE EST.text IS NOT NULL OR EQP.query_plan IS NOT NULL
ORDER BY 3 DESC;

/*
EDIT

As Martin pointed out in a comment, this would not find active transactions that are occupying space in tempdb, it will only find active queries that are currently utilizing space there (and likely culprits for current log usage). You could change the inner join on sys.dm_exec_requests to a left outer join, then you will return rows for sessions that aren't currently actively running queries.

The query Martin posted...

*/

SELECT database_transaction_log_bytes_reserved,session_id 
  FROM sys.dm_tran_database_transactions AS tdt 
  INNER JOIN sys.dm_tran_session_transactions AS tst 
  ON tdt.transaction_id = tst.transaction_id 
  WHERE database_id = 2;

/*
...would identify session_ids with active transactions that are occupying log space, but you wouldn't necessarily be able to determine the actual query that caused the problem, since if it's not running now it won't be captured in the above query for active requests. You may be able to reactively check the most recent query using DBCC INPUTBUFFER but it may not tell you what you want to hear. You can outer join in a similar way to capture those actively running, e.g.:
*/



SELECT tdt.database_transaction_log_bytes_reserved,tst.session_id,
       t.[text], [statement] = COALESCE(NULLIF(
         SUBSTRING(
           t.[text],
           r.statement_start_offset / 2,
           CASE WHEN r.statement_end_offset < r.statement_start_offset
             THEN 0
             ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
         ), ''
       ), t.[text])
     FROM sys.dm_tran_database_transactions AS tdt
     INNER JOIN sys.dm_tran_session_transactions AS tst
     ON tdt.transaction_id = tst.transaction_id
         LEFT OUTER JOIN sys.dm_exec_requests AS r
         ON tst.session_id = r.session_id
         OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
     WHERE tdt.database_id = 2;

/*
You can also use the DMV sys.dm_db_session_space_usage to see overall space utilization by session (but again you may not get back valid results for the query; if the query is not active, what you get back may not be the actual culprit).
*/


;WITH s AS
(
    SELECT 
        s.session_id,
        [pages] = SUM(s.user_objects_alloc_page_count 
          + s.internal_objects_alloc_page_count) 
    FROM sys.dm_db_session_space_usage AS s
    GROUP BY s.session_id
    HAVING SUM(s.user_objects_alloc_page_count 
      + s.internal_objects_alloc_page_count) > 0
)
SELECT s.session_id, s.[pages], t.[text], 
  [statement] = COALESCE(NULLIF(
    SUBSTRING(
        t.[text], 
        r.statement_start_offset / 2, 
        CASE WHEN r.statement_end_offset < r.statement_start_offset 
        THEN 0 
        ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
      ), ''
    ), t.[text])
FROM s
LEFT OUTER JOIN 
sys.dm_exec_requests AS r
ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
ORDER BY s.[pages] DESC;

/*
With all of these queries at your disposal, you should be able to narrow down who is using up tempdb and how, especially if you catch them in the act.
some tips for minimizing tempdb utilization

    use fewer #temp tables and @table variables
    minimize concurrent index maintenance, and avoid the SORT_IN_TEMPDB option if it isn't needed
    avoid unnecessary cursors; avoid static cursors if you think this may be a bottleneck, since static cursors use work tables in tempdb - though this is the type of cursor I always recommend if tempdb isn't a bottleneck
    try to avoid spools (e.g. large CTEs that are referenced multiple times in the query)
    don't use MARS
    thoroughly test the use of snapshot / RCSI isolation levels - don't just turn it on for all databases since you've been told it's better than NOLOCK (it is, but it isn't free)
    in some cases, it may sound unintuitive, but use more temp tables. e.g. breaking up a humongous query into parts may be slightly less efficient, but if it can avoid a huge memory spill to tempdb because the single, larger query requires a memory grant too large...
    avoid enabling triggers for bulk operations
    avoid overuse of LOB types (max types, XML, etc) as local variables
    keep transactions short and sweet
    don't set tempdb to be everyone's default database -
*/