--USE TMC_MAN_RENTAL

SELECT DB_NAME() AS Database_Name,
    MIN(STATS_DATE(object_id, stats_id)) AS first_update_date,
    MAX(STATS_DATE(object_id, stats_id)) AS last_update_date
FROM sys.stats 
WHERE STATS_DATE(object_id, stats_id) IS NOT NULL
AND STATS_DATE(object_id, stats_id) > CAST(CONVERT(VARCHAR, GETDATE(),101) AS Datetime)




    SELECT sch.name + '.' + so.name, so.object_id, ss.name, ss.stats_id
    FROM sys.stats ss
    JOIN sys.objects so ON ss.object_id = so.object_id
    JOIN sys.schemas sch ON so.schema_id = sch.schema_id
    WHERE so.name =  'tbl_VehicleState'


DBCC SHOW_STATISTICS ("tbl_Vehicles", PK_tbl_Vehicles);

SELECT  *
FROM    sys.dm_db_stats_properties (1854629650, 1)

SELECT DB_NAME() AS Database_Name,
	OBJECT_NAME(st.object_id) AS [Object_Name],
	st.name,
	'USE ['+DB_NAME()+']; UPDATE STATISTICS [' + OBJECT_NAME(st.object_id)  + '] [' + st.name + '] WITH SAMPLE 40 PERCENT',
    STATS_DATE(st.object_id, st.stats_id) AS stats_update_date
FROM sys.stats st INNER JOIN sys.objects ob
	ON st.object_id = ob.object_id
	AND ob.[type] = 'U' -- USER_TABLE'
-- Index Stats	
		INNER JOIN  sys.indexes ix
				ON st.object_id = ix.object_id
				AND st.name = ix.name
-- Index Stats
WHERE STATS_DATE(st.object_id, st.stats_id) IS NOT  NULL
--AND OBJECT_NAME(st.object_id) IN ('tbl_SystemEvents','tbl_Journeys','tbl_JourneyDrops','tbl_BusinessRules','tbl_Drivers','tbl_Vehicles','tbl_BusinessRuleLocalisation')
--,'tbl_Eventcodes')
--ORDER BY  OBJECT_NAME(st.object_id), st.name
ORDER BY STATS_DATE(st.object_id, stats_id) desc




SELECT  *, STATS_DATE(object_id, stats_id) AS Stats_Updated
FROM   sys.stats 
where name LIKE '%tbl_systemevents%'


SELECT name AS index_name,
OBJECT_NAME(object_id) AS [Object_Name],
STATS_DATE(OBJECT_ID, index_id) AS StatsUpdated
FROM sys.indexes
--WHERE OBJECT_ID = OBJECT_ID('HumanResources.Department')
ORDER BY OBJECT_NAME(object_id), name


SELECT  COUNT(*)
FROM tbl_Incident   

--UPDATE STATISTICS tbl_Incident RESAMPLE


-- SQL Server 2000

DBCC show_statistics ('OrderGroupGrouping', 'PK_OrderGroupGrouping') WITH STAT_HEADER
DBCC show_statistics ('OrderGroupGrouping', 'IX_OrderGroupGrouping_Reference') WITH STAT_HEADER
DBCC show_statistics ('OrderGroupGrouping', 'IX_OrderGroupGroupingCreatedOn') WITH STAT_HEADER


DBCC show_statistics ('OrderGroup', 'IX_OrderGroup_OrderGroupGroupingID') WITH STAT_HEADER
DBCC show_statistics ('OrderGroup', 'IX_OrderGroup_Reference') WITH STAT_HEADER
DBCC show_statistics ('OrderGroup', 'IX_OrderGroup_TriggerTimeStamp') WITH STAT_HEADER
DBCC show_statistics ('OrderGroup', 'IX_OrderGroupTaxPlanID') WITH STAT_HEADER
DBCC show_statistics ('OrderGroup', 'PK_OrderGroup') WITH STAT_HEADER

DBCC show_statistics ('Orders', 'PK_OctoplusOrders') WITH STAT_HEADER