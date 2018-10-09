SELECT  name, create_date,  'ALTER DATABASE [' + name + '] SET RECOVERY SIMPLE WITH NO_WAIT'
FROM    sys.databases
WHERE recovery_model_desc = 'FULL'
AND name NOT IN ('model')
AND name NOT LIKE 'ReportServer%'
ORDER BY name
--WHERE name LIKE 'TMC_Reports%'

/*
SELECT  *
FROM    sys.databases
*/

/*
ALTER DATABASE [ARC_Maritime_May2012] SET RECOVERY SIMPLE WITH NO_WAIT
ALTER DATABASE [ARC_MARITIME_Nov2012] SET RECOVERY SIMPLE WITH NO_WAIT
*/

--ALTER DATABASE [model] SET RECOVERY SIMPLE WITH NO_WAIT

SELECT  *
FROM       sys.databases


SELECT  name, create_date,  'ALTER DATABASE [' + name + '] SET RECOVERY SIMPLE WITH NO_WAIT'
FROM    sys.databases
WHERE recovery_model_desc = 'FULL'
AND name NOT IN ('model')
AND name NOT LIKE 'ReportServer%'
ORDER BY name



SELECT 'DBCC CHECKDB(''' + name + ''') WITH no_infomsgs' AS CHECKDB_Full
FROM    sys.databases
WHERE database_id > 4
--and name not like 'Report%'
AND state_desc = 'ONLINE'
ORDER BY name

SELECT 'DBCC CHECKDB(''' + name + ''') WITH physical_only, no_infomsgs' AS CHECKDB_PhysicalOnly
FROM    sys.databases
WHERE database_id > 4
--AND name NOT LIKE '%UAT'
--AND name NOT LIKE '%TEST'
--and name not like 'Report%'
AND state_desc = 'ONLINE'
ORDER BY name
