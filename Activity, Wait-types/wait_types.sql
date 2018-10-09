use master

SELECT  *
FROM    sys.dm_os_latch_stats

SELECT  *
FROM    sys.dm_os_wait_stats


select
        r.command,
        r.wait_resource,
        r.wait_type,
        qp.query_plan,
        [statement_text]=SUBSTRING(st.text, (r.statement_start_offset/2)+1,
                        ((CASE r.statement_end_offset
                            WHEN -1 THEN DATALENGTH(st.text)
                                ELSE r.statement_end_offset
                            END - r.statement_start_offset)/2) + 1),
        st.text
from sys.dm_exec_requests r
    outer apply sys.dm_exec_sql_text (r.sql_handle) st
    cross apply sys.dm_exec_query_plan(r.plan_handle) qp
    where wait_type like 'PAGE%'


--SELECT  [resource_type] ,
--        DB_NAME([resource_database_id]) AS [Database Name] ,
--        CASE WHEN DTL.resource_type IN ( 'DATABASE', 'FILE', 'METADATA' )
--             THEN DTL.resource_type
--             WHEN DTL.resource_type = 'OBJECT'
--             THEN OBJECT_NAME(DTL.resource_associated_entity_id,
--                              DTL.[resource_database_id])
--             WHEN DTL.resource_type IN ( 'KEY', 'PAGE', 'RID' )
--             THEN ( SELECT  OBJECT_NAME([object_id])
--                    FROM    sys.partitions
--                    WHERE   sys.partitions.hobt_id =
--                                            DTL.resource_associated_entity_id
--                  )
--             ELSE 'Unidentified'
--        END AS requested_object_name ,
--        [request_mode] ,
--        [resource_description]
--FROM    sys.dm_tran_locks DTL
--WHERE   DTL.[resource_type] <> 'DATABASE' 
--  AND DB_NAME([resource_database_id]) = 'TMC_TESCOUK_CB'