DECLARE @traceid INT
SET @traceid = 0

SELECT  *
FROM    sys.fn_trace_getinfo(@traceid)

IF @traceid = 0
BEGIN
	SELECT  *
	FROM    sys.traces
END
ELSE
BEGIN
	SELECT  *
	FROM    sys.traces
	WHERE id = @traceid
END

SELECT  *
FROM   fn_trace_getfilterinfo (@traceid)

SELECT * FROM ::fn_trace_getinfo(0); -- SQL 2000 (Returns all traces running)

SELECT  evi.eventid, te.name AS event_name,  evi.columnid, tc.name AS column_name --, evi.*
FROM   fn_trace_geteventinfo (@traceid) evi INNER JOIN  sys.trace_events te
ON evi.eventid = te.trace_event_Id
INNER JOIN sys.trace_columns tc
ON evi.columnid = tc.trace_column_Id


SELECT TextData, LineNumber, HostName, ClientProcessID,
--ApplicationName, LoginName,
SPID, Duration,StartTime, EndTime, READS, Writes, CPU,EventClass,ObjectName, DatabaseName,RowCounts,EventSequence
 FROM fn_trace_gettable ( 'C:\temp\3663_WS2_Trace5.trc' , 1 )
--WHERE starttime BETWEEN '2012-09-27 17:32:00.000' AND '2012-09-27 17:37:00.000'
WHERE Duration > 30000

/*
	Returns the content of one or more trace files in tabular form. 
*/

USE Admin_DBA
SELECT * 
INTO trc_SQLVS24_20150113_0900
FROM fn_trace_gettable ( 'C:\temp\trc_SQLVS09_MARITIME_25-04-2014_102423.trc' , 1 )

USE Admin_DBA
SELECT * 
INTO trc_SQLVS10_TMC_3663_20140909_1108
FROM trc_SQLVS10_20140909_1108
WHERE DatabaseName = 'TMC_3663'



SELECT  *
FROM   sys.trace_categories

SELECT  *
FROM    sys.trace_columns 

SELECT  *
FROM    sys.trace_events 

SELECT  *
FROM    sys.trace_event_bindings

SELECT  *
FROM    sys.trace_subclass_values

-- Stop and close trace

EXEC sp_trace_setstatus 2, 0
EXEC sp_trace_setstatus 2, 2


--USE Admin_DBA
--SELECT DatabaseName, SUM(CPU) AS CPU_Total
-- FROM dbo.trc_JCB_Trace_20131212_121839
--WHERE DatabaseName IS NOT NULL
--GROUP BY DatabaseName
--ORDER BY SUM(CPU) DESC

--SELECT DatabaseName, SUM([CPU]) AS CPU_Total,
--	   SUM(Duration) AS Duration_Total,
--	   SUM(Reads) AS Reads_Total,
--	   SUM(Writes) AS Writes_Total
--  FROM [Admin_DBA].[dbo].trc_JCB_Trace_20131212_121839
--  WHERE DatabaseName IS NOT NULL
--GROUP BY  DatabaseName 
--ORDER BY 2 desc

--SELECT  *
--FROM trc_JCB_Trace_20131212_121839;

SELECT DISTINCT EventClass
FROM  [Admin_DBA].dbo.trc_SQLVS24_20150113_0900

/*
SELECT  trace_event_id, name
FROM    sys.trace_events WHERE trace_event_id IN (10, 12, 13) --41, 45, 65528, 65534)

Johns Trace - EventClass
========================
10	RPC:Completed
12	SQL:BatchCompleted
41	SQL:StmtCompleted
45	SP:StmtCompleted
65528
65534

Mine Trace - EventClass
=======================
10	RPC:Completed
12	SQL:BatchCompleted
13	SQL:BatchStarting
65528
65534

*/
SELECT TOP 1000 * 
--INTO [Admin_DBA].dbo.trc_Tesco_Trace_20140425_115018_AVL
FROM     [Admin_DBA].dbo.trc_SQLVS24_20150113_0900
--WHERE ObjectName = 'pr_UpdateEstimatedPunctualityForUnvisitedJourneyDrops'
WHERE  ApplicationName = 'TMC Web Portal'
AND TextData IS NOT NULL
AND TextData LIKE '%SP_JOURNEYCALCULATEETAETD%'
AND Duration IS NOT NULL
--AND Duration > 1000000
AND SPID = 665
ORDER BY  Duration DESC
WHERE [TextData] LIKE '%cu_JourneyBREvent%'

