-- Drop temporary table if it exists
IF OBJECT_ID('tempdb..#info') IS NOT NULL
       DROP TABLE #info;

-- Create table to house database file information
CREATE TABLE #info (
     databasename VARCHAR(128)
     ,name VARCHAR(128)
    ,fileid INT
    ,filename VARCHAR(1000)
    ,filegroup VARCHAR(128)
    ,SIZE VARCHAR(25)
    ,maxsize VARCHAR(25)
    ,growth VARCHAR(25)
    ,USAGE VARCHAR(25));
    
-- Get database file information for each database  
SET NOCOUNT ON;
INSERT INTO #info
EXEC sp_MSforeachdb 'use ?
select ''?'',name,  fileid, filename,
filegroup = filegroup_name(groupid),
''size'' = convert(nvarchar(15), convert (bigint, size) * 8) + N'' KB'',
''maxsize'' = (case maxsize when -1 then N''Unlimited''
else
convert(nvarchar(15), convert (bigint, maxsize) * 8) + N'' KB'' end),
''growth'' = (case status & 0x100000 when 0x100000 then
convert(nvarchar(15), growth) + N''%''
else
convert(nvarchar(15), convert (bigint, growth) * 8) + N'' KB'' end),
''usage'' = (case status & 0x40 when 0x40 then ''log only'' else ''data only'' end)
from sysfiles
';

-- Identify database files that use default auto-grow properties
SELECT databasename AS [DATABASE Name]
      ,name AS [Logical Name]
      ,filename AS [Physical FILE Name]
      ,growth AS [AUTO-grow Setting]
      ,  
      CASE 
		WHEN RIGHT(filename,3) = 'mdf' AND growth <> '524288 KB' THEN 'ALTER DATABASE [' + databasename + '] MODIFY FILE ( NAME = N'''+ name +''', FILEGROWTH = 524288KB )'
		WHEN RIGHT(filename,3) = 'ldf' AND growth <> '262144 KB' THEN 'ALTER DATABASE [' + databasename + '] MODIFY FILE ( NAME = N'''+ name +''', FILEGROWTH = 262144KB )'
		ELSE ''
	  END AS Alter_Database_Command
      FROM #info
      WHERE ((RIGHT(filename,3) = 'mdf' AND growth <> '524288 KB')  OR (RIGHT(filename,3) = 'ldf' AND growth <> '262144 KB'))
      AND databasename LIKE 'TMC%'
--WHERE (usage = 'data only' AND growth = '1024 KB')
--   OR (usage = 'log only' AND growth = '10%')
--   WHERE RIGHT(filename,3) = 'ldf'
--   AND growth = '10%'
--   AND LEFT(databasename, 3) = 'TMC'
ORDER BY databasename




-- get rid of temp table
--DROP TABLE #info;