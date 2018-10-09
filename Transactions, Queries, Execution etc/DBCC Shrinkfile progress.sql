/*  DBCC Shrinkfile progress

Various stages

Step ¦ Command				¦ Description
--------------------------------------------------------------------------------------------------------------
 1   ¦ DbccSpaceReclaim		¦ Clean up deferred allocations and purge empty extents preparing for data moves.  
 2   ¦ DbccFilesCompact		¦ Moves pages beyond the target to before the target and truncate file as required.
 3	 ¦ DbccLOBCompact		¦ Compacting the LOB data. 
 
*/

USE master

SELECT T.text, R.Status, R.Command, DatabaseName = DB_NAME(R.database_id)
	   , R.cpu_time, R.total_elapsed_time, R.blocking_session_id, R.percent_complete
FROM   sys.dm_exec_requests R
	   CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) T
	   WHERE command IN ('DbccSpaceReclaim','DbccFilesCompact','DbccLOBCompact') 
ORDER BY Command


/*

-- Check is shrink process is causing blocking

-- =================================================

DECLARE @BlockingSession AS INT
DECLARE @RecordCount AS INT
DECLARE @SessionID AS INT
DECLARE @SessionCount AS TINYINT

SET @SessionID = 1102 -- SessionID of Shrink commands

------------------------------

SET @BlockingSession = 0
SET @SessionCount    = 1

WHILE @BlockingSession = 0 AND @SessionCount = 1
BEGIN
	SET @SessionCount = (SELECT COUNT(*)
						FROM   sys.dm_exec_requests
						WHERE session_id = @SessionID)
	
	
	SET @RecordCount =	(SELECT COUNT(*)
						FROM   sys.dm_exec_requests R
							   CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) T
							   WHERE command IN ('DbccSpaceReclaim','DbccFilesCompact','DbccLOBCompact')) 
	   
	IF @RecordCount > 0
	BEGIN
		SET @BlockingSession =	(SELECT R.blocking_session_id
									FROM   sys.dm_exec_requests R
								   CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) T
								   WHERE command IN ('DbccSpaceReclaim','DbccFilesCompact','DbccLOBCompact')) 
	END	
	
	WAITFOR DELAY '00:00:30'								   
END

IF @BlockingSession > 0
BEGIN
	EXEC msdb.dbo.sp_send_dbmail @profile_name  = 'Microlise', @recipients = 'michael.giles@microlise.com', @body = 'Shrinking is blocking',@Subject = 'Shrinking is blocking'
END

IF @SessionCount = 0
BEGIN
	EXEC msdb.dbo.sp_send_dbmail @profile_name  = 'Microlise', @recipients = 'michael.giles@microlise.com', @body = 'Shrink query finished',@Subject = 'Shrink query finished'
END

*/

-- =================================================




--SELECT R.session_id,  T.text, R.Status, R.Command, DatabaseName = DB_NAME(R.database_id)
--	   , R.cpu_time, R.total_elapsed_time, R.blocking_session_id, R.percent_complete
--FROM   sys.dm_exec_requests R
--	   CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) T
--	   WHERE command IN ('DbccSpaceReclaim','DbccFilesCompact','DbccLOBCompact') 
--ORDER BY Command