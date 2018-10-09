
    SELECT
         sjh.instance_id,    
         sj.name AS Job_Name,   
         sj.enabled,   
         sjh.run_status,    
         run_date,   
         run_time,  
    CONVERT (DATETIME,( LEFT(CAST(run_date AS VARCHAR(8)),4) + '.' +   SUBSTRING(CAST(run_date AS VARCHAR(8)), 5,2) + '.' +
									RIGHT(CAST(run_date AS VARCHAR(8)), 2)    + ' ' +  
									CAST( ((run_time/10000) %100) AS VARCHAR ) + ':' + CAST( ((run_time/100) %100) AS VARCHAR ) + ':' +
									CAST(  (run_time %100) AS VARCHAR ) ),102) AS run_date_time, 
	(run_duration % 100 ) + (((run_duration/100) % 100 ) * 60) + (((run_duration/10000) % 100 ) * 3600) AS run_duration, 
         CONVERT( VARCHAR(8000), MESSAGE) AS [MESSAGE]  

       FROM msdb.dbo.sysjobs AS sj   
         JOIN msdb.dbo.sysjobhistory AS sjh ON sj.job_id = sjh.job_id   
       WHERE step_id = 0   
         AND sjh.run_status = 1 
         AND run_duration >  CAST((15 * 60) AS VARCHAR(20)) 
         AND run_date > 20150711
--       ORDER BY run_date DESC, run_time DESC, step_id  
	ORDER BY Job_Name, run_date, run_time, step_id  



