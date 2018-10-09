
INSERT INTO  Admin_DBA.dbo.tbl_SQL_Session_Summary
SELECT DB_NAME(SP.dbid) AS Database_Name, des.[program_name], des.login_name, des.[HOST_NAME], des.[status], COUNT(*) AS No_Occurrences, CONVERT(VARCHAR(16), GETDATE(),120) AS Captured_DateTime
FROM sys.dm_exec_sessions des
LEFT JOIN sys.dm_exec_requests der
ON des.session_id = der.session_id
LEFT JOIN sys.dm_exec_connections dec
ON des.session_id = dec.session_id
INNER JOIN (select spid, dbid
from sys.sysprocesses) SP 
ON des.session_id = SP.spid
WHERE des.session_id <> @@SPID
AND  des.session_id > 50
GROUP BY  DB_NAME(SP.dbid), [program_name], login_name, [HOST_NAME],des.[status]

