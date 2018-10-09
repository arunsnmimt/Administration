/****************************************************/
/* Created by: SQL Server 2008 R2 Profiler          */
/* Date: 04/01/2013  13:20:32         */
/****************************************************/

/*
				COPY FROM
 vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
*/

-- Create a Queue
DECLARE @rc INT
DECLARE @TraceID INT
DECLARE @maxfilesize BIGINT
DECLARE @DateTime DATETIME
DECLARE @DurationMins INT
DECLARE @DrivePath VARCHAR(200)
DECLARE @TraceNamePrefix VARCHAR(200)
DECLARE @TraceFile NVARCHAR(256)
DECLARE @TraceName VARCHAR(100)
DECLARE @TraceFileDate VARCHAR(14)
DECLARE @Waitfor VARCHAR(8)
DECLARE @SQL VARCHAR(1000)
DECLARE @ToRecipients VARCHAR(256)
DECLARE @CCRecipients VARCHAR(256)
DECLARE @Body VARCHAR(500)
DECLARE @Subject VARCHAR(500)
DECLARE @DatabaseFilter NVARCHAR(256)
DECLARE @ApplicationFilter NVARCHAR(256)
DECLARE @DeadlocksLockTimeouts BIT
DECLARE @ServerName VARCHAR(128)


/*  
 ##################################################################
	Set Parameters - Begin
 ##################################################################
*/
SET @ServerName = @@SERVERNAME
SET @DurationMins = 15
SET @maxfilesize = 3072
--SET @DrivePath = 'c:\perflogs\'
SET @DrivePath = 'G:\Trace Output\' -- DHLSQLVS01, SQLCluster05
SET @DatabaseFilter = NULL --'TMC_MARITIME' --NULL --'TMC_SPIRIT' --NULL --'TMC_TESCO'  --NULL --'JCB_Live_Link_SATELLITE1' -- Set to NULL for all databases
SET @ApplicationFilter =  NULL --'ESI%' -- --NULL --'MapClient' --NULL --'TMC Web Portal' --'Amber Event Processor' --NULL
SET @DeadlocksLockTimeouts = 0  -- (1)Enable (0)Disable

SET @TraceNamePrefix = ''

IF @DatabaseFilter IS NOT NULL
BEGIN
	SET @TraceNamePrefix = @DatabaseFilter + '_'
END


IF @ApplicationFilter IS NOT NULL
BEGIN
	SET @TraceNamePrefix = @TraceNamePrefix + REPLACE(REPLACE(@ApplicationFilter,'%',''),' ','_') + '_'
END


--SET @TraceNamePrefix = 'DAF_Live_Amber' -- No need to include server name
SET @ToRecipients = 'dba@microlise.com'
SET @CCRecipients = 'michael.giles@microlise.com'
SET @Subject = 'Trace Output created for Server: ' + @ServerName -- for xxxxx, BUG999999'
IF @DatabaseFilter IS NOT NULL
BEGIN
	SET @Subject = @Subject + ', Database Filter: ' + @DatabaseFilter
END
IF @ApplicationFilter IS NOT NULL
BEGIN
	SET @Subject = @Subject + ', Application Filter: ' + REPLACE(@ApplicationFilter,'%','')
END

PRINT @Subject

/*
##################################################################
	Set Parameters - End
##################################################################
*/


SET @DateTime = DATEADD(MINUTE,@DurationMins,GETDATE())
--SET @DateTime = '2013-07-29 11:00'
SET @TraceName = @@SERVERNAME + '_' + @TraceNamePrefix + CONVERT(VARCHAR(30),GETDATE(),112) + '_' + REPLACE(CONVERT(VARCHAR(5),GETDATE(),108),':','') 
SET @TraceFile = @DrivePath + @TraceName
SET @Waitfor = (RIGHT('0' + CONVERT(VARCHAR(2), (@DurationMins % 3600) / 60), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @DurationMins % 60), 2)) + ':30'
SET @Body = 'Trace output created on server: ' + @@SERVERNAME + ', Database: Admin_DBA, Table: trc_' +  @TraceName

