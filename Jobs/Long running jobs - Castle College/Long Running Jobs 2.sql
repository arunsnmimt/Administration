SET NOCOUNT ON  
DECLARE @message varchar(4000) 
DECLARE @instance_id INT 
DECLARE @flag_exists int
DECLARE @subject varchar(80)
DECLARE @long_running_flag char(1)
DECLARE @minid int
DECLARE @maxid int
DECLARE @job_id uniqueidentifier
DECLARE @job_nm varchar(128)
DECLARE @step_id int
DECLARE @avgduration int
DECLARE @duration int
DECLARE @step_nm varchar(128)
DECLARE @last_run_date datetime
DECLARE @run_status as int
DECLARE @recipients as varchar(100) 
DECLARE @exceeded_1_hour char(1)  
DECLARE @time_of_day char(5)
DECLARE @allactivejobs table  (instance_id int, job_id uniqueidentifier, job_step_id int, 
                job_nm varchar(128), step_nm varchar(128), last_run_date datetime, time_of_day char(5), duration int, long_running_flag char(1), tid int identity(1,1), run_status int)  
SELECT @instance_id = max(instance_id) FROM DBA_JOB_STEPS_HISTORY  
SET   @instance_id = IsNull(@instance_id,0) 
SET @message = 'Unusually Long Running Steps' + CHAR(13)
SET @message = @message + '----------------------------'  + CHAR(13) + CHAR(13)
SET @flag_exists = 0 
SET @subject = 'Unusually Long Running Steps on server  ' + @@servername 
SET @long_running_flag = 'N'
SET @exceeded_1_hour = 'N' 
--SET @recipients = 'mis@castlecollege.ac.uk'
SET @recipients = 'michael.giles@castlecollege.ac.uk'
  
INSERT INTO @allactivejobs 
  ( instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, time_of_day, duration, long_running_flag, run_status) 

SELECT      soh.instance_id,sj.job_id, sos.step_id,    sj.name ,sos.step_name,
               Convert (DATETIME, 
( Left(cast(run_date as varchar(8)),4) + '.' +       substring(cast(run_date as varchar(8)), 5,2) + '.' + 
                Right(cast(run_date as varchar(8)), 2)    + ' ' +    
                cast( ((run_time/10000) %100) as varchar ) + ':' +  cast( ((run_time/100) %100) as varchar ) + ':' + 
                cast(  (run_time %100) as varchar ) ),102) as run_date_time,
				CASE LEN(CAST(run_time as varchar(10)))
				WHEN 3 THEN
					'00:0' + left(cast(run_time as varchar(10)),1)

				WHEN 4 THEN
					'00:' + left(cast(run_time as varchar(10)),2)

				WHEN 5 THEN
					'0' + left(cast(run_time as varchar(10)),1) + ':' + substring(cast(run_time as varchar(10)),2,2)

				WHEN 6 THEN
					left(cast(run_time as varchar(10)),2) + ':' + substring(cast(run_time as varchar(10)),3,2)
				ELSE
					'00:00'
				END,
                ( run_duration % 100 )+                     -- seconds 
                (((run_duration/100) % 100 ) * 60) +        -- minutes in seconds 
                (((run_duration/10000) % 100 ) * 3600),     -- hours in seconds 
                'N', soh.run_status
FROM msdb..sysjobs sj 
                inner join msdb..sysjobsteps sos on sos.job_id = sj.job_id 
                inner join msdb..sysjobhistory soh on soh.job_id = sos.job_id and soh.step_id = sos.step_id 
WHERE soh.instance_id NOT IN (SELECT instance_id FROM DBA_JOB_STEPS_HISTORY)	-- only retrieve data for jobs steps which have not been saved to History table     
  and ( soh.run_status = 1  or soh.run_status = 4 )								-- successful and in progress jobs. In progress jobs will not be saved to  History table
  and sj.job_id <> 'bd33e379-96f5-4000-b30d-7acccc615f76'						-- Exclude the job which runs this Stored Procedure
  and sj.job_id <> 'CD1D154D-8527-48CC-A250-ACC3F8CE7850'						-- Exclude Transactional Replication as this is constantly running 
order by sj.name,sos.step_name

SELECT @minid = min(tid),@maxid = max(tid) FROM @allactivejobs

WHILE (@minid <= @maxid) 
BEGIN  
    SET @long_running_flag = 'N'
    SET @exceeded_1_hour = 'N' 
 
    SELECT  @job_id = job_id,        
			@job_nm = job_nm,          
			@step_id = job_step_id, 
            @step_nm = step_nm,     
			@duration = duration,  
			@last_run_date = last_run_date,
			@time_of_day = time_of_day,
			@run_status = run_status 
    FROM @allactivejobs
    WHERE tid = @minid 

