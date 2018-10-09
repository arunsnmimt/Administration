--http://www.sqlservercentral.com/articles/DMV/64425/


CREATE PROC [dbo].[dba_WhatSQLIsExecuting]
AS
/*--------------------------------------------------------------------
Purpose: Shows what individual SQL statements are currently executing.
----------------------------------------------------------------------
Parameters: None.
Revision History:
	24/07/2008  Ian_Stirk@yahoo.com Initial version
Example Usage:
	1. exec YourServerName.master.dbo.dba_WhatSQLIsExecuting               
---------------------------------------------------------------------*/
BEGIN
    -- Do not lock anything, and do not get held up by any locks.
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    -- What SQL Statements Are Currently Running?
    SELECT [Spid] = session_Id
	, ecid
	, [Database] = DB_NAME(sp.dbid)
	, [User] = nt_username
	, [Status] = er.status
	, [Wait] = wait_type
	, [Individual Query] = SUBSTRING (qt.text, 
             er.statement_start_offset/2,
	(CASE WHEN er.statement_end_offset = -1
	       THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
		ELSE er.statement_end_offset END - 
                                er.statement_start_offset)/2)
	,[Parent Query] = qt.text
	, Program = program_name
	, Hostname
	, nt_domain
	, start_time
    FROM sys.dm_exec_requests er
    INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
    CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
    WHERE session_Id > 50              -- Ignore system spids.
    AND session_Id NOT IN (@@SPID)     -- Ignore this current statement.
    ORDER BY 1, 2
END
