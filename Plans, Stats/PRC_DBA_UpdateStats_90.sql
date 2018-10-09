USE [DBA_ADMIN]
GO

/****** Object:  StoredProcedure [dbo].[PRC_DBA_UpdateStats_90]    Script Date: 11/27/2012 09:25:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PRC_DBA_UpdateStats_90]
(
 @DBNAME 	sysname=NULL, -- Specific Database name to do update stats - if not specified update stats for all db's
 @DEBUG 	char(1) = 'N', -- If 'Y' then it will not do the update stats, ony populate the temp table with commands and display output
/*Fix1.4
the size of the @scan variable was changed to accomodate all the other options.
*/
 @Scan varchar(18)='FULLSCAN', -- possible values 'FULLSCAN', 'SAMPLE XX PERCENT', 'SAMPLE XX ROWS'
 @updateStatsThreshold int = 24 -- Threshold in days the last stats update. Statistics will be updated if the last stats update is less than this threshold
 )
as
/*
Version			Date of Change			Comments
-----------------------------------------------------------
1.0				30/06/2010				First version for deployment in test environments
1.1				06/01/2011				changed the logic to include STATSDate function
1.2				02/03/2011				added the logic to includes which return NULL with STATDATE function
1.3				25/04/2011				To Fix Bug: this procedure try to update the Table Valued functions from sys.stats
1.4				11/05/2011				To fix the following issues
														1. quotename[] to the statistics name.
														2. Remove the hardcoded FULLSCAN & comments added.
														3. Extend the variable length of @Scan from 12 to 18.
1.5				24/05/2011				To change the update statistics thresholf from days to hour
1.6				17/11/2011				To include the collation of TURKEY builds Turkish_CI_AS
*/
set @DBNAME=upper(@DBNAME)
set @DEBUG=upper(@DEBUG)
set @Scan=upper(@Scan)


declare @DBNAME_NEXT sysname
declare @DBNAME_NEXT_CUR smallint
declare @STAT_NEXT_CUR smallint
declare @SQLCMD varchar(8000)
declare @SQLCMD1 varchar(8000)
declare @CURRENT_OBJ varchar(50)
declare @CUR_DBName sysname
declare @CUR_Obj_Name sysname
declare @CUR_Sch_Name sysname
declare @CUR_Stat_Name sysname
set @CURRENT_OBJ='PRC_DBA_UpdateStats_90'

/***Temporary table to take all the databases, excluding systemdbs*/
create table #TEMPDBS(DBNAME sysname)
/***Temporary table to take statistics information for a single database*/
CREATE TABLE #All_Stats
			(DBName sysname,	
			 Obj_Id int not null,		 
		     Obj_Name sysname,			 
			 Sch_Name sysname null,
			 Sch_Id int null,
			 Stat_Name sysname,
			 Stat_Date datetime,
			 Stat_Command varchar(4000)		 
			) 
/*Determine if all databases need to be considered for update statistics else choose the one that the user is interested in
*/
IF isnull(@DBNAME,'*')='*'
 BEGIN
	INSERT INTO #TEMPDBS(DBNAME) 
	SELECT name FROM sys.databases 
	WHERE name NOT IN ('master','msdb','tempdb','model','pubs','AdventureWorks','NorthWind')
	AND UPPER(name) NOT IN(SELECT UPPER(EXCL_OBJ_VALUE) FROM TBL_DBA_EXCLUSION WHERE EXCL_OBJ_TYPE='DATABASE_NAME' AND EXCL_PROGRAM='UPDATE_STATS')
	AND state  = 0 AND compatibility_level IN(90,100) AND is_read_only=0 AND is_in_standby=0
 END
ELSE
 BEGIN
	INSERT INTO #TEMPDBS(DBNAME) 
	SELECT name  FROM sys.databases 
	WHERE name NOT IN ('master','msdb','tempdb','model','pubs','AdventureWorks','NorthWind') 	
	AND UPPER(name)=@DBNAME
	AND state = 0 AND compatibility_level IN(90,100) AND is_read_only=0 AND is_in_standby=0
 END
