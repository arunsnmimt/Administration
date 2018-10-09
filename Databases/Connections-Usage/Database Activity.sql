SELECT DISTINCT DB_NAME(database_id) As [Database] ,MAX(last_user_update) As Last_Update, MAX(last_user_seek) AS Last_User_Seek , MAX(last_user_scan) AS Last_User_Scan
--SELECT OBJECT_NAME(OBJECT_ID) AS TableName, last_user_update,*
--SELECT MAX(last_user_update)
FROM master.sys.dm_db_index_usage_stats
/*
WHERE database_id IN (DB_ID('BESMgmt'),
DB_ID('BMSStore'),
DB_ID('Castle-Citrix-DB'),
DB_ID('CastleCitrix'),
DB_ID('CastleCitrixFarm'),
DB_ID('CitrixXenApp5ServerFarm'),
DB_ID('ConfigMgrDashboardSessionDB'),
DB_ID('exams-citrix'),
DB_ID('mdsis'),
DB_ID('ProjectServer'),
DB_ID('ProjectServer_Archive2k7'),
DB_ID('ProjectServer_Config'),
DB_ID('ProjectServer_Draft2k7'),
DB_ID('ProjectServer_Published2k7'),
DB_ID('ProjectServer_Reporting2k7'),
DB_ID('SharedServices1_DB'),
DB_ID('SharedServices5_DB'),
DB_ID('SharePoint_Config'),
DB_ID('SurfControlWeb'),
DB_ID('SUSDB'),
DB_ID('WSS_Content'),
DB_ID('WSS_Content_16499cad9f254be3ab0259ee99d4c6a1'),
DB_ID('WSS_Content_4e4b3c82820342a9a21ecaeb156519f2'),
DB_ID('WSS_Content_cc6a84a5a3e942889bfe2ab1008eae27'),
DB_ID('WSS_Content_f29170c49bd047c2832b7799637a17b5'),
DB_ID('WSS_Search_PROJECT-2K7'),
DB_ID('WSS_Search_PROJECTSERVER'))
*/
GROUP BY DB_NAME(database_id)
--AND OBJECT_ID=OBJECT_ID('ALS_Data')
--ORDER BY TableName

CREATE TABLE Activity_Log
(
spid  INTEGER,
[status] VARCHAR(100),
[login] VARCHAR(100),
hostname VARCHAR(100),
BlkBy VARCHAR(100),
dbname VARCHAR(100),
command VARCHAR(100),
CPUTime INT,
DiskIO INT,
LastBatch VARCHAR(100),
ProgramName VARCHAR(100),
spid2  INT,
request_id INT,
datelogged DATETIME 
)

		
INSERT INTO dbo.Activity_Log (Spid, [Status], Login, [Host_Name], Blk_By, [DB_Name], Command, CPU_Time, DiskIO, Last_Batch, Program_Name, Spid2, Request_ID )
EXEC sp_who2


USE Audit

SELECT Database_Name, MAX(Last_Activity) AS Last_Activity,
	  MAX(CONVERT(VARCHAR(10), IUS.last_user_update, 120)) As Last_Update, 
	  MAX(CONVERT(VARCHAR(10), IUS.last_user_seek, 120))  AS Last_User_Seek , 
	  MAX(CONVERT(VARCHAR(10), IUS.last_user_scan, 120))  AS Last_User_Scan       

 FROM
(
SELECT Database_Name,
       MAX(CONVERT(VARCHAR(10), Date_Logged, 120)) AS Last_Activity
  FROM Activity_Log 
  WHERE Database_Name IS NOT NULL
  GROUP BY Database_Name
UNION ALL
SELECT Database_Name,
       MAX(CONVERT(VARCHAR(10), Date_Logged, 120)) AS Last_Activity
  FROM Activity_Log_Database
  GROUP BY Database_Name
 
)  AS Table_Name (Database_Name, Last_Activity)  
INNER JOIN master.sys.databases DB
ON Database_Name  = DB.name
LEFT OUTER JOIN master.sys.dm_db_index_usage_stats AS IUS
ON DB_NAME(IUS.database_id) = Database_Name
Where DB.state = 0 -- Online
AND DB.name NOT IN ('distribution','master','model','msdb','tempdb') -- Ignore system db's
GROUP BY Database_Name
  ORDER BY Database_Name


select * from master.sys.databases






SELECT DISTINCT DB_NAME(database_id) As [Database] ,MAX(CONVERT(VARCHAR(10), last_user_update, 120)) As Last_Update, MAX(CONVERT(VARCHAR(10), last_user_seek, 120))  AS Last_User_Seek , MAX(CONVERT(VARCHAR(10), last_user_scan, 120))  AS Last_User_Scan
FROM master.sys.dm_db_index_usage_stats
GROUP BY DB_NAME(database_id)  