/****** Script for SelectTopNRows command from SSMS  ******/

DECLARE @ServerName VARCHAR(128) = 'SQLVS19'
DECLARE @DatebaseName VARCHAR(128) = 'TMC_TRENT'
DECLARE @TableName1 VARCHAR(128) = 'tbl_TrackerEvents'
DECLARE @TableName2 VARCHAR(128) = 'tbl_SystemEvents'
DECLARE @TableName3 VARCHAR(128) = 'tbl_TrackedEvent'
DECLARE @Diff1 SMALLINT = 0
DECLARE @Diff2 SMALLINT = 2 -- DATEDIFF(day, '2014-08-07', CAST(GETDATE() AS DATE))    -- 1
DECLARE @TableHistory SMALLINT = 60

DECLARE @ServerName2 VARCHAR(128)
SET @ServerName2 = @ServerName + '%'
DECLARE @DatabaseIngore VARCHAR(128)

SET @DatabaseIngore = @ServerName + '- tempdb'

SELECT A.dbname, 
  A.dbsizeMB - B.dbsizeMB AS dbsizeMBDiff, A.DataUsed,
  A.DataUsed - B.DataUsed AS DataUsedMBDiff, CAST((A.DataUsed - B.DataUsed) /1024.0 AS DECIMAL(10,2)) AS DataUsedGBDiff, @Diff2 - @Diff1 AS DaysDiff
  FROM [Admin_DBA].[dbo].[DBGrowthUsage] A INNER JOIN [Admin_DBA].[dbo].[DBGrowthUsage] B
  ON A.dbname = B.dbname
  WHERE A.dbname LIKE @ServerName2
  AND A.dbname <> @DatabaseIngore
--  AND LEFT(A.Filename,1) = 'F'
  AND A.[date] BETWEEN GETDATE() - @Diff1 - 1 AND GETDATE() - @Diff1
  AND B.[date]  BETWEEN GETDATE() -@Diff2 - 1 AND GETDATE() - @Diff2
  ORDER BY DataUsedMBDiff DESC
  

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT A.Table_Name, A.Total_Data_Used_GB, A.Total_Data_Used_GB - B.Total_Data_Used_GB AS Total_Data_Used_GB_Diff, A.Total_Data_Used_MB - B.Total_Data_Used_MB AS Total_Data_Used_MB_Diff, @Diff2 - @Diff1 AS DaysDiff
  FROM [Admin_DBA].[dbo].[tbl_TableUsage] A LEFT JOIN [Admin_DBA].[dbo].[tbl_TableUsage] B
  ON A.Server_Name = A.Server_Name
  AND A.Database_Name = B.Database_Name
  AND A.Table_Name = B.Table_Name
  WHERE A.Server_Name = @ServerName
  AND A.Database_Name = @DatebaseName
  AND A.Date_Time BETWEEN GETDATE() - @Diff1 - 1 AND GETDATE() - @Diff1
  AND B.Date_Time  BETWEEN GETDATE() -@Diff2 - 1 AND GETDATE() - @Diff2
  ORDER BY 3 DESC
  
SELECT A.*
  FROM [Admin_DBA].[dbo].[tbl_TableUsage] A 
  WHERE A.Server_Name = @ServerName
  AND A.Database_Name = @DatebaseName  
  AND A.Table_Name = @TableName1
  AND A.Date_Time BETWEEN GETDATE()-@TableHistory AND GETDATE()  -0
    ORDER BY Date_Time
    
  SELECT A.*
  FROM [Admin_DBA].[dbo].[tbl_TableUsage] A 
  WHERE A.Server_Name = @ServerName
  AND A.Database_Name = @DatebaseName  
  AND A.Table_Name = @TableName2
  AND A.Date_Time BETWEEN GETDATE()-@TableHistory AND GETDATE()  -0
    ORDER BY Date_Time

  SELECT A.*
  FROM [Admin_DBA].[dbo].[tbl_TableUsage] A 
  WHERE A.Server_Name = @ServerName
  AND A.Database_Name = @DatebaseName  
  AND A.Table_Name = @TableName3
  AND A.Date_Time BETWEEN GETDATE()-@TableHistory AND GETDATE()  -0
  ORDER BY Date_Time
  
