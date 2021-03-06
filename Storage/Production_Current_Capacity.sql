/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP 1000 DU.[Server_Name], SM.Usage
--      ,DU.[Drive]
--      ,DA.[Description]
--      ,[Free_GB]
--      ,[Free_Percent]
--      ,[Total_GB]
--      ,[Date_Time]
USE Admin_DBA

      
SELECT  SM.Server_Name + CASE  WHEN SM.Usage IS NULL THEN '' ELSE ' (' + SM.Usage + ')' END AS Server_Name,     
--SM.Server_Name, SM.Usage, 
CAST(SUM(Total_Size_GB) AS DECIMAL (10,1)) AS Total_Data_Capacity,  CAST(SUM(Free_GB) AS DECIMAL(10,1)) AS Total_Data_Free, COUNT(*) AS No_Data_Drives, CAST(SUM(Free_GB) / COUNT(*) AS DECIMAL(10,1)) AS Avg_Free_PerDrive
  FROM [Admin_DBA].[dbo].[tbl_DiskUsage] DU INNER JOIN dbo.Server_Monitoring SM
  ON DU.Server_Name = SM.Server_Name
  INNER JOIN dbo.tbl_DiskAlerts DA
  ON DU.Server_Name = DA.Server_Name
  AND DU.Drive = DA.Drive
  WHERE Date_Time > GETDATE() -1
  AND SM.Type = 'P'
  AND DA.[Description] LIKE '%Data%'
  GROUP BY SM.Server_Name, SM.Usage
  ORDER BY SUM(Free_GB) -- CAST(SUM(Free_GB) / COUNT(*) AS DECIMAL(10,1))  