WHERE ApplicationName = 'Amber Web Application'


SELECT TextData, StartTime, EndTime, DatabaseName, ApplicationName, EventClass, ObjectName, ClientProcessID, SPID, Duration, --StartTime, EndTime, 
Reads, Writes, CPU, TransactionID
FROM     [Admin_DBA].dbo.trc_SQLVS24_20150113_0900
WHERE Reads > 500000
AND TextData NOT LIKE 'exec sp_%'
--AND ApplicationName = 'TMC AVL Service'
--AND ObjectName = 'sp_SystemEventsInsert'
ORDER BY Duration DESC
--WHERE SPID = 232
--WHERE [TextData] LIKE '%TBL_INTERFACELOG%' --'%SP_JOURNEYSTOMATCHFORDAY%'
--AND DatabaseName = 'TMC_CARLSBERG'
--WHERE Reads > 10000
--WHERE EventClass IN (27, 148, 189)
--WHERE ApplicationName = 'TMC Web Portal'
--AND Duration > 3000000
--AND [TextData] LIKE  'EXEC usp_BusinessEvents_GetTopThreeEvents%'
WHERE (ObjectName = 'OFD_IVC_ProcessTrackedEvent') --   OR [TextData] LIKE  'EXEC usp_BusinessEvents_GetTopThreeEvents%')         --'usp_map_GetSafetyEventsForVehicles'
ORDER BY StartTime
--WHERE [TextData] LIKE '%usp_map_GetSafetyEventsForVehicles%'
--WHERE DatabaseName = 'master'

WHERE ApplicationName = 'TMC AVL Service'

SELECT 
[DatabaseName]
, [ApplicationName]
, [ObjectName]
,LEFT(CAST([TextData] AS VARCHAR(2000)), 40) AS command
, COUNT(1) AS Total_Calls
, MIN(Duration) AS MIN_Duration
, MAX(Duration) AS MAX_Duration
, AVG(Duration) AS AVG_Duration
, SUM(Duration) AS SUM_Duration
, MIN(READS) AS MIN_Reads
, MAX(READS) AS MAX_Reads
, AVG(READS) AS AVG_Reads
, SUM(READS) AS SUM_Reads
, MIN(Writes) AS MIN_Writes
, MAX(Writes) AS MAX_Writes
, AVG(Writes) AS AVG_Writes
, SUM(Writes) AS SUM_Writes
, MIN(CPU) AS MIN_CPU
, MAX(CPU) AS MAX_CPU
, AVG(CPU) AS AVG_CPU
, SUM(CPU) AS SUM_CPU
INTO #tmp_TextData
 FROM [Admin_DBA].dbo.trc_SQLVS24_20150113_0900
-- WHERE DatabaseName = 'JCB_Live_Link_SATELLITE1'
--WHERE ApplicationName = 'TMC AVL Service'
--WHERE [TextData] LIKE '%cu_JourneyBREvent%'
--WHERE [TextData] LIKE 'UPDATE TBL_VEHICLE SET ENGINETYPEID%'
GROUP BY [DatabaseName], [ApplicationName], [ObjectName], LEFT(CAST([TextData] AS VARCHAR(2000)), 40)
ORDER BY AVG(Duration) DESC
--ORDER BY AVG(CPU) DESC;

SELECT * FROM #tmp_TextData
ORDER BY 7 DESC;



DROP TABLE #tmp_TextData

SELECT 
[DatabaseName]
, [ApplicationName]
, [ObjectName]
, COUNT(1) AS Total_Calls
, MIN(Duration) AS MIN_Duration
, MAX(Duration) AS MAX_Duration
, AVG(Duration) AS AVG_Duration
, SUM(Duration) AS SUM_Duration
, MIN(READS) AS MIN_Reads
, MAX(READS) AS MAX_Reads
, AVG(READS) AS AVG_Reads
, SUM(READS) AS SUM_Reads
, MIN(Writes) AS MIN_Writes
, MAX(Writes) AS MAX_Writes
, AVG(Writes) AS AVG_Writes
, SUM(Writes) AS SUM_Writes
, MIN(CPU) AS MIN_CPU
, MAX(CPU) AS MAX_CPU
, AVG(CPU) AS AVG_CPU
, SUM(CPU) AS SUM_CPU
INTO #tmp_ObjectName
 FROM [Admin_DBA].dbo.trc_SQLVS24_20150113_0900
-- WHERE DatabaseName = 'JCB_Live_Link_SATELLITE1'
--WHERE ApplicationName = 'TMC AVL Service'
WHERE [ObjectName] IS NOT NULL
--WHERE [TextData] LIKE 'UPDATE TBL_VEHICLE SET ENGINETYPEID%'
GROUP BY [DatabaseName], [ApplicationName], [ObjectName]

SELECT * FROM #tmp_ObjectName
ORDER BY AVG_Duration DESC;


DROP TABLE #tmp_ObjectName


SELECT  *
FROM #tmp_ObjectName   


SELECT [DatabaseName]
, [ApplicationName]
,total_calls
, ISNULL([ObjectName], LEFT(CAST([Command] AS VARCHAR(2000)), 40)) AS ObjectName
, CAST(MAX_Duration/1000000.0 AS DECIMAL (6,2)) AS Max_Duration_Seconds
, MAX_Reads
, MAX_Writes
, MAX_CPU
 FROM #tmp_TextData
 WHERE MAX_Duration/1000000.0 > 4 OR MAX_Reads > 100000
ORDER BY 3 DESC


SELECT * FROM [Admin_DBA].dbo.trc_SQLVS24_20150113_0900
WHERE Duration > 300000




DROP TABLE #tmp_TextData

SELECT MIN(StartTime), MAX(EndTime)
FROM    Admin_DBA.dbo.trc_SQLVS24_20150113_0900


SELECT TOP 2000 *
FROM    Admin_DBA.dbo.trc_SQLVS24_20150113_0900
WHERE ApplicationName = 'TMC Interfacer'
AND Duration > 1000
AND LEFT(CAST([TextData] AS VARCHAR(2000)), 70) = 'exec sp_executesql N''/*-----------------------------------------------'

