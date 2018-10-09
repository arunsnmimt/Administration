USE [Audit]
GO
/****** Object:  StoredProcedure [dbo].[usp_ProcessFailedJobs]    Script Date: 03/06/2009 14:14:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_Process_Long_Running_Jobs]  

AS  

BEGIN

--TRUNCATE TABLE Long_Running_Jobs
	DECLARE @ServerName sysname  
	DECLARE @DatabaseName			AS VARCHAR(50)
	DECLARE @SQL AS VARCHAR(MAX)

	SELECT @DatabaseName = DB_NAME()

	IF object_id('tempdb..#DBA_JobList') IS NOT NULL
	BEGIN
		DROP TABLE #DBA_JobList
	END

	CREATE TABLE #DBA_JobList 
	(job_id                UNIQUEIDENTIFIER  NOT NULL, 
 	 Server_Name		   VARCHAR(30) ,		    
	 last_run_date         INT              NOT NULL,  
	 last_run_time         INT              NOT NULL,  
	 next_run_date         INT              NOT NULL,  
	 next_run_time         INT              NOT NULL,  
	 next_run_schedule_id  INT              NOT NULL,  
	 requested_to_run      INT              NOT NULL,  
	 request_source        INT              NOT NULL,  
	 request_source_id     sysname          NULL,  
	 running               INT    	       NOT NULL,   
	 current_step          INT              NOT NULL,  
	 current_retry_attempt INT              NOT NULL,  
	 job_state             INT              NOT NULL)


	BEGIN TRY
		DECLARE ServerCursor INSENSITIVE CURSOR  FOR  
		  SELECT Config_Value  
			FROM Audit_Config  
		   WHERE [Enabled] = 1
             AND Config_Setting = 'SERVER_NAME'  
		ORDER BY Config_Value  
	  
		OPEN ServerCursor

        FETCH NEXT FROM ServerCursor INTO @ServerName  
	END TRY

	BEGIN CATCH
		GOTO LogError
	END CATCH

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SQL = 	'ALTER TABLE #DBA_JobList ADD CONSTRAINT Server_Name_Default DEFAULT ''' + @ServerName + ''' FOR Server_Name'
		EXEC(@SQL)
--		ALTER TABLE #DBA_JobList ADD CONSTRAINT Server_Name_Default DEFAULT 'SQL-02'  FOR Server_Name

		-- Run it as SA (1), so ‘aaa’ is a dummy login name:
		SET @SQL = 'INSERT INTO #DBA_JobList (job_id, last_run_date,last_run_time,next_run_date,next_run_time,
									next_run_schedule_id,requested_to_run,request_source,
									request_source_id,running,current_step,current_retry_attempt,
									job_state)
				EXECUTE [' + @ServerName + '].master.dbo.xp_sqlagent_enum_jobs 1, ''aaa'' '
		EXEC (@SQL)

		ALTER TABLE #DBA_JobList DROP CONSTRAINT Server_Name_Default

		FETCH NEXT FROM ServerCursor INTO @ServerName  
	END

	CLOSE ServerCursor
	DEALLOCATE ServerCursor

	RETURN

LogError:
	
	EXECUTE Audit.dbo.usp_LogError NULL, @DatabaseName, NULL, NULL, NULL, TRUE	

	RETURN 99
END

/*


ALTER TABLE #DBA_JobList DROP CONSTRAINT Server_Name_Default

ALTER TABLE #DBA_JobList ADD CONSTRAINT Server_Name_Default DEFAULT 'BC-SQL-01'  FOR Server_Name

INSERT INTO #DBA_JobList (job_id, last_run_date,last_run_time,next_run_date,next_run_time,
   next_run_schedule_id,requested_to_run,request_source,
   request_source_id,running,current_step,current_retry_attempt,
   job_state)
   -- Run it as SA (1), so ‘aaa’ is a dummy login name:
    EXEC ('EXECUTE [BC-SQL-01].master.dbo.xp_sqlagent_enum_jobs 1, ''aaa'' ')


DELETE FROM #DBA_JobList WHERE job_state NOT IN (0,1,2,3,6,7) 

ALTER TABLE #DBA_JobList ADD Job_Name sysname

IF object_id('tempdb..#jobs') IS NOT NULL
BEGIN
	DROP TABLE #jobs
END


CREATE TABLE #jobs 
         (job_id                UNIQUEIDENTIFIER PRIMARY KEY,
          Job_Name               sysname)



EXEC ('INSERT INTO #jobs select job_id, name from ' + 
                 'msdb.dbo.sysjobs')


EXEC ('INSERT INTO #jobs select job_id, name from ' + 
                 '[BC-SQL-01].msdb.dbo.sysjobs')


UPDATE #DBA_JobList 
		   SET  Job_Name    =  j.Job_Name 
		FROM #DBA_JobList r 
            INNER JOIN #jobs j ON r.job_id = j.job_id




-- delete finished jobs:
DELETE Long_Running_Jobs 
FROM  Long_Running_Jobs l
WHERE  NOT EXISTS (SELECT 1 FROM #DBA_JobList r 
                     WHERE l.Server_Name = r.Server_Name 
                       AND l.job_id = r.job_id
					   AND l.Last_Run_Date = r.last_run_date
					   AND l.Last_Run_Time = r.last_run_time)



-- insert new records to central table:
INSERT INTO Long_Running_Jobs
(Server_Name,job_id,First_Check_Date,Job_Name,Job_Status, Last_Run_Date, Last_Run_Time )
SELECT Server_Name, job_id, GETDATE(), Job_Name ,job_state, last_run_date, last_run_time
FROM #DBA_JobList r
  WHERE job_state IN (0,1,2,3,6,7) 
    AND NOT EXISTS (SELECT 1 FROM Long_Running_Jobs l 
                    WHERE l.Server_Name = r.Server_Name 
                      AND l.job_id = r.job_id)

*/