-- exclude checks the first 2 times 
	IF ((SELECT count(*) 
			FROM DBA_JOB_STEPS_HISTORY 
		   WHERE job_id = @job_id 
			 and job_step_id = @step_id) >= 2) 
	BEGIN 
	    
		-- define average run time excluding unusually long running instances 

		IF @job_id = 'd98ec5b3-2775-4291-bc97-35751abdbfbf' 
		BEGIN
		/*
		 For transaction backups just retrieve the stats for each specific time of day.
		 The one which runs at 00:00 takes considerably longer then the rest
	   */ 
		   SELECT @avgduration = avg(duration)      
   			 FROM DBA_JOB_STEPS_HISTORY 
			WHERE job_id = @job_id 
			  and job_step_id = @step_id    
			  and @long_running_flag = 'N' 
			  and time_of_day = @time_of_day
		END
		ELSE
		BEGIN
		   SELECT @avgduration = avg(duration)      
   			 FROM DBA_JOB_STEPS_HISTORY 
			WHERE job_id = @job_id 
			  AND job_step_id = @step_id    
			  AND @long_running_flag = 'N' 
		END
			                                    
		SET @avgduration = IsNull(@avgduration,1) 

		IF (@avgduration > 0 and @avgduration < 60) 
		 begin 
		  IF (@duration > (@avgduration * 4.0)  )      -- @avgduration * 2
			begin 
			  SET @flag_exists = 1 
			  SET @long_running_flag = 'Y' 
			end
		 end 

		IF (@avgduration > 60 and @avgduration < 600)  -- 1 min and 10 Min 
		 begin 
		  IF (@duration > (@avgduration * 3.0)  )    -- @avgduration * 1.3
			begin 
			 SET @flag_exists = 1 
			 SET @long_running_flag = 'Y' 
			end 
		 end 

		IF (@avgduration > 600 and @avgduration < 1800)  -- 10 min and 30 Min 
		 begin 
		  IF (@duration > (@avgduration * 2.0)  )    -- @avgduration * 1.3
			begin 
			 SET @flag_exists = 1 
			 SET @long_running_flag = 'Y' 
			end 
		 end 
	  
		IF (@avgduration > 1800) 
		 begin 
		  IF (@duration > (@avgduration * 1.5)  )    -- @avgduration * 1.2
		   begin 
			SET @flag_exists = 1 
			SET @long_running_flag = 'Y' 
		   end 
		 end 


		IF (@long_running_flag = 'Y') 
		begin 
			SELECT @message = @message + '   > '  + @job_nm + ': ' + @step_nm + CHAR(13)
			IF @run_status = 1 -- Job  step has completed
			Begin 
				SELECT @message = @message + '          '  +
			  ' Ran for: ' + Cast(@duration as Varchar(20)) + ' secs. Average run time: ' +  CAST(@avgduration as varchar(20)) + ' secs' + CHAR(13)
			End
			Else -- Job step is still running
			Begin
				SELECT @message = @message + '                    '  +
			  ' Currently running for: ' + Cast(@duration as Varchar(20)) + ' secs. Average run time: ' +  CAST(@avgduration as varchar(20)) + ' secs' + CHAR(13)
			End	
			
			update @allactivejobs 
    		   SET long_running_flag = 'Y' 
			 WHERE tid = @minid 
		end 

	END                  

	IF (@duration > 3600) 
	BEGIN
		SET @flag_exists = 1 
		SET @exceeded_1_hour = 'Y' 
	END

	IF (@exceeded_1_hour = 'Y')
	BEGIN
		SELECT @message = @message + '   > '  + @job_nm + ': ' + @step_nm + CHAR(13)
		IF @run_status = 1 -- Job  step has completed
		Begin 
			SELECT @message = @message + '          '  +
		  ' Ran for: ' + Cast(@duration as Varchar(20)) + ' secs. This is over 1 hour in duration ' + CHAR(13)
		End
		Else -- Job step is still running
		Begin
			SELECT @message = @message + '                    '  +
		  ' Currently running for: ' + Cast(@duration as Varchar(20)) + ' secs. This is over 1 hour in duration ' + CHAR(13)
		End	
	END 

	SELECT @minid = @minid + 1 

END 


IF (@flag_exists = 1) 
 begin 
  exec master..xp_sendmail 
       @recipients = @recipients, 
       @subject = @subject,  
       @message = @message                
 end 


-- Exclude Jobs which are still running as this will effect the calculation of averages. When procdure is run again the stats will be added to the History table if the job has completed 
DELETE FROM @allactivejobs 
	WHERE run_status = 4 and long_running_flag = 'N' 

INSERT INTO DBA_JOB_STEPS_HISTORY 
  ( instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, duration, long_running_flag) 
 SELECT instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, duration, long_running_flag 
  FROM @allactivejobs 
  
-- Only keep 60 days worth of history

DELETE FROM DBA_JOB_STEPS_HISTORY  WHERE datediff(dd, last_run_date, getdate()) > 60

  
SET NOCOUNT OFF 