PRINT @TraceFile

EXEC @rc = sp_trace_create @TraceID OUTPUT, 0, @TraceFile, @maxfilesize, @Datetime 
IF (@rc != 0) GOTO ERROR

/*
				COPY TO
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*/

-- Client side File and Table cannot be scripted

declare @on bit
set @on = 1

exec sp_trace_setevent @TraceID, 10, 7, @on
exec sp_trace_setevent @TraceID, 10, 15, @on
exec sp_trace_setevent @TraceID, 10, 31, @on
exec sp_trace_setevent @TraceID, 10, 8, @on
exec sp_trace_setevent @TraceID, 10, 16, @on
exec sp_trace_setevent @TraceID, 10, 48, @on
exec sp_trace_setevent @TraceID, 10, 64, @on
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 10, 9, @on
exec sp_trace_setevent @TraceID, 10, 17, @on
exec sp_trace_setevent @TraceID, 10, 25, @on
exec sp_trace_setevent @TraceID, 10, 41, @on
exec sp_trace_setevent @TraceID, 10, 49, @on
exec sp_trace_setevent @TraceID, 10, 2, @on
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 10, 18, @on
exec sp_trace_setevent @TraceID, 10, 26, @on
exec sp_trace_setevent @TraceID, 10, 34, @on
exec sp_trace_setevent @TraceID, 10, 50, @on
exec sp_trace_setevent @TraceID, 10, 66, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 35, @on
exec sp_trace_setevent @TraceID, 10, 51, @on
exec sp_trace_setevent @TraceID, 10, 4, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 60, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 6, @on
exec sp_trace_setevent @TraceID, 10, 14, @on
exec sp_trace_setevent @TraceID, 45, 7, @on
exec sp_trace_setevent @TraceID, 45, 55, @on
exec sp_trace_setevent @TraceID, 45, 8, @on
exec sp_trace_setevent @TraceID, 45, 16, @on
exec sp_trace_setevent @TraceID, 45, 48, @on
exec sp_trace_setevent @TraceID, 45, 64, @on
exec sp_trace_setevent @TraceID, 45, 1, @on
exec sp_trace_setevent @TraceID, 45, 9, @on
exec sp_trace_setevent @TraceID, 45, 17, @on
exec sp_trace_setevent @TraceID, 45, 25, @on
exec sp_trace_setevent @TraceID, 45, 41, @on
exec sp_trace_setevent @TraceID, 45, 49, @on
exec sp_trace_setevent @TraceID, 45, 10, @on
exec sp_trace_setevent @TraceID, 45, 18, @on
exec sp_trace_setevent @TraceID, 45, 26, @on
exec sp_trace_setevent @TraceID, 45, 34, @on
exec sp_trace_setevent @TraceID, 45, 50, @on
exec sp_trace_setevent @TraceID, 45, 66, @on
exec sp_trace_setevent @TraceID, 45, 3, @on
exec sp_trace_setevent @TraceID, 45, 11, @on
exec sp_trace_setevent @TraceID, 45, 35, @on
exec sp_trace_setevent @TraceID, 45, 51, @on
exec sp_trace_setevent @TraceID, 45, 4, @on
exec sp_trace_setevent @TraceID, 45, 12, @on
exec sp_trace_setevent @TraceID, 45, 28, @on
exec sp_trace_setevent @TraceID, 45, 60, @on
exec sp_trace_setevent @TraceID, 45, 5, @on
exec sp_trace_setevent @TraceID, 45, 13, @on
exec sp_trace_setevent @TraceID, 45, 29, @on
exec sp_trace_setevent @TraceID, 45, 61, @on
exec sp_trace_setevent @TraceID, 45, 6, @on
exec sp_trace_setevent @TraceID, 45, 14, @on
exec sp_trace_setevent @TraceID, 45, 22, @on
exec sp_trace_setevent @TraceID, 45, 62, @on
exec sp_trace_setevent @TraceID, 45, 15, @on
exec sp_trace_setevent @TraceID, 12, 7, @on
exec sp_trace_setevent @TraceID, 12, 15, @on
exec sp_trace_setevent @TraceID, 12, 31, @on
exec sp_trace_setevent @TraceID, 12, 8, @on
exec sp_trace_setevent @TraceID, 12, 16, @on
exec sp_trace_setevent @TraceID, 12, 48, @on
exec sp_trace_setevent @TraceID, 12, 64, @on
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 9, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 41, @on
exec sp_trace_setevent @TraceID, 12, 49, @on
exec sp_trace_setevent @TraceID, 12, 6, @on
exec sp_trace_setevent @TraceID, 12, 10, @on
exec sp_trace_setevent @TraceID, 12, 14, @on
exec sp_trace_setevent @TraceID, 12, 18, @on
exec sp_trace_setevent @TraceID, 12, 26, @on
exec sp_trace_setevent @TraceID, 12, 50, @on
exec sp_trace_setevent @TraceID, 12, 66, @on
exec sp_trace_setevent @TraceID, 12, 3, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 35, @on
exec sp_trace_setevent @TraceID, 12, 51, @on
exec sp_trace_setevent @TraceID, 12, 4, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 60, @on
exec sp_trace_setevent @TraceID, 12, 13, @on
exec sp_trace_setevent @TraceID, 41, 7, @on
exec sp_trace_setevent @TraceID, 41, 15, @on
exec sp_trace_setevent @TraceID, 41, 55, @on
exec sp_trace_setevent @TraceID, 41, 8, @on
exec sp_trace_setevent @TraceID, 41, 16, @on
exec sp_trace_setevent @TraceID, 41, 48, @on
exec sp_trace_setevent @TraceID, 41, 64, @on
exec sp_trace_setevent @TraceID, 41, 1, @on
exec sp_trace_setevent @TraceID, 41, 9, @on
exec sp_trace_setevent @TraceID, 41, 17, @on
exec sp_trace_setevent @TraceID, 41, 25, @on
exec sp_trace_setevent @TraceID, 41, 41, @on
exec sp_trace_setevent @TraceID, 41, 49, @on
exec sp_trace_setevent @TraceID, 41, 10, @on
exec sp_trace_setevent @TraceID, 41, 18, @on
exec sp_trace_setevent @TraceID, 41, 26, @on
exec sp_trace_setevent @TraceID, 41, 50, @on
exec sp_trace_setevent @TraceID, 41, 66, @on
exec sp_trace_setevent @TraceID, 41, 3, @on
exec sp_trace_setevent @TraceID, 41, 11, @on
exec sp_trace_setevent @TraceID, 41, 35, @on
exec sp_trace_setevent @TraceID, 41, 51, @on
exec sp_trace_setevent @TraceID, 41, 4, @on
exec sp_trace_setevent @TraceID, 41, 12, @on
exec sp_trace_setevent @TraceID, 41, 60, @on
exec sp_trace_setevent @TraceID, 41, 5, @on
exec sp_trace_setevent @TraceID, 41, 13, @on
exec sp_trace_setevent @TraceID, 41, 29, @on
exec sp_trace_setevent @TraceID, 41, 61, @on
exec sp_trace_setevent @TraceID, 41, 6, @on
exec sp_trace_setevent @TraceID, 41, 14, @on

