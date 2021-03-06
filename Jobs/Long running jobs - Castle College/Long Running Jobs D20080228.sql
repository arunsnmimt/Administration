USE [Processed_Data]
GO
/****** Object:  StoredProcedure [dbo].[usp_Check_Jobs_Run_Time]    Script Date: 02/28/2008 10:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_Check_Jobs_Run_Time] 
--                @recipients varchar(100)                 
as  


-- Based on http://www.sqlservercentral.com/articles/Administering/controllingunusuallylongrunningjobs/1858/


/*

Script to create Holding table

CREATE TABLE [dbo].[DBA_Job_Steps_History](
	[history_id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[Insert_DT] [datetime] NULL DEFAULT (getdate()),
	[instance_id] [int] NULL,
	[job_id] [uniqueidentifier] NULL,
	[job_step_id] [int] NULL,
	[job_nm] [sysname] NOT NULL,
	[step_nm] [varchar](128) NULL,
	[last_run_date] [datetime] NULL,
	[duration] [int] NULL,
	[long_running_flag] [char](1) NULL,
)

*/



BEGIN  
SET NOCOUNT ON  
DECLARE @message varchar(4000), @instance_id INT, @flag_exists int, @subject varchar(80), 
                @long_running_flag char(1), @minid int, @maxid int, @job_id uniqueidentifier, 
                @job_nm varchar(128),@step_id int, @avgduration int, @duration int,  @step_nm varchar(128), @last_run_date datetime, @run_status as int, @recipients as varchar(100) 
  
DECLARE @allactivejobs table  (instance_id int, job_id uniqueidentifier, job_step_id int, 
                job_nm varchar(128), step_nm varchar(128), last_run_date datetime,duration int, long_running_flag char(1), tid int identity(1,1), run_status int)  

SELECT @instance_id = max(instance_id) FROM DBA_JOB_STEPS_HISTORY  
SET   @instance_id = IsNull(@instance_id,0) 
SET @message = 'Unusually Long Running Steps' + CHAR(13)
SET @message = @message + '----------------------------'  + CHAR(13) + CHAR(13)
SET @flag_exists = 0 
SET @subject = 'Unusually Long Running Steps on server  ' + @@servername 
SET @long_running_flag = 'N'
SET @recipients = 'mis@castlecollege.ac.uk'
  
INSERT INTO @allactivejobs 
  ( instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, duration, long_running_flag, run_status) 

SELECT      soh.instance_id,sj.job_id, sos.step_id,    sj.name ,sos.step_name,
               Convert (DATETIME, 
( Left(cast(run_date as varchar(8)),4) + '.' +       substring(cast(run_date as varchar(8)), 5,2) + '.' + 
                Right(cast(run_date as varchar(8)), 2)    + ' ' +    
                cast( ((run_time/10000) %100) as varchar ) + ':' +  cast( ((run_time/100) %100) as varchar ) + ':' + 
                cast(  (run_time %100) as varchar ) ),102),
/*
                CAST 
( Left(cast(run_date as varchar(8)),4) + '/' +       substring(cast(run_date as varchar(8)), 5,2) + '/' + 
                Right(cast(run_date as varchar(8)), 2)    + ' ' +    
                cast( ((run_time/10000) %100) as varchar ) + ':' +  cast( ((run_time/100) %100) as varchar ) + ':' + 
                cast(  (run_time %100) as varchar )         as datetime), 
*/
                ( run_duration % 100 )+                     -- seconds 
                (((run_duration/100) % 100 ) * 60) +        -- minutes in seconds 
                (((run_duration/10000) % 100 ) * 3600),     -- hours in seconds 
                'N', soh.run_status
FROM msdb..sysjobs sj 
                inner join msdb..sysjobsteps sos on sos.job_id = sj.job_id 
                inner join msdb..sysjobhistory soh on soh.job_id = sos.job_id and soh.step_id = sos.step_id 
where soh.instance_id NOT IN (SELECT instance_id FROM DBA_JOB_STEPS_HISTORY)	-- only retrieve data for jobs steps which have not been saved to History table     
  and ( soh.run_status = 1  or soh.run_status = 4 )								-- successful and in progress jobs. In progress jobs will not be saved to  History table
  and sj.job_id <> 'bd33e379-96f5-4000-b30d-7acccc615f76'						-- Exclude the job which runs this Stored Procedure
order by sj.name,sos.step_name

SELECT @minid = min(tid),@maxid = max(tid) FROM @allactivejobs

 while (@minid <= @maxid) 
  begin  
    SET @long_running_flag = 'N' 
    SELECT  @job_id = job_id,        @job_nm = job_nm,          @step_id = job_step_id, 
            @step_nm = step_nm,     @duration = duration,  @last_run_date = last_run_date, @run_status = run_status 
    FROM @allactivejobs
    where tid = @minid 

-- exclude checks the first 2 times 
IF ( (SELECT count(*) FROM DBA_JOB_STEPS_HISTORY where job_id = @job_id and job_step_id = @step_id) >= 2 ) 
 BEGIN 
    -- define average run time excluding unusually long running instances 
    SELECT @avgduration = avg(duration)      FROM DBA_JOB_STEPS_HISTORY 
    where job_id = @job_id and job_step_id = @step_id    and @long_running_flag = 'N' 
                                         
    SET @avgduration = IsNull(@avgduration,1) 

    IF (@avgduration > 0 and @avgduration < 60) 
     begin 
      IF (@duration > (@avgduration * 4)  )      -- @avgduration * 2
        begin 
          SET @flag_exists = 1 
          SET @long_running_flag = 'Y' 
        end
     end 
    IF (@avgduration > 60 and @avgduration < 1800) 
     begin 
      IF (@duration > (@avgduration * 2.5)  )    -- @avgduration * 1.3
        begin 
         SET @flag_exists = 1 
         SET @long_running_flag = 'Y' 
        end 
     end 
  
    IF (@avgduration > 1800) 
     begin 
      IF (@duration > (@avgduration * 2.2)  )    -- @avgduration * 1.2
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
      where tid = @minid 
    end 

  end                  

  SELECT @minid = @minid + 1 

end 


IF (@flag_exists = 1) 
 begin 
  exec master..xp_sendmail 
       @recipients = @recipients, 
       @subject = @subject,  
       @message = @message                
 end 


-- Exclude Jobs which are still running as this will effect the calculation of averages. When procdure is run again the stats will be added to the History table if the job has completed 
delete FROM @allactivejobs 
	where run_status = 4 and long_running_flag = 'N' 

INSERT INTO DBA_JOB_STEPS_HISTORY 
  ( instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, duration, long_running_flag) 
 SELECT instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, duration, long_running_flag 
  FROM @allactivejobs 
  
-- Only keep 60 days worth of history

Delete FROM DBA_JOB_STEPS_HISTORY  Where datediff(dd, last_run_date, getdate()) > 60

  
 SET NOCOUNT OFF 

END 
