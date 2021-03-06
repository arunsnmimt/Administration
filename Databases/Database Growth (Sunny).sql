/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @ServerName VARCHAR(128) = 'SQLCluster05'
DECLARE @DatebaseName VARCHAR(128) = NULL --'TMC_DHL_JLR' -- NULL or '' All Databases
DECLARE @Diff1 SMALLINT = 0
DECLARE @Diff2 SMALLINT = 1 

DECLARE @DBname VARCHAR(128)

SET @DBname = @ServerName+'%'

IF @DatebaseName IS NOT NULL AND
   @DatebaseName <> ''
BEGIN   
	SET @DBname = @DBname +@DatebaseName+'%'
END

SELECT  A.[dbname], B.DataUsed, B.DataUsed - A.DataUsed AS DB_Growth, B.DataMB - A.DataMB AS MDF_Growth
      --,[dbsizeMB]
      --,[DataMB]
      --,[DataUsed]
      --,[DataUsedPct]
      --,[DataFree]
      --,[DataFreePct]
      --,[LogMB]
      --,[LogUsed]
      --,[LogUsedPct]
      --,[LogFree]
      --,[LogFreePct]
      --,[date]
      ,A.[FileName]
  FROM [Admin_DBA].[dbo].[DBGrowthUsage] A INNER JOIN  [Admin_DBA].[dbo].[DBGrowthUsage] B
  ON A.dbname = b.dbname
  where A.dbname  LIKE @DBname
  --AND A.[date]  BETWEEN GETDATE() -@Diff2 - 1 AND GETDATE() - @Diff2  
  --AND B.[date] BETWEEN GETDATE() - @Diff1 - 1 AND GETDATE() - @Diff1
    and A.date between GETDATE()-5 AND GETDATE() -4
    and B.date between GETDATE()-1 AND GETDATE() 
--  and  A.dbname  <> 'DHLSQLVS01- tempdb'
  and  A.dbname NOT LIKE '%tempdb'
 -- and A.[FileName] LIKE 'F%'
  ORDER BY DB_Growth DESC

-- Logs


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT A.dbname, A.LogMB, B.LogMB, A.LogMB - B.LogMB AS Growth
  FROM [Admin_DBA].[dbo].[DBGrowthUsage] A INNER JOIN [Admin_DBA].[dbo].[DBGrowthUsage] B
  ON A.dbname = B.dbname
    where A.dbname LIKE @DBname
  AND A.[date] BETWEEN GETDATE() - 1 AND GETDATE()
  AND B.[date] BETWEEN GETDATE() - 5 AND GETDATE() - 4
  ORDER BY A.LogMB - B.LogMB desc
