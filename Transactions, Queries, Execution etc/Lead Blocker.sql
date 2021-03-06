SELECT
    SPID
    ,sp.STATUS
    ,loginame   = SUBSTRING(loginame, 1, 12)
    ,hostname   = SUBSTRING(hostname, 1, 12)
    ,blk        = CONVERT(CHAR(3), blocked)
    ,open_tran
    ,dbname     = SUBSTRING(DB_NAME(sp.dbid),1,10)
    ,cmd
    ,waittype
    ,waittime
    ,last_batch
    ,SQLStatement       =
        SUBSTRING
        (
            qt.text,
            er.statement_start_offset/2,
            (CASE WHEN er.statement_end_offset = -1
                THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
                ELSE er.statement_end_offset
                END - er.statement_start_offset)/2
        )
FROM master.dbo.sysprocesses sp
LEFT JOIN sys.dm_exec_requests er
    ON er.session_id = sp.spid
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
WHERE SPID IN (SELECT blocked FROM master.dbo.sysprocesses)
AND blocked = 0

 SELECT  DES.Session_ID AS [Root Blocking SESSION ID],
    DER.Status AS [Blocking SESSION Request Status],
    DES.Login_Time AS [Blocking SESSION LOGIN TIME],
    DES.Login_Name AS [Blocking SESSION LOGIN Name],
    DES.Host_Name AS [Blocking SESSION HOST Name],
    COALESCE(DER.Start_Time,DES.Last_Request_Start_Time) AS [Request START TIME],
    CASE
     WHEN DES.Last_Request_End_Time >= DES.Last_Request_Start_Time THEN DES.Last_Request_End_Time
     ELSE NULL
    END AS [Request END TIME],
    SUBSTRING(TEXT,DER.Statement_Start_Offset/2,
        CASE
         WHEN DER.Statement_End_Offset = -1 THEN DATALENGTH(TEXT)
         ELSE DER.Statement_End_Offset/2
        END) AS [Executing Command],
    CASE
     WHEN DER.Session_ID IS NULL THEN 'Blocking session does not have an open request and may be due to an uncommitted transaction.'
     WHEN DER.Wait_Type IS NOT NULL THEN 'Blocking session is currently experiencing a '+DER.Wait_Type+' wait.'
     WHEN DER.Status = 'Runnable' THEN 'Blocking session is currently waiting for CPU time.'
     WHEN DER.Status = 'Suspended' THEN 'Blocking session has been suspended by the scheduler.'
     ELSE 'Blocking session is currently in a '+DER.Status+' status.'
    END AS [Blocking Notes]
 FROM  Sys.DM_Exec_Sessions DES (READUNCOMMITTED)
 LEFT JOIN Sys.DM_Exec_Requests DER (READUNCOMMITTED)
   ON DER.Session_ID = DES.Session_ID
 OUTER APPLY Sys.DM_Exec_Sql_Text(DER.Sql_Handle)
 WHERE  DES.Session_ID IN (
         SELECT Blocking_Session_ID
         FROM Sys.DM_Exec_Requests (READUNCOMMITTED)
         WHERE Blocking_Session_ID <> 0
          AND Blocking_Session_ID NOT IN (
                   SELECT session_id
                   FROM Sys.DM_Exec_Requests (READUNCOMMITTED)
                   WHERE Blocking_Session_ID <> 0
                  )
         )