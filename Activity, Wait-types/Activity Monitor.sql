-- SQL 2000
CREATE TABLE #spwho2 (
        SPID INT,
        Status VARCHAR(1000),
        LOGIN VARCHAR(1000),
        HostName VARCHAR(1000),
        BlkBy VARCHAR(1000),
        DBName VARCHAR(1000),
        Command VARCHAR(1000),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(1000),
        ProgramName VARCHAR(1000),
        SPID_1 INT --,
--        REQUESTID INT
)

INSERT INTO #spwho2 EXEC sp_who2

SELECT  *
FROM    #spwho2
WHERE DBName = 'CSS_AUDIT_DB'

---

USE master

PRINT @@SERVERNAME

IF object_id('tempdb..##DatabasesList') IS NOT NULL
BEGIN
	DROP TABLE ##DatabasesList
END

CREATE TABLE ##DatabasesList
(
	Database_Name VARCHAR(128)
)



INSERT INTO ##DatabasesList (Database_Name) VALUES ('TMC_DHL_BA')



SELECT  *
FROM    sys.databases
WHERE name IN  (SELECT Database_Name FROM ##DatabasesList)

--SELECT DB_NAME(dbid) AS Database_Name, * 
SELECT @@SERVERNAME AS Server_Name, DB_NAME(dbid) AS Database_Name, spid, kpid, blocked, waittime, uid, cpu, physical_io, memusage, login_time, last_batch, open_tran, status, hostname, program_name, hostprocess, cmd 
--SELECT @@SERVERNAME AS Server_Name, DB_NAME(dbid) AS Database_Name, spid, login_time, last_batch, status, hostname, program_name
FROM sys.sysprocesses 
--WHERE spid = 63
--WHERE DB_NAME(dbid) IN  (SELECT Database_Name FROM ##DatabasesList)
ORDER BY spid, kpid



SELECT DISTINCT DB_NAME(dbid) AS Database_Name
FROM sys.sysprocesses 

SELECT  *
FROM  sys.sysprocesses 
where spid = 133  


SELECT SP.spid, sp.dbid, des.session_id ,
des.status ,
des.login_name ,
des.[HOST_NAME] ,
SP.blocked, 
der.blocking_session_id ,
DB_NAME(SP.dbid) AS database_name ,
--DB_NAME(der.database_id) AS database_name ,
der.command ,
des.cpu_time ,
des.reads ,
des.writes ,
dec.last_write ,
des.[program_name] ,
der.wait_type ,
der.wait_time ,
der.last_wait_type ,
der.wait_resource ,
CASE des.transaction_isolation_level
WHEN 0 THEN 'Unspecified'
WHEN 1 THEN 'ReadUncommitted'
WHEN 2 THEN 'ReadCommitted'
WHEN 3 THEN 'Repeatable'
WHEN 4 THEN 'Serializable'
WHEN 5 THEN 'Snapshot'
END AS transaction_isolation_level --,
--OBJECT_NAME(dest.objectid, der.database_id) AS OBJECT_NAME ,
--SUBSTRING(dest.text, der.statement_start_offset / 2,
--( CASE WHEN der.statement_end_offset = -1
--THEN DATALENGTH(dest.text)
--ELSE der.statement_end_offset
--END - der.statement_start_offset ) / 2)
--AS [executing statement] ,
--deqp.query_plan
FROM sys.dm_exec_sessions des
LEFT JOIN sys.dm_exec_requests der
ON des.session_id = der.session_id
LEFT JOIN sys.dm_exec_connections dec
ON des.session_id = dec.session_id
INNER JOIN (select spid, dbid, blocked
from sys.sysprocesses) SP 
ON des.session_id = SP.spid
WHERE des.session_id <> @@SPID
AND  des.session_id > 50
AND DB_NAME(SP.dbid) = 'JCB_Live_Link_SATELLITE1'
ORDER BY des.session_id