/****************************************************/
/* Created by: SQL Profiler                         */
/* Date: 15/04/2015  16:58:30         */
/****************************************************/
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
SET @DurationMins = 5 --60 * 24 * 7 -- 1 week
SET @maxfilesize = 1024 --4096
--SET @DrivePath = 'c:\perflogs\'

--SET @DrivePath = 'C:\TraceOutput\' -- DHLSQLVS01, SQLCluster05
SET @DrivePath = 'G:\Trace Output\'
SET @DatabaseFilter = NULL --'TMC_MARITIME' -- Set to NULL for all databases
SET @ApplicationFilter =  NULL --'ESI%' 
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



/*
##################################################################
	Set Parameters - End
##################################################################
*/


SET @DateTime = DATEADD(MINUTE,@DurationMins,GETDATE())
--SET @DateTime = '2013-07-29 11:00'
SET @TraceName = @@SERVERNAME + '_' + @TraceNamePrefix + CONVERT(VARCHAR(30),GETDATE(),112) + '_' + REPLACE(CONVERT(VARCHAR(5),GETDATE(),108),':','') 
SET @TraceFile = @DrivePath + @TraceName

PRINT @TraceFile

EXEC @rc = sp_trace_create @TraceID OUTPUT, 0, @TraceFile, @maxfilesize, @Datetime 
IF (@rc != 0) GOTO ERROR








/*
-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 4096

-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 0, N'g:\Trace Output\UKS1CENT92_20150722_0929_DurationOver2min', @maxfilesize, NULL 
if (@rc != 0) goto error
*/

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
-- Occurs when a remote procedure call (RPC) has completed.
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 10, 2, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 6, @on
exec sp_trace_setevent @TraceID, 10, 8, @on
exec sp_trace_setevent @TraceID, 10, 9, @on
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 14, @on
exec sp_trace_setevent @TraceID, 10, 16, @on
exec sp_trace_setevent @TraceID, 10, 17, @on
exec sp_trace_setevent @TraceID, 10, 18, @on
exec sp_trace_setevent @TraceID, 10, 35, @on
exec sp_trace_setevent @TraceID, 10, 40, @on
-- Occurs when a Transact-SQL batch has completed.
/*
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 2, @on
exec sp_trace_setevent @TraceID, 12, 3, @on
exec sp_trace_setevent @TraceID, 12, 6, @on
exec sp_trace_setevent @TraceID, 12, 8, @on
exec sp_trace_setevent @TraceID, 12, 9, @on
exec sp_trace_setevent @TraceID, 12, 10, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 13, @on
exec sp_trace_setevent @TraceID, 12, 14, @on
exec sp_trace_setevent @TraceID, 12, 16, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 18, @on
exec sp_trace_setevent @TraceID, 12, 35, @on
exec sp_trace_setevent @TraceID, 12, 40, @on
-- Occurs when the Transact-SQL statement has completed.
exec sp_trace_setevent @TraceID, 41, 1, @on
exec sp_trace_setevent @TraceID, 41, 2, @on
exec sp_trace_setevent @TraceID, 41, 3, @on
exec sp_trace_setevent @TraceID, 41, 6, @on
exec sp_trace_setevent @TraceID, 41, 8, @on
exec sp_trace_setevent @TraceID, 41, 9, @on
exec sp_trace_setevent @TraceID, 41, 10, @on
exec sp_trace_setevent @TraceID, 41, 11, @on
exec sp_trace_setevent @TraceID, 41, 12, @on
exec sp_trace_setevent @TraceID, 41, 13, @on
exec sp_trace_setevent @TraceID, 41, 14, @on
exec sp_trace_setevent @TraceID, 41, 16, @on
exec sp_trace_setevent @TraceID, 41, 17, @on
exec sp_trace_setevent @TraceID, 41, 18, @on
exec sp_trace_setevent @TraceID, 41, 35, @on
exec sp_trace_setevent @TraceID, 41, 40, @on 
-- Indicates that a Transact-SQL statement within a stored procedure has finished executing.
exec sp_trace_setevent @TraceID, 45, 1, @on
exec sp_trace_setevent @TraceID, 45, 2, @on
exec sp_trace_setevent @TraceID, 45, 3, @on
exec sp_trace_setevent @TraceID, 45, 6, @on
exec sp_trace_setevent @TraceID, 45, 8, @on
exec sp_trace_setevent @TraceID, 45, 9, @on
exec sp_trace_setevent @TraceID, 45, 10, @on
exec sp_trace_setevent @TraceID, 45, 11, @on
exec sp_trace_setevent @TraceID, 45, 12, @on
exec sp_trace_setevent @TraceID, 45, 13, @on
exec sp_trace_setevent @TraceID, 45, 14, @on
exec sp_trace_setevent @TraceID, 45, 16, @on
exec sp_trace_setevent @TraceID, 45, 17, @on
exec sp_trace_setevent @TraceID, 45, 18, @on
exec sp_trace_setevent @TraceID, 45, 35, @on
exec sp_trace_setevent @TraceID, 45, 40, @on
*/

-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Profiler'
exec sp_trace_setfilter @TraceID, 10, 1, 6, N'.Net'
--exec sp_trace_setfilter @TraceID, 1, 1, 6, N'OrderGroupGrouping.OrderGroupGroupingID'



--set @intfilter = 5
--exec sp_trace_setfilter @TraceID, 3, 0, 4, @intfilter -- User Databases

--set @bigintfilter = 120000 	-- Duration greater or equal to 120 seconds
--exec sp_trace_setfilter @TraceID, 13, 0, 4, @bigintfilter


-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1


-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
