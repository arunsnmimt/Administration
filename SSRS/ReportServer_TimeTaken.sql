USE ReportServer

DECLARE @TodaysDate AS DATETIME
DECLARE @Days AS SMALLINT

SET @TodaysDate = CAST(CONVERT(VARCHAR, GETDATE(),101) AS Datetime)
SET @Days = 7

SELECT CAT.Name,  DATEDIFF(s,TimeStart,TimeEnd) AS 'TimeTaken (Secs)', CONVERT(DECIMAL(9,2),DATEDIFF(ms,TimeStart,TimeEnd))/1000/60 AS 'TimeTaken (Mins)', EL.UserName, EL.Format, EL.PARAMETERS, EL.TimeStart, EL.TimeEnd, EL.TimeDataRetrieval, EL.TimeRendering, EL.Status
FROM ExecutionLog EL INNER JOIN CATALOG CAT 
ON EL.ReportID = CAT.ItemID
WHERE TimeStart > DATEADD(DAY,-@Days,@TodaysDate)    --    '2010-01-01 00:00:00.000'
AND CAT.[Path] LIKE '/TMC_reports/MARITIME%'   
 AND [Status] = 'rsProcessingAborted'
 ORDER BY 'TimeTaken (Mins)' DESC
 
/* 
SELECT  *
FROM    Catalog
where Name like '%ILR%'
and Path NOT LIKE '/Data Sources%'
and Path NOT LIKE '/Models%'
*/

--select *  FROM ExecutionLog

--SELECT *
--  FROM [ReportServer].[dbo].[ExecutionLogStorage]

DECLARE @TodaysDate AS DATETIME
DECLARE @Days AS SMALLINT

SET @TodaysDate = CAST(CONVERT(VARCHAR, GETDATE(),101) AS Datetime)
SET @Days = 1

SELECT CAT.Name,  DATEDIFF(s,TimeStart,TimeEnd) AS 'TimeTaken (Secs)', CONVERT(DECIMAL(9,2),DATEDIFF(ms,TimeStart,TimeEnd))/1000/60 AS 'TimeTaken (Mins)', EL.UserName, EL.Format, EL.PARAMETERS, EL.TimeStart, EL.TimeEnd, EL.TimeDataRetrieval, EL.TimeRendering, EL.Status
FROM ExecutionLog EL INNER JOIN CATALOG CAT 
ON EL.ReportID = CAT.ItemID
WHERE TimeStart > DATEADD(DAY,-@Days,@TodaysDate)
and Username LIKE  '%rachel.simpson'
 ORDER BY 'TimeTaken (Mins)' DESC