-- Execution Plan
/*
exec sp_trace_setevent @TraceID, 122, 7, @on
exec sp_trace_setevent @TraceID, 122, 8, @on
exec sp_trace_setevent @TraceID, 122, 64, @on
exec sp_trace_setevent @TraceID, 122, 1, @on
exec sp_trace_setevent @TraceID, 122, 9, @on
exec sp_trace_setevent @TraceID, 122, 25, @on
exec sp_trace_setevent @TraceID, 122, 41, @on
exec sp_trace_setevent @TraceID, 122, 49, @on
exec sp_trace_setevent @TraceID, 122, 2, @on
exec sp_trace_setevent @TraceID, 122, 10, @on
exec sp_trace_setevent @TraceID, 122, 14, @on
exec sp_trace_setevent @TraceID, 122, 22, @on
exec sp_trace_setevent @TraceID, 122, 26, @on
exec sp_trace_setevent @TraceID, 122, 34, @on
exec sp_trace_setevent @TraceID, 122, 50, @on
exec sp_trace_setevent @TraceID, 122, 66, @on
exec sp_trace_setevent @TraceID, 122, 3, @on
exec sp_trace_setevent @TraceID, 122, 11, @on
exec sp_trace_setevent @TraceID, 122, 35, @on
exec sp_trace_setevent @TraceID, 122, 51, @on
exec sp_trace_setevent @TraceID, 122, 4, @on
exec sp_trace_setevent @TraceID, 122, 12, @on
exec sp_trace_setevent @TraceID, 122, 28, @on
exec sp_trace_setevent @TraceID, 122, 60, @on
exec sp_trace_setevent @TraceID, 122, 5, @on
exec sp_trace_setevent @TraceID, 122, 29, @on

*/

