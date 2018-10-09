-- SQL Server 2000 - sp_who2 into query

CREATE TABLE #sp_who2 
(
   SPID INT,  
   Status VARCHAR(1000) NULL,  
   Login SYSNAME NULL,  
   HostName SYSNAME NULL,  
   BlkBy SYSNAME NULL,  
   DBName SYSNAME NULL,  
   Command VARCHAR(1000) NULL,  
   CPUTime INT NULL,  
   DiskIO INT NULL,  
   LastBatch VARCHAR(1000) NULL,  
   ProgramName VARCHAR(1000) NULL,  
   SPID2 INT
) 
GO

INSERT INTO #sp_who2
EXEC sp_who2
GO


SELECT  DISTINCT HostName
FROM    #sp_who2
ORDER BY HostName

DROP TABLE #sp_who2
--WHERE ....

--sp_who2

select 
    P.spid
--,   right(convert(varchar, 
            --dateadd(ms, datediff(ms, P.last_batch, getdate()), '1900-01-01'), 
            --121), 12) as 'batch_duration'
,   P.program_name
,   P.hostname
,   P.loginame
, p.*
from master.dbo.sysprocesses P
where P.spid > 50
--and      P.status not in ('background', 'sleeping')
--and      P.cmd not in ('AWAITING COMMAND'
--                    ,'MIRROR HANDLER'
--                    ,'LAZY WRITER'
--                    ,'CHECKPOINT SLEEP'
--                    ,'RA MANAGER')
order by batch_duration desc