/*Genereate the statists information for each database and put them in a temporary table #All_stats*/
declare CUR_DBLIST cursor for select DBNAME from #TEMPDBS	
open CUR_DBLIST
fetch next from CUR_DBLIST into @DBNAME_NEXT 
select @DBNAME_NEXT_CUR = @@FETCH_STATUS
while(@DBNAME_NEXT_CUR=0)
begin
--	print @DBNAME_NEXT
/*Flush the table for the new database*/
	truncate table #All_Stats
/*Insert db name , object id, object_name, stat_name & stat_date from the sys.stat table.*/
	set @SQLCMD='use '+quotename(@DBNAME_NEXT)+' '
				+'insert into #All_Stats (DBName,Obj_Id,Obj_Name,Stat_Name,Stat_Date) select '''+@DBNAME_NEXT+''',object_id,object_name(object_id),name,stats_date(object_id,stats_id) from sys.stats where isnull(stats_date(object_id,stats_id),''20000101'')<dateadd(hh,
-'+convert(varchar,@updateStatsThreshold)+', getdate())and object_id>100 and (objectproperty(object_id,''IsTable'')=1 or objectproperty(object_id,''IsView'')=1) '
	exec (@SQLCMD)
print (@SQLCMD)
/*update the schema id for the statistics*/
	set @SQLCMD='update AST set AST.Sch_Id=SO.schema_id from #All_Stats AST inner join '+quotename(@DBNAME_NEXT)+'.sys.objects SO on AST.Obj_Id=SO.object_id where AST.DBName='''+@DBNAME_NEXT+''''
	exec (@SQLCMD)
print (@SQLCMD)
/*update the schema name for the statistics*/
	set @SQLCMD='update AST set AST.Sch_Name =SC.name from #All_Stats AST inner join '+quotename(@DBNAME_NEXT)+'.sys.schemas SC on AST.Sch_Id=SC.schema_id where AST.DBName='''+@DBNAME_NEXT+''''
	exec (@SQLCMD)		
print (@SQLCMD)
	----process each record in the table ------------------------------------------
/*For each record in teh #All_Stats table 
Generate the UPDATE STATISTICS statement
update the table with the statement generated
	Execute the UPDATE STATISTICS*/
		declare CUR_STATS cursor for select DBName,Obj_Name,Sch_Name,Stat_Name  from #All_Stats where isnull(DBName,'#')<>'#' and isnull(Obj_Name,'#')<>'#' and isnull(Sch_Name,'#')<>'#' and isnull(Stat_Name,'#')<>'#'
		open CUR_STATS
		fetch next from CUR_STATS into @CUR_DBName,@CUR_Obj_Name,@CUR_Sch_Name,@CUR_Stat_Name  
		select @STAT_NEXT_CUR = @@FETCH_STATUS
		while(@STAT_NEXT_CUR=0)
		begin
			/*Fix 1.4
			1. quotename[] to the statistics name 2. Remove the hardcoded FULLSCAN 
			@CUR_Stat_Name in the below statement was replaced by quotename(@CUR_Stat_Name)
			FULLSCAN that was hardcoded was removed & replaced with the @scan variable*/
			set @SQLCMD='UPDATE STATISTICS '+quotename(@CUR_DBName)+'.'+quotename(@CUR_Sch_Name)+'.'+quotename(@CUR_Obj_Name)+'  '+quotename(@CUR_Stat_Name)+' WITH '+@Scan
			set @SQLCMD1='update #All_Stats set Stat_Command='''+@SQLCMD+''' where DBName='''+@CUR_DBName+''' and Obj_Name='''+@CUR_Obj_Name+''' and Sch_Name='''+@CUR_Sch_Name+''' and Stat_Name='''+@CUR_Stat_Name+''''
			
			if(@DEBUG='N') exec (@SQLCMD)
			if(@DEBUG='Y')
				begin
				exec(@SQLCMD1)
				print @SQLCMD1
				end
			fetch next from CUR_STATS into @CUR_DBName,@CUR_Obj_Name,@CUR_Sch_Name,@CUR_Stat_Name
			select @STAT_NEXT_CUR = @@FETCH_STATUS
		end
		close CUR_STATS
		deallocate CUR_STATS
	if(@DEBUG='Y') select * from #All_Stats
	-------------------------------------------------------------------------------
	fetch next from CUR_DBLIST into @DBNAME_NEXT 
	select @DBNAME_NEXT_CUR = @@FETCH_STATUS
end
close CUR_DBLIST
deallocate CUR_DBLIST
drop table #All_Stats