--  Deadlock Graph , Lock Timeouts
IF @DeadlocksLockTimeouts = 1
BEGIN
	exec sp_trace_setevent @TraceID, 148, 11, @on
	exec sp_trace_setevent @TraceID, 148, 51, @on
	exec sp_trace_setevent @TraceID, 148, 4, @on
	exec sp_trace_setevent @TraceID, 148, 12, @on
	exec sp_trace_setevent @TraceID, 148, 14, @on
	exec sp_trace_setevent @TraceID, 148, 26, @on
	exec sp_trace_setevent @TraceID, 148, 60, @on
	exec sp_trace_setevent @TraceID, 148, 64, @on
	exec sp_trace_setevent @TraceID, 148, 1, @on
	exec sp_trace_setevent @TraceID, 148, 41, @on
	exec sp_trace_setevent @TraceID, 27, 7, @on
	exec sp_trace_setevent @TraceID, 27, 15, @on
	exec sp_trace_setevent @TraceID, 27, 55, @on
	exec sp_trace_setevent @TraceID, 27, 8, @on
	exec sp_trace_setevent @TraceID, 27, 32, @on
	exec sp_trace_setevent @TraceID, 27, 56, @on
	exec sp_trace_setevent @TraceID, 27, 64, @on
	exec sp_trace_setevent @TraceID, 27, 1, @on
	exec sp_trace_setevent @TraceID, 27, 9, @on
	exec sp_trace_setevent @TraceID, 27, 41, @on
	exec sp_trace_setevent @TraceID, 27, 49, @on
	exec sp_trace_setevent @TraceID, 27, 57, @on
	exec sp_trace_setevent @TraceID, 27, 2, @on
	exec sp_trace_setevent @TraceID, 27, 10, @on
	exec sp_trace_setevent @TraceID, 27, 26, @on
	exec sp_trace_setevent @TraceID, 27, 58, @on
	exec sp_trace_setevent @TraceID, 27, 66, @on
	exec sp_trace_setevent @TraceID, 27, 3, @on
	exec sp_trace_setevent @TraceID, 27, 11, @on
	exec sp_trace_setevent @TraceID, 27, 35, @on
	exec sp_trace_setevent @TraceID, 27, 51, @on
	exec sp_trace_setevent @TraceID, 27, 4, @on
	exec sp_trace_setevent @TraceID, 27, 12, @on
	exec sp_trace_setevent @TraceID, 27, 52, @on
	exec sp_trace_setevent @TraceID, 27, 60, @on
	exec sp_trace_setevent @TraceID, 27, 13, @on
	exec sp_trace_setevent @TraceID, 27, 6, @on
	exec sp_trace_setevent @TraceID, 27, 14, @on
	exec sp_trace_setevent @TraceID, 27, 22, @on
	exec sp_trace_setevent @TraceID, 189, 7, @on
	exec sp_trace_setevent @TraceID, 189, 15, @on
	exec sp_trace_setevent @TraceID, 189, 55, @on
	exec sp_trace_setevent @TraceID, 189, 8, @on
	exec sp_trace_setevent @TraceID, 189, 32, @on
	exec sp_trace_setevent @TraceID, 189, 56, @on
	exec sp_trace_setevent @TraceID, 189, 64, @on
	exec sp_trace_setevent @TraceID, 189, 1, @on
	exec sp_trace_setevent @TraceID, 189, 9, @on
	exec sp_trace_setevent @TraceID, 189, 41, @on
	exec sp_trace_setevent @TraceID, 189, 49, @on
	exec sp_trace_setevent @TraceID, 189, 57, @on
	exec sp_trace_setevent @TraceID, 189, 2, @on
	exec sp_trace_setevent @TraceID, 189, 10, @on
	exec sp_trace_setevent @TraceID, 189, 26, @on
	exec sp_trace_setevent @TraceID, 189, 58, @on
	exec sp_trace_setevent @TraceID, 189, 66, @on
	exec sp_trace_setevent @TraceID, 189, 3, @on
	exec sp_trace_setevent @TraceID, 189, 11, @on
	exec sp_trace_setevent @TraceID, 189, 35, @on
	exec sp_trace_setevent @TraceID, 189, 51, @on
	exec sp_trace_setevent @TraceID, 189, 4, @on
	exec sp_trace_setevent @TraceID, 189, 12, @on
	exec sp_trace_setevent @TraceID, 189, 52, @on
	exec sp_trace_setevent @TraceID, 189, 60, @on
	exec sp_trace_setevent @TraceID, 189, 13, @on
	exec sp_trace_setevent @TraceID, 189, 6, @on
	exec sp_trace_setevent @TraceID, 189, 14, @on
	exec sp_trace_setevent @TraceID, 189, 22, @on
