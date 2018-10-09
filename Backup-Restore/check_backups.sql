--http://www.simple-talk.com/sql/database-administration/the-dba-script-thumb/

--see the full backups and log backups that have occurred in the past 10 days

SELECT  sd.name,
        bs.TYPE,
        bs.database_name,
        bs.backup_start_date as last_backup
FROM    master..sysdatabases sd
        Left outer join msdb..backupset bs on rtrim(bs.database_name) = rtrim(sd.name)
        left outer JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE sd.name = 'DBA_Info' and bs.backup_start_date > getdate() - 10
Order by sd.name,last_backup

------------------------------------------------------------------------------
-- quick read of error log files

DECLARE @TSQL  NVARCHAR(2000)
DECLARE @lC    INT


CREATE TABLE #TempLog (
      LogDate     DATETIME,
      ProcessInfo NVARCHAR(50),
      [Text] NVARCHAR(MAX))


CREATE TABLE #logF (
      ArchiveNumber     INT,
      LogDate           DATETIME,
      LogSize           INT
)

INSERT INTO #logF   
EXEC sp_enumerrorlogs
SELECT @lC = MIN(ArchiveNumber) FROM #logF


WHILE @lC IS NOT NULL
BEGIN
      INSERT INTO #TempLog
      EXEC sp_readerrorlog @lC
      SELECT @lC = MIN(ArchiveNumber) FROM #logF 
      WHERE ArchiveNumber > @lC
END

--could be adapted for anything

--Failed login counts. Useful for security audits.
SELECT Text,COUNT(Text) Number_Of_Attempts
FROM #TempLog where 
 Text like '%failed%' and ProcessInfo = 'LOGON'
 Group by Text

--Find Last Successful login. Useful to know before deleting "obsolete" accounts.
SELECT Distinct MAX(logdate) last_login,Text 
FROM #TempLog 
where ProcessInfo = 'LOGON'and Text like '%SUCCEEDED%' 
and Text not like '%NT AUTHORITY%'
Group by Text

DROP TABLE #TempLog
DROP TABLE #logF 