/*











--	-- update existing records when job is still running:
--	UPDATE Long_Running_Jobs 
--      SET Time_Amount_Sec = Time_Amount_Sec + 
--                          DATEDIFF(ss,Last_Check_Date,GETDATE()),
--	    Last_Check_Date = GETDATE()
--	FROM Long_Running_Jobs l 
--      INNER JOIN #DBA_JobList r ON l.Server_Name = r.Server_Name 
--                              AND l.job_id = r.job_id
--	WHERE r.job_state IN (0,1,2,3,6,7)


--	DELETE Long_Running_Jobs
--		WHERE Server_Name = 'BC-SQL-01'


INSERT INTO dbo.Long_Running_Jobs
 
SELECT INTO #Temp 
exec ('msdb.dbo.sp_help_job')

CREATE TABLE #temp

(
job_id uniqueidentifier, 
originating_server  nvarchar(30), 
name sysname, 
enabled tinyint,
description  nvarchar(512), 
start_step_id  int,
category  sysname,
owner  sysname, 
notify_level_eventlog  int,
notify_level_email  int,
notify_level_netsend  int,
notify_level_page  int,
notify_email_operator  sysname,
notify_netsend_operator  sysname,
notify_page_operator sysname,
delete_level  int,
date_created  datetime,
date_modified  datetime,
version_number  int,
last_run_date  int,
last_run_time  int,
last_run_outcome  int,
next_run_date  int,
next_run_time  int,
next_run_schedule_id  int,
current_execution_status  int,
current_execution_step  sysname,
current_retry_attempt  int ,
has_step  int,
has_schedule  int,
has_target  int,
type int 
) 

TRUNCATE TABLE #Temp

INSERT INTO #Temp exec('msdb.dbo.sp_help_job')
INSERT INTO #Temp exec('[BC-SQL-01].msdb.dbo.sp_help_job')

[BC-SQL-01].master.dbo.xp_sqlagent_enum_jobs 1, 'aa'

sp_get_composite_job_info


--EXEC [BC-SQL-01].msdb.dbo.sp_help_job

--.msdb.dbo.sp_help_job

select * from #Temp

INSERT INTO dbo.Long_Running_Jobs
(Server_Name, Job_id, Last_Run_Date, Last_Run_Time, Job_Name)
SELECT spjob.originating_server, spjob.Job_id, spjob.last_run_date, spjob.last_run_time, spjob.name
FROM #Temp spjob
WHERE NOT EXISTS (SELECT * FROM Long_Running_Jobs LRJ
					WHERE spjob.Job_id = LRJ.Job_id
                      AND spjob.originating_server = LRJ.Server_Name
					AND spjob.last_run_date = LRJ.Last_Run_Date
					AND spjob.last_run_time = LRJ.Last_Run_Time)
AND
*/