END




-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

IF @ApplicationFilter IS NOT NULL
BEGIN
	exec sp_trace_setfilter @TraceID, 10, 0, 6, @ApplicationFilter -- Application Filter (Include)
--	exec sp_trace_setfilter @TraceID, 10, 0, 6, N'Amber Event Processor' -- Application Filter (Include)
END
--exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - 66a39cd9-e79a-4cef-abed-c1a382b81ba1' -- SQLVS20
IF @DatabaseFilter IS NOT NULL
BEGIN
--	exec sp_trace_setfilter @TraceID, 35, 0, 6, N'DAF_telematics_Live_Amber' -- DatabaseName Filter (Include)
	exec sp_trace_setfilter @TraceID, 35, 0, 6, @DatabaseFilter -- DatabaseName Filter (Include)
END
--exec sp_trace_setfilter @TraceID, 1, 0, 6, N'UPDATE tbl_businessevent'
-- Set the trace status to start
set @intfilter = @@SPID
exec sp_trace_setfilter @TraceID, 12, 0, 1, @intfilter -- Exclude SPID
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
--goto finish

DECLARE @TraceRunning AS TINYINT

SET @TraceRunning = 1

WHILE @TraceRunning = 1
BEGIN
	SET @TraceRunning =	(SELECT  COUNT(*)
							FROM    sys.traces
							WHERE id = @TraceID)
	WAITFOR DELAY '00:00:30'
END


/*
				COPY FROM
 vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
*/






SET @SQL = 'SELECT * INTO Admin_DBA.dbo.trc_'+ @TraceName + ' FROM fn_trace_gettable ( ''' + @TraceFile + '.trc'' , 1 )'

EXEC(@SQL)

EXEC msdb.dbo.sp_send_dbmail	
			@profile_name  = 'Microlise',
			@recipients = @ToRecipients,
			@copy_recipients = @CCRecipients,
			@importance = 'Normal',
			@subject = @Subject,
			@body = @Body

error: 
select ErrorCode=@rc

finish: 
go




 
