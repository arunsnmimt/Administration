SELECT total_worker_time/execution_count AS AvgCPU  
, total_worker_time AS TotalCPU
, total_elapsed_time/execution_count AS AvgDuration  
, total_elapsed_time AS TotalDuration  
, (total_logical_reads+total_physical_reads)/execution_count AS AvgReads 
, (total_logical_reads+total_physical_reads) AS TotalReads
, execution_count   
, SUBSTRING(st.TEXT, (qs.statement_start_offset/2)+1  
, ((CASE qs.statement_end_offset  WHEN -1 THEN datalength(st.TEXT)  
ELSE qs.statement_end_offset  
END - qs.statement_start_offset)/2) + 1) AS txt  
, query_plan
FROM sys.dm_exec_query_stats AS qs  
cross apply sys.dm_exec_sql_text(qs.sql_handle) AS st  
cross apply sys.dm_exec_query_plan (qs.plan_handle) AS qp 
ORDER BY 1 DESC
 