CREATE procedure dbo.usp_Check_Jobs_Run_Time 
                @recipients varchar(100)                 
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

Set @recipients = 'michael.giles@castlecollege.ac.uk'

BEGIN  
SET NOCOUNT ON  
declare @message varchar(4000), @instance_id INT, @flag_exists int, @subject varchar(80), 
                @long_running_flag char(1), @minid int, @maxid int, @job_id uniqueidentifier, 
                @job_nm varchar(128),@step_id int, @avgduration int, @duration int,  @step_nm varchar(128), @last_run_date datetime 
  
DECLARE @allactivejobs table  (instance_id int, job_id uniqueidentifier, job_step_id int, 
                job_nm varchar(128), step_nm varchar(128), last_run_date datetime,duration int, long_running_flag char(1), tid int identity(1,1), run_status int)  

SELECT @instance_id = max(instance_id) from DBA_JOB_STEPS_HISTORY  
set   @instance_id = IsNull(@instance_id,0) 
set @message = 'Unusually Long Run Steps:  ' 
set @flag_exists = 0 
set @subject = 'Unusually Long Run Steps on server  ' + @@servername 
set @long_running_flag = 'N'
  
insert into @allactivejobs 
  ( instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, duration, long_running_flag, run_status) 

select      soh.instance_id,sj.job_id, sos.step_id,    sj.name ,sos.step_name,
                CAST 
( Left(cast(run_date as varchar(8)),4) + '/' +       substring(cast(run_date as varchar(8)), 5,2) + '/' + 
                Right(cast(run_date as varchar(8)), 2)    + ' ' +    
                cast( ((run_time/10000) %100) as varchar ) + ':' +  cast( ((run_time/100) %100) as varchar ) + ':' + 
                cast(  (run_time %100) as varchar )         as datetime), 
                ( run_duration % 100 )+                     -- seconds 
                (((run_duration/100) % 100 ) * 60) +        -- minutes in seconds 
                (((run_duration/10000) % 100 ) * 3600),     -- hours in seconds 
                'N', soh.run_status
from msdb..sysjobs sj 
                inner join msdb..sysjobsteps sos on sos.job_id = sj.job_id 
                inner join msdb..sysjobhistory soh on soh.job_id = sos.job_id and soh.step_id = sos.step_id 
where soh.instance_id NOT IN (SELECT instance_id from DBA_JOB_STEPS_HISTORY) --- only retrieve data for jobs steps which have not been saved to History table     
and ( soh.run_status = 1  or soh.run_status = 4 ) -- successful and in progress jobs. In progress jobs will not be saved to  History table
order by sj.name,sos.step_name

 select @minid = min(tid),@maxid = max(tid) from @allactivejobs

 while (@minid <= @maxid) 
  begin  
    set @long_running_flag = 'N' 
    select  @job_id = job_id,        @job_nm = job_nm,          @step_id = job_step_id, 
            @step_nm = step_nm,     @duration = duration,  @last_run_date = last_run_date 
    from @allactivejobs
    where tid = @minid 

-- exclude checks the first 2 times 
IF ( (select count(*) from DBA_JOB_STEPS_HISTORY where job_id = @job_id and job_step_id = @step_id) >= 2 ) 
 BEGIN 
    -- define average run time excluding unusually long running instances 
    select @avgduration = avg(duration)      from DBA_JOB_STEPS_HISTORY 
    where job_id = @job_id and job_step_id = @step_id    and @long_running_flag = 'N' 
                                         
    set @avgduration = IsNull(@avgduration,1) 

    IF (@avgduration > 0 and @avgduration < 60) 
     begin 
      IF (@duration > (@avgduration * 2.5)  )      -- @avgduration * 2
        begin 
          select @message = @message + ' 
           ' + @job_nm + ': ' + @step_nm 
          set @flag_exists = 1 
          set @long_running_flag = 'Y' 
        end
     end 
    IF (@avgduration > 60 and @avgduration < 1800) 
     begin 
      IF (@duration > (@avgduration * 1.8)  )    -- @avgduration * 1.3
        begin 
         select @message = @message + ' 
          ' + @job_nm + ': ' + @step_nm 
         set @flag_exists = 1 
         set @long_running_flag = 'Y' 
        end 
     end 
  
    IF (@avgduration > 1800) 
     begin 
      IF (@duration > (@avgduration * 1.5)  )    -- @avgduration * 1.2
       begin 
        select @message = @message + ' 
        ' + @job_nm + ': ' + @step_nm 

        set @flag_exists = 1 
        set @long_running_flag = 'Y' 
       end 
     end 

   IF (@long_running_flag = 'Y') 
    begin 
     update @allactivejobs 
      set long_running_flag = 'Y' 
      where tid = @minid 
    end 

  end                  

  select @minid = @minid + 1 
end 


IF (@flag_exists = 1) 
 begin 
  exec master..xp_sendmail 
       @recipients = @recipients, 
       @subject = @subject,  
       @message = @message                
 end 


-- Exclude Jobs which are still running as this will effect the calculation of averages. When procdure is run again the stats will be added to the History table if the job has completed 
delete from @allactivejobs 
	where run_status = 4 and long_running_flag = 'N' 

insert into DBA_JOB_STEPS_HISTORY 
  ( instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, duration, long_running_flag) 
 select instance_id, job_id , job_step_id, job_nm, step_nm,  last_run_date, duration, long_running_flag 
  from @allactivejobs 
  
-- Only keep 60 days worth of history

Delete from DBA_JOB_STEPS_HISTORY  Where datediff(dd, Insert_DT, getdate()) > 60

  
 SET NOCOUNT OFF 

END 
