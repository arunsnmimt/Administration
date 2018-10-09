
USE msdb

DECLARE @EnabledJobOnly AS BIT

SET @EnabledJobOnly = 1

DECLARE @EnabledJobValues TABLE
(
  Value bit
)

INSERT INTO @EnabledJobValues VALUES(1)


IF @EnabledJobOnly <> 1
BEGIN
	INSERT INTO @EnabledJobValues VALUES(0)
END

IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'dbo.udf_schedule_description')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN

	SELECT dbo.sysjobs.name, CAST(dbo.sysschedules.active_start_time / 10000 AS VARCHAR(10))  
	+ ':' + RIGHT('00' + CAST(dbo.sysschedules.active_start_time % 10000 / 100 AS VARCHAR(10)), 2) AS active_start_time,  
	dbo.udf_schedule_description(dbo.sysschedules.freq_type, dbo.sysschedules.freq_interval, 
	dbo.sysschedules.freq_subday_type, dbo.sysschedules.freq_subday_interval, dbo.sysschedules.freq_relative_interval, 
	dbo.sysschedules.freq_recurrence_factor, dbo.sysschedules.active_start_date, dbo.sysschedules.active_end_date, 
	dbo.sysschedules.active_start_time, dbo.sysschedules.active_end_time) AS ScheduleDscr, dbo.sysjobs.enabled 
	FROM dbo.sysjobs INNER JOIN 
	dbo.sysjobschedules ON dbo.sysjobs.job_id = dbo.sysjobschedules.job_id INNER JOIN 
	dbo.sysschedules ON dbo.sysjobschedules.schedule_id = dbo.sysschedules.schedule_id  
END

ELSE

