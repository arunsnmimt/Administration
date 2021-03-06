USE [ReportServerDHL]

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT --TOP 1000  
		EL.*,
		CT.[Path]
  FROM [dbo].[ExecutionLog] EL INNER JOIN [dbo].[Catalog] CT
  ON EL.ReportID = CT.ItemID
--  WHERE Status <> 'rsSuccess'
--  WHERE EL.ReportID = 'AD2BD96C-AF7E-4A4E-913C-43014F0B3131'
  WHERE TimeStart > '2014-09-15 07:00'
  AND Path LIKE '%Poly%'
--  AND Path LIKE '/TMC_reports/CELTIC%'
  ORDER BY  TimeStart

UNION ALL

SELECT --TOP 1000  
		EL.*,
		CT.[Path]
  FROM [dbo].[ExecutionLog] EL INNER JOIN [dbo].[Catalog] CT
  ON EL.ReportID = CT.ItemID
  WHERE Status <> 'rsSuccess'
  AND TimeStart > '2013-05-17'
--  ORDER BY  TimeStart
  
 UNION ALL
 
SELECT --TOP 1000  
		EL.*,
		CT.[Path]
  FROM [dbo].[ExecutionLog] EL INNER JOIN [dbo].[Catalog] CT
  ON EL.ReportID = CT.ItemID
  WHERE Status <> 'rsSuccess'
  AND TimeStart > '2013-05-17'
  ORDER BY  TimeStart 

  --WHERE RequestType = 1
  --AND TimeStart >= '2013-01-04 05:55:00.000'
  --AND ReportID = 'FBDBBB08-6A7D-415B-B2A5-01BAB3AE1479'

-- Reports Extract Interserve

SELECT --TOP 1000  
		EL.*,
		CT.[Path]
  FROM [dbo].[ExecutionLog] EL INNER JOIN [dbo].[Catalog] CT
  ON EL.ReportID = CT.ItemID
  WHERE CT.ItemID = 'EDD0C9D4-6DED-4CBC-B32E-7D6880C8FB55'
  --WHERE Status <> 'rsSuccess'
  --AND TimeStart > '2013-05-17'
--  ORDER BY  TimeStart  
 

SELECT  *
FROM    [dbo].[Catalog]
--WHERE ItemID = '41E90A5D-0876-4661-ADAB-B2807A421463'
where Name like '%interserve%'

SELECT  *
FROM      [dbo].[ExecutionLog] 
WHERE ReportID = '41E90A5D-0876-4661-ADAB-B2807A421463'

41E90A5D-0876-4661-ADAB-B2807A421463