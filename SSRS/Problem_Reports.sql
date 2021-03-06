/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT *
--  FROM [ReportServer].[dbo].[ExecutionLogStorage]
  
  
INSERT INTO Audit.dbo.Reports_Log(LogEntryID, ReportID, ExecutionId, RequestType, TimeTakenSecs, TimeTakenMins, Name, UserName, Format, [PARAMETERS], TimeStart, TimeEnd, TimeDataRetrieval, TimeProcessing, TimeRendering, Source, ByteCount, [ROWCOUNT], [Status])
 SELECT EL.LogEntryID, 
		EL.ReportID, 
		EL.ExecutionId, 
		EL.RequestType, 
		DATEDIFF(s,TimeStart,TimeEnd) AS 'TimeTakenSecs', 
		CONVERT(DECIMAL(9,2),DATEDIFF(ms,TimeStart,TimeEnd))/1000/60 AS 'TimeTakenMins', 
		CAT.Name,  
		EL.UserName, 
		EL.Format, 
		EL.[Parameters],
		EL.TimeStart, 
		EL.TimeEnd, 
		EL.TimeDataRetrieval, 
		EL.TimeProcessing,
		EL.TimeRendering,
		EL.[Source],
		EL.ByteCount,
		EL.[RowCount],
		EL.[Status]
--		INTO Audit.dbo.Reports_Log
FROM ReportServer.dbo.ExecutionLogStorage EL INNER JOIN CATALOG CAT 
ON EL.ReportID = CAT.ItemID
WHERE EL.ReportAction = 1
AND CAT.Name <> ''
AND EL.LogEntryID > (SELECT MAX(LogEntryID) FROM Audit.dbo.Reports_Log)
AND (EL.[Status] NOT IN ('rsSuccess', 'rsProcessingAborted')
OR (EL.[Status] = 'rsSuccess'  AND DATEDIFF(s,TimeStart,TimeEnd) > 300)) 
 

 
SELECT Name, COUNT(*) AS Occurances
FROM audit.dbo.Reports_Log
WHERE Status <> 'rsSuccess'
AND EmailSent IS NULL
GROUP BY Name
ORDER BY Name


SELECT Name, MAX(TimeTakenMins) AS 'Max Time Taken (Mins)', COUNT(*) AS Occurances
FROM audit.dbo.Reports_Log
WHERE Status = 'rsSuccess'
AND EmailSent IS NULL
GROUP BY Name
ORDER BY Name


--SELECT DISTINCT Status FROM ExecutionLogStorage


