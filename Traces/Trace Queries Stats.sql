/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT [LoginName], COUNT(*) AS No_Count
--  FROM [SQL-02 - Queries]
--  WHERE LoginName IS NOT NULL
--  GROUP BY LoginName
USE Audit
  

SELECT CASE 
			WHEN LoginName = 'sw_orion' THEN 'NetPerfMon'
			WHEN LoginName = 'BROXTOWE\WSUS$' THEN 'SUSDB'
			WHEN LoginName = 'CompassSystemUser' THEN 'ProAchive'
			WHEN LoginName = 'BROXTOWE\michael.giles' THEN 'AdHoc'
			WHEN LoginName = 'BROXTOWE\besuser' THEN 'BESMgmt'
			WHEN LoginName = 'BROXTOWE\misdbpump' THEN 'Processed_Data'
			WHEN LoginName = 'NT AUTHORITY\SYSTEM' THEN 
			CASE 
				WHEN ApplicationName LIKE 'SQLAgent%' THEN 'SQLAgent'
				WHEN ApplicationName LIKE 'DatabaseMail%' THEN 'DatabaseMail'
				ELSE ApplicationName
			END
			ELSE LoginName
		END AS Database_Application,		
		SUM(CASE
				WHEN CPU > 500 THEN 1
				ELSE 0
			END) AS [CPU GE 500 Ms],
		SUM(CASE
				WHEN Duration > 500 THEN 1
				ELSE 0
			END) AS [Duration GE 500 Ms],
		SUM(CASE
				WHEN Reads > 10000 THEN 1
				ELSE 0
			END) AS [Reads GE 10000],
		SUM(CASE
				WHEN Writes > 500 THEN 1
				ELSE 0
			END) AS [Writes GE 500],
		COUNT(*) AS No_Count  
  FROM [SQL-02 - Queries]
  WHERE LoginName IS NOT NULL
--    AND CPU > 500
--    AND Duration > 500
--	AND	Reads > 10000
--	AND Writes > 5000
  GROUP BY CASE 
			WHEN LoginName = 'sw_orion' THEN 'NetPerfMon'
			WHEN LoginName = 'BROXTOWE\WSUS$' THEN 'SUSDB'
			WHEN LoginName = 'CompassSystemUser' THEN 'ProAchive'
			WHEN LoginName = 'BROXTOWE\michael.giles' THEN 'AdHoc'
			WHEN LoginName = 'BROXTOWE\besuser' THEN 'BESMgmt'
			WHEN LoginName = 'BROXTOWE\misdbpump' THEN 'Processed_Data'
			WHEN LoginName = 'NT AUTHORITY\SYSTEM' THEN 
			CASE 
				WHEN ApplicationName LIKE 'SQLAgent%' THEN 'SQLAgent'
				WHEN ApplicationName LIKE 'DatabaseMail%' THEN 'DatabaseMail'
				ELSE ApplicationName
			END
			ELSE LoginName
		END
ORDER BY 1

SELECT CONVERT(VARCHAR(20),MIN(StartTime),103) + ' ' + CONVERT(VARCHAR(20),MIN(StartTime),108) AS Start_Time, 
CONVERT(VARCHAR(20),MAX(EndTime),103) + ' ' + CONVERT(VARCHAR(20),MAX(EndTime),108) AS End_Time FROM   [SQL-02 - Queries]


SELECT  TOP 50 *
FROM [SQL-02 - Queries]
ORDER BY CPU DESC

SELECT  TOP 50 *
FROM [SQL-02 - Queries]
ORDER BY Reads DESC

SELECT  TOP 50 *
FROM [SQL-02 - Queries]
ORDER BY Writes DESC

SELECT  TOP 50 *
FROM [SQL-02 - Queries]
ORDER BY Duration DESC


# CPU > 500
# Duration > 500 (half a second)
# Reads > 10,000
# Writes > 5000