SELECT       command, 
	R.Status, 
	s.text,
--    LEFT(s.text,50) AS [text],  
    DB_NAME(r.database_id) AS Database_Name,
    start_time,  
    percent_complete,  
    CASE  
		WHEN percent_complete = 0 THEN NULL
		ELSE
    CAST(((DATEDIFF(s,start_time,GetDate()))/3600) as varchar) + ' hour(s), '  
        + CAST((DATEDIFF(s,start_time,GetDate())%3600)/60 as varchar) + 'min, '  
        + CAST((DATEDIFF(s,start_time,GetDate())%60) as varchar) + ' sec' 
        END as running_time,  

    CASE  
		WHEN percent_complete = 0 THEN NULL
		ELSE
    CAST((estimated_completion_time/3600000) as varchar) + ' hour(s), '  
        + CAST((estimated_completion_time %3600000)/60000 as varchar) + 'min, '  
        + CAST((estimated_completion_time %60000)/1000 as varchar) + ' sec' 
        END as est_time_to_go,  
    CASE  
		WHEN percent_complete = 0 THEN NULL
		ELSE
		DATEADD(second,estimated_completion_time/1000, getdate()) 
		END as est_completion_time,
		R.cpu_time, --R.total_elapsed_time, 
		R.blocking_session_id   
FROM   
    sys.dm_exec_requests r  
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s  
--WHERE  r.session_id = 55
--WHERE r.command LIKE 'DBCC INDEXDEFRAG%'
 
WHERE    r.command IN (  
        'CREATE INDEX',
        'ALTER INDEX',
        'DROP INDEX',
        'DBCC TABLE CHECK',
		'UPDATE STATISTIC',
        'DBCC',
        'RESTORE DATABASE',
        'BACKUP DATABASE',
        'BACKUP LOG',
        'ALTER TABLE',
		'DbccSpaceReclaim',
		'DbccFilesCompact',
		'DbccLOBCompact'
    ) 
    
    --SELECT  *
    --FROM    sys.dm_exec_requests
    