WITH Trace_CPU_Stats_Query
AS
(SELECT DatabaseName, LEFT(CAST([TextData] AS VARCHAR(2000)), 70) AS Command, SUM(CPU) AS CPU_Total
 FROM dbo.trc_SQLVS24_20150113_0900
WHERE DatabaseName IS NOT NULL
AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
GROUP BY DatabaseName, LEFT(CAST([TextData] AS VARCHAR(2000)), 70))
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Total] DESC) AS [row_num], DatabaseName, Command, CPU_Total, 
CAST(CPU_Total * 1.0 / SUM(CPU_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
FROM Trace_CPU_Stats_Query;

/*
=========================================================================================================================
	Database/Application stats
=========================================================================================================================
*/

SELECT DatabaseName, ApplicationName, SUM(CPU) AS CPU_Total, SUM(READS) AS Reads_Total, SUM(Writes) AS Writes_Total, SUM(Duration) AS Duration_Total
INTO #DbAppTraceSummary
 FROM dbo.trc_SQLVS24_20150113_0900
WHERE DatabaseName IS NOT NULL
AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
GROUP BY DatabaseName,ApplicationName;

/*
DELETE FROM    #DbAppTraceSummary
WHERE DatabaseName = 'master'
*/

WITH Trace_DB_App_CPU
AS
--(SELECT DatabaseName, ApplicationName, SUM(CPU) AS CPU_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName,ApplicationName)
(SELECT DatabaseName, ApplicationName, CPU_Total FROM #DbAppTraceSummary)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Total] DESC) AS [row_num], DatabaseName, ApplicationName, CPU_Total, 
CAST(CPU_Total * 1.0 / SUM(CPU_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
FROM Trace_DB_App_CPU;

WITH Trace_App_CPU
AS
--(SELECT DatabaseName, ApplicationName, SUM(CPU) AS CPU_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName,ApplicationName)
(SELECT ApplicationName, SUM(CPU_Total) AS CPU_Total FROM #DbAppTraceSummary GROUP BY ApplicationName)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Total] DESC) AS [row_num], ApplicationName, CPU_Total, 
CAST(CPU_Total * 1.0 / SUM(CPU_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
FROM Trace_App_CPU;


WITH Trace_DB_App_Reads
AS
--(SELECT DatabaseName, ApplicationName, SUM(Reads) AS Reads_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName,ApplicationName)
(SELECT DatabaseName, ApplicationName, Reads_Total FROM #DbAppTraceSummary)
SELECT ROW_NUMBER() OVER(ORDER BY [Reads_Total] DESC) AS [row_num], DatabaseName, ApplicationName, Reads_Total, 
CAST(Reads_Total * 1.0 / SUM(Reads_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [ReadsPercent]
FROM Trace_DB_App_Reads;


WITH Trace_DB_App_Writes
AS
--(SELECT DatabaseName, ApplicationName, SUM(Writes) AS Writes_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName,ApplicationName)
(SELECT DatabaseName, ApplicationName, Writes_Total FROM #DbAppTraceSummary)
SELECT ROW_NUMBER() OVER(ORDER BY [Writes_Total] DESC) AS [row_num], DatabaseName, ApplicationName, Writes_Total, 
CAST(Writes_Total * 1.0 / SUM(Writes_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [WritesPercent]
FROM Trace_DB_App_Writes;


WITH Trace_DB_App_Duration
AS
--(SELECT DatabaseName, ApplicationName, SUM(Writes) AS Writes_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName,ApplicationName)
(SELECT DatabaseName, ApplicationName, Duration_Total FROM #DbAppTraceSummary)
SELECT ROW_NUMBER() OVER(ORDER BY Duration_Total DESC) AS [row_num], DatabaseName, ApplicationName, Duration_Total, 
CAST(Duration_Total * 1.0 / SUM(Duration_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [DurationPercent]
FROM Trace_DB_App_Duration;


WITH Trace_DB_CPU
AS
--(SELECT DatabaseName, SUM(CPU) AS CPU_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName)
(SELECT DatabaseName, SUM(CPU_Total) AS CPU_Total FROM #DbAppTraceSummary GROUP BY DatabaseName)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Total] DESC) AS [row_num], DatabaseName, CPU_Total, 
CAST(CPU_Total * 1.0 / SUM(CPU_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
FROM Trace_DB_CPU;

WITH Trace_DB_Duration
AS
--(SELECT DatabaseName, SUM(Duration) AS Duration_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName)
(SELECT DatabaseName, SUM(Duration_Total) AS Duration_Total FROM #DbAppTraceSummary GROUP BY DatabaseName)
SELECT ROW_NUMBER() OVER(ORDER BY [Duration_Total] DESC) AS [row_num], DatabaseName, Duration_Total, 
CAST(Duration_Total * 1.0 / SUM(Duration_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [DurationPercent]
FROM Trace_DB_Duration;

WITH Trace_DB_Reads
AS
--(SELECT DatabaseName, SUM(READS) AS Reads_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName)
(SELECT DatabaseName, SUM(Reads_Total) AS Reads_Total FROM #DbAppTraceSummary GROUP BY DatabaseName)
SELECT ROW_NUMBER() OVER(ORDER BY [Reads_Total] DESC) AS [row_num], DatabaseName, Reads_Total, 
CAST(Reads_Total * 1.0 / SUM(Reads_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [ReadsPercent]
FROM Trace_DB_Reads;

WITH Trace_DB_Writes
AS
--(SELECT DatabaseName, SUM(READS) AS Writes_Total
-- FROM dbo.trc_SQLVS24_20150113_0900
--WHERE DatabaseName IS NOT NULL
--AND LEFT(CAST([TextData] AS VARCHAR(2000)), 18) <> 'exec sp_executesql'
--GROUP BY DatabaseName)
(SELECT DatabaseName, SUM(Writes_Total) AS Writes_Total FROM #DbAppTraceSummary GROUP BY DatabaseName)
SELECT ROW_NUMBER() OVER(ORDER BY [Writes_Total] DESC) AS [row_num], DatabaseName, Writes_Total, 
CAST(Writes_Total * 1.0 / SUM(Writes_Total) OVER() * 100.0 AS DECIMAL(5, 2)) AS [WritesPercent]
FROM Trace_DB_Writes;



SELECT  *
FROM  trc_SQLVS24_20150113_0900  
WHERE CAST([TextData] AS VARCHAR(2000)) LIKE 'exec sp_executesql N''EXEC usp_ContextualSpeeding_GetRowsToProcess%'


SELECT  *
FROM  trc_SQLVS24_20150113_0900  
WHERE CAST([TextData] AS VARCHAR(2000)) LIKE '%usp_ContextualSpeeding_GetRowsToProcess%'

SELECT  MIN(StartTime), MAX(EndTime), DATEDIFF(SECOND, MIN(StartTime),  MAX(EndTime)) AS Trace_Duration_Secs
FROM  trc_SQLVS24_20150113_0900  

