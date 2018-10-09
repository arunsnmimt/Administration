SELECT  CHAR(13) + CHAR(10)
        + CASE WHEN deqs.statement_start_offset = 0
                    AND deqs.statement_end_offset = -1
               THEN '-- see objectText column--'
               ELSE '-- query --' + CHAR(13) + CHAR(10)
                    + SUBSTRING(execText.text, deqs.statement_start_offset / 2,
                                ( ( CASE WHEN deqs.statement_end_offset = -1
                                         THEN DATALENGTH(execText.text)
                                         ELSE deqs.statement_end_offset
                                    END ) - deqs.statement_start_offset ) / 2)
          END AS queryText ,
          execText.text,
          DB_NAME(deqp.dbid) AS DB_Name,
          deqs.plan_handle,
          deqs.creation_time, 
          deqs.last_execution_time,
        deqp.query_plan --, deqp.*, execText.*
FROM    sys.dm_exec_query_stats deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) deqp
--WHERE   execText.text LIKE '%sp_imp_PODPOCImport%'
WHERE   execText.text LIKE '%CalculateRAGStatus_Restrictions%'
--WHERE  execText.text LIKE '%sp_SystemEventsGetAlerts%'
--AND  DB_NAME(deqp.dbid) = 'TMC_DHL_LOTS'
--AND deqs.last_execution_time >= '2013-10-24 12:41'
--AND deqs.creation_time < '2013-10-03'
--WHERE deqs.plan_handle = 0x05001700218562444021328F0E0000000000000000000000
  
  
--  select * from sys.dm_exec_query_plan(0x05001700AD02111540A1B2C2040000000000000000000000)

-- Remove the specific plan from the cache using the plan handle
--DBCC FREEPROCCACHE (0x0600120063B0AD3A40014B81120000000000000000000000)