BEGIN

	/*---------------------------------------------------------------------------------------------------------*\

	  this script is based on Ken Simmons article
	  the article can be found here in the following link:

	  http://www.mssqltips.com/sqlservertip/1622/generate-sql-agent-job-schedule-report/

 
	  it is a great tool to find out which jobs are running on the servers.
	  it has also extra info about jobs.

	  Marcelo Miorelli jjradha@yahoo.it

	  10-Aug-2012 - Sri Krishna Janmasthami Day

	\*---------------------------------------------------------------------------------------------------------*/

 	select 'Server'=left(@@ServerName,50),
		   'JobName'=left(S.name,108),
		   'Category' = coalesce(cat.name, '??'),
		   'ScheduleName'=left(ss.name,50),
		   'Enabled'=
			  CASE (S.enabled)
				WHEN 0 THEN'No'
				WHEN 1 THEN'Yes'
				ELSE '??'
			  END,
		   'Frequency'=
			  CASE(ss.freq_type)
			   WHEN 1 THEN'Once'
			   WHEN 4 THEN'Daily'
			   WHEN 8 THEN 
						   ( case when (ss.freq_recurrence_factor > 1) then 
									  'Every ' + convert(varchar(3),ss.freq_recurrence_factor)+ ' Weeks'
							 else 'Weekly' end )
			   WHEN 16 THEN
						   ( case when (ss.freq_recurrence_factor > 1) then
									'Every '+convert(varchar(3),ss.freq_recurrence_factor)+ ' Months'
							 else 'Monthly' end )
			   WHEN 32 THEN 'Every '+ convert(varchar(3),ss.freq_recurrence_factor)+ ' Months' 
			   -- RELATIVE
			   WHEN 64 THEN'SQL Startup'
			   WHEN 128 THEN'SQL Idle'
			   ELSE'??'
			 END,
			'Interval'=
			 CASE
			   WHEN (freq_type = 1)then'One time only'
			   WHEN (freq_type = 4 and freq_interval = 1) then 'Every Day'
			   WHEN (freq_type = 4 and freq_interval > 1) then'Every '+ convert(varchar(10),freq_interval) + ' Days'
			   WHEN (freq_type = 8) then ( select'Weekly Schedule' = D1+ D2+D3+D4+D5+D6+D7 
											 from (select ss.schedule_id,
														  freq_interval,
														 'D1' = CASE WHEN (freq_interval & 1 <> 0) then 'Sun '
																	 ELSE ''
																END,
														 'D2'= CASE WHEN (freq_interval & 2 <> 0) then 'Mon '
																	ELSE ''
																END,
														 'D3'= CASE WHEN (freq_interval & 4 <> 0)then 'Tue ' 
																   ELSE ''
															   END,
														 'D4'= CASE WHEN (freq_interval & 8 <> 0)then 'Wed '
																	ELSE''
															   END,
														 'D5'= CASE WHEN (freq_interval & 16 <> 0)then'Thu '
																	ELSE ''
															   END,
														 'D6'= CASE WHEN (freq_interval & 32 <> 0)then'Fri '
																   ELSE ''
															   END,
														 'D7'= CASE WHEN (freq_interval & 64 <> 0)then 'Sat '
																   ELSE''
															   END 
														 from msdb..sysschedules ss 
														 where freq_type = 8)as F 
											 where schedule_id = sj.schedule_id)
			   WHEN (freq_type = 16)then 'Day '+convert(varchar(2),freq_interval)
			   WHEN (freq_type = 32)then (select freq_rel + WDAY 
											from (select ss.schedule_id
														,'freq_rel'= CASE(freq_relative_interval)
																		 WHEN 1 then'First'
																		 WHEN 2 then'Second'
																		 WHEN 4 then'Third'
																		 WHEN 8 then'Fourth'
																		 WHEN 16 then'Last'
																		 ELSE'??'
																	 END
														,'WDAY'=     CASE (freq_interval)
																		WHEN 1 then' Sun'
																		WHEN 2 then' Mon'
																		WHEN 3 then' Tue'
																		WHEN 4 then' Wed'
																		WHEN 5 then' Thu'
																		WHEN 6 then' Fri'
																		WHEN 7 then' Sat'
																		WHEN 8 then' Day'
																		WHEN 9 then' Weekday'
																		WHEN 10 then' Weekend'
																		ELSE'??'
																	 END
														from msdb..sysschedules ss
													   where ss.freq_type = 32)as WS 
												  where WS.schedule_id =ss.schedule_id)
			 else'n/a'
			 END,
			 'Time'=CASE (freq_subday_type)
						WHEN 1 then left(stuff((stuff((replicate('0', 6 -len(Active_Start_Time)))
									+convert(varchar(6),Active_Start_Time),3,0,':')),6,0,':'),8)
						WHEN 2 then'Every '+convert(varchar(10),freq_subday_interval)+' seconds'
						WHEN 4 then'Every '+convert(varchar(10),freq_subday_interval)+' minutes'
						WHEN 8 then'Every '+convert(varchar(10),freq_subday_interval)+' hours'
						ELSE'??'
			 END,
			 'Next Run Time'=CASE SJ.next_run_date
					   WHEN 0 THEN cast('n/a'as char(10))
					   ELSE convert(char(10),convert(datetime,convert(char(8),SJ.next_run_date)),120)
							+' '+left(stuff((stuff((replicate('0', 6 -len(next_run_time)))
							+convert(varchar(6),next_run_time),3,0,':')),6,0,':'),8)
			 END,
			 'Avg Job Duration' = coalesce( JH.Avg_Duration,'??'),
			 'Max. Duration' = coalesce( JH.Max_Duration,'??'),
			 'Num. of Executions' = coalesce( JH.Num_of_Executions,'0')
	from msdb.dbo.sysjobschedules SJ 
	join msdb.dbo.sysjobs S 
		 on S.job_id = SJ.job_id
	INNER JOIN msdb.dbo.syscategories cat 
			   ON S.category_id = cat.category_id
	join msdb.dbo.sysschedules SS 
		 on ss.schedule_id = sj.schedule_id 
	left join( 
	SELECT jh.job_ID,
	RTRIM(CAST(CONVERT(CHAR(2), DATEADD(ss,MAX(CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)), 2, 2) AS INT)* 60 * 60
	+ CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)), 4, 2) AS INT) * 60 + CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)), 6, 2) AS INT)),
	0), 13) - 1 AS CHAR(2))) + '.' + CONVERT(CHAR(8), DATEADD(ss,MAX(CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)),
	 2, 2) AS INT) * 60 * 60  + CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)),4, 2) AS INT) * 60  + CAST(SUBSTRING(CAST(run_duration
	+ 1000000 AS VARCHAR(7)),6, 2) AS INT)), 0), 14) Max_Duration, RTRIM(CAST(CONVERT(CHAR(2), DATEADD(ms,AVG(( CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)), 2, 2) AS INT)
	 * 60 * 60 + CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)), 4, 2) AS INT) * 60 + CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)), 6, 2) AS INT) )
	* 1000), 0), 13) - 1 AS CHAR(2))) + '.' + CONVERT(CHAR(12), DATEADD(ms, AVG(( CAST(SUBSTRING(CAST(run_duration + 1000000 AS VARCHAR(7)),
	2, 2) AS INT) * 60 * 60 + CAST(SUBSTRING(CAST(run_duration  + 1000000 AS VARCHAR(7)),  4, 2) AS INT) * 60 + CAST(SUBSTRING(CAST(run_duration
	  + 1000000 AS VARCHAR(7)),  6, 2) AS INT) )* 1000), 0), 14) Avg_Duration,'Num_of_Executions' = COUNT(*) 
	FROM    msdb.dbo.sysjobhistory jh 
	WHERE    step_id = 0 
						GROUP BY jh.job_ID
								  ) as JH 
		 on S.job_id = JH.job_id
		 WHERE S.[enabled] IN (SELECT value FROM @EnabledJobValues)
	order by S.name 

END