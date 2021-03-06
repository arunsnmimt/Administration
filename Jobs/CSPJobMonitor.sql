CREATE PROCEDURE [dbo].[cspJobMonitor]
	(@listType VARCHAR(1000) = 'LastRun')
AS

IF @listType = 'LastRun'
	SELECT DISTINCT [name] AS 'Job Name',
		CASE [enabled] WHEN 1 THEN 'Enabled' ELSE 'Disabled' END AS 'Enabled',
		CAST (LTRIM(STR(run_date))+' '+STUFF(STUFF(RIGHT('000000'+LTRIM(STR(run_time)), 6) , 3, 0, ':'), 6, 0, ':') AS DATETIME) AS 'Last Run',
		step_id AS Step,
		CASE [h].[run_status] 
			WHEN 0 THEN 'Failed' ELSE 'Success'
			END AS 'Status' , 
		STUFF(STUFF(REPLACE(STR(run_duration,6),' ','0'),5,0,':'),3,0,':') AS 'Duration', 
		CASE next_run_date 
			  WHEN '0' THEN '9999-jan-01'
			  ELSE CAST (LTRIM(STR(next_run_date))+' '+STUFF(STUFF(RIGHT('000000'+LTRIM(STR(next_run_time)), 6) , 3, 0, ':'), 6, 0, ':') AS DATETIME) 
				END AS 'Next Run' 
	FROM msdb.dbo.sysjobs         j
	LEFT JOIN msdb.dbo.sysjobschedules s ON j.job_id = s.job_id
	JOIN msdb.dbo.sysjobhistory   h ON j.job_id = h.job_id
	WHERE step_id = 0
	  AND h.instance_id IN (SELECT MAX(sh.instance_id)
					FROM msdb.dbo.sysjobs sj   
					JOIN msdb.dbo.sysjobhistory   sh ON sj.job_id = sh.job_id
					WHERE h.step_id = 0
					GROUP BY sj.name	)
ELSE
IF @listType = 'Last24'
	SELECT DISTINCT [name] AS 'Job Name',
		CASE [enabled] WHEN 1 THEN 'Enabled' ELSE 'Disabled' END AS 'Enabled',
		CAST (LTRIM(STR(run_date))+' '+STUFF(STUFF(RIGHT('000000'+LTRIM(STR(run_time)), 6) , 3, 0, ':'), 6, 0, ':') AS DATETIME) AS 'Job Run',
		step_id AS Step,
		CASE [h].[run_status] 
			WHEN 0 THEN 'Failed' ELSE 'Success'
			END AS 'Status' , 
		STUFF(STUFF(REPLACE(STR(run_duration,6),' ','0'),5,0,':'),3,0,':') AS 'Duration', 
		CASE next_run_date 
			  WHEN '0' THEN '9999-jan-01'
			  ELSE CAST (LTRIM(STR(next_run_date))+' '+STUFF(STUFF(RIGHT('000000'+LTRIM(STR(next_run_time)), 6) , 3, 0, ':'), 6, 0, ':') AS DATETIME) 
				END AS 'Next Run' 
	FROM msdb.dbo.sysjobs         j
	LEFT JOIN msdb.dbo.sysjobschedules s ON j.job_id = s.job_id
	JOIN msdb.dbo.sysjobhistory   h ON j.job_id = h.job_id
	WHERE 
		CAST (LTRIM(STR(run_date))+' '+STUFF(STUFF(RIGHT('000000'+LTRIM(STR(run_time)), 6) , 3, 0, ':'), 6, 0, ':') AS DATETIME)
			  > DATEADD(HOUR, -24, GETDATE())
	 AND step_id = 0
	 
ELSE
  BEGIN
	SELECT [name] AS 'Job Name',
		CASE [enabled] WHEN 1 THEN 'Enabled' ELSE 'Disabled' END AS 'Enabled',
		CAST (LTRIM(STR(run_date))+' '+STUFF(STUFF(RIGHT('000000'+LTRIM(STR(run_time)), 6) , 3, 0, ':'), 6, 0, ':') AS DATETIME) AS 'Job Run',
		step_id AS Step,
		CASE [h].[run_status] 
			WHEN 0 THEN 'Failed' ELSE 'Success'
			END AS 'Status' , 
		STUFF(STUFF(REPLACE(STR(run_duration,6),' ','0'),5,0,':'),3,0,':') AS 'Duration', 
		CASE next_run_date 
			  WHEN '0' THEN '9999-jan-01'
			  ELSE CAST (LTRIM(STR(next_run_date))+' '+STUFF(STUFF(RIGHT('000000'+LTRIM(STR(next_run_time)), 6) , 3, 0, ':'), 6, 0, ':') AS DATETIME) 
				END AS 'Next Run' 
	FROM msdb.dbo.sysjobs         j
	LEFT JOIN msdb.dbo.sysjobschedules s ON j.job_id = s.job_id
	JOIN msdb.dbo.sysjobhistory   h ON j.job_id = h.job_id
	WHERE  j.name =  @listType
		 AND step_id = 0
    ORDER BY 3 DESC
  END


-- cspJobMonitor 'last24'
-- cspJobMonitor 'LastRun'
-- cspJobMonitor 'Backup Client Databases'

