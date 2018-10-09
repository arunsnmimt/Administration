USE [ReportServer3]
GO


/* Reports and their data sources */

  SELECT DISTINCT C.Name --, C.[Path], E.Name AS [Shared DataSource Name], D.Name AS [DataSource Name] 
       FROM [Catalog] C 
		INNER JOIN DataSource D 
			ON C.ItemID = D.ItemID
	INNER JOIN (SELECT ItemID, Name From Catalog) AS E 
	ON D.Link = E.ItemID		
	WHERE C.Type = 2 -- Reports
	ORDER BY c.Name

--	AND E.Name = 'ILRAnalyser'
--	ORDER BY c.[Path], e.Name


--  Shared Data Sources in use

  SELECT DISTINCT E.Name AS [Shared DataSource Name]
      FROM [Catalog] C 
		INNER JOIN DataSource D 
			ON C.ItemID = D.ItemID
	INNER JOIN (SELECT ItemID, Name From Catalog) AS E 
	ON D.Link = E.ItemID		
	WHERE C.Type = 2 -- Reports
	ORDER BY E.Name



  

--SELECT * FROM DataSource

--SELECT * FROM CATALOG
--WHERE TYPE = 5


--(Link, CATALOG)


;WITH [SUBJECT]([SubscriptionID], [SubjectLine]) AS 
(
 --CTE with Subject lines from e-mail Subscriptions from XML like: 
 --  <ParameterValues>
 --    <ParameterValue>
 --      <Name>TO</Name>
 --      <Value>email@address.com</Value>
 --    </ParameterValue>
 --    <ParameterValue>
 --      <Name>IncludeReport</Name>
 --      <Value>True</Value>
 --    </ParameterValue>
 --    <ParameterValue>
 --      <Name>RenderFormat</Name>
 --      <Value>PDF</Value>
 --    </ParameterValue>
 --    <ParameterValue>
 --      <Name>Subject</Name>
 --      <Value>THE SUBJECT LINE</Value>
 --    </ParameterValue>
 --    ..
 --  </ParameterValues>
 SELECT  I.[SubscriptionID], 
         --just get the subject line here 
         I1.rows.value('Value [1]', 'VARCHAR(500)') AS [SubjectLine] 
 FROM    (
          --if the Subscription is an e-mail, get the XML fragment which contains the subject line 
          SELECT  S.[SubscriptionID], 
                  --add a "root" element to create well-formed XML to the "ExtensionSettings"
                  --(in case it's NULL) 
                  CONVERT(XML, N'<Root>' + CONVERT(NVARCHAR(MAX), S.[ExtensionSettings]) + N'</Root>') AS [ExtensionSettings]
          FROM    dbo.[Subscriptions] S WITH (NOLOCK) 
          WHERE   --only get e-mail subscriptions 
                  S.[DeliveryExtension] = 'Report Server Email' 
         ) I CROSS APPLY 
             --pull out elements in the "ParameterValues/ParameterValue" hierarchy 
             I.ExtensionSettings.nodes('/Root/ParameterValues/ParameterValue') AS I1(ROWS) 
 WHERE   --only get the Subject field 
         I1.rows.value('Name [1]', 'VARCHAR(100)') = 'Subject' 
) 
--get subscription data for all users
SELECT  --unique ID for this Subscription 
        S.[SubscriptionID], 
        SC.ScheduleID,
        --is the subscription Inactive (<> 0)?
        S.[InactiveFlags], 
        --XML fragment which contains PATH (if file) or TO (if e-mail)
        --also has render settings like "render format"
        S.[ExtensionSettings], 
        --e-mail subject (if an e-mail subscription) 
        [SUBJECT].[SubjectLine], 
        --when the subscription was modified 
        S.[ModifiedDate], 
        --internally put-together description of subscription 
        S.[Description], 
        --user-friendly message for what happened the last time the subscription ran 
        --which may be "New Subscription" 
        S.[LastStatus], 
        --is this a "TimedSubscription" or one-off
        S.[EventType], 
        --XML fragment describing the timing and recurrence 
        S.[MatchData], 
        --the time the subscription was last run (may be NULL) 
        S.[LastRunTime], 
        --is this an e-mail ("Report Server Email") or file share ("Report Server FileShare")?
        S.[DeliveryExtension], 
        --start date and end date for schedule 
        SC.[StartDate], SC.[EndDate], 
        --other schedule information (we could get exactly the schedule here, but needs
        --to be re-assembled from multiple fields) 
        --???
        SC.[Flags], SC.[RecurrenceType], SC.[State], 
        --report path and name 
        C.[Path], C.[Name], 
        --owner name 
        [U1].[UserName] AS [Owner], 
        --modified by name 
        [U2].[UserName] AS [ModifiedBy], 
        --URL direct to the subscription 
        [URL] = 'http://SQL-02/Reports/Pages/SubscriptionProperties.aspx?ItemPath=' + C.[Path] + '&IsDataDriven=False&SubscriptionID=' + CAST(S.[SubscriptionID] AS VARCHAR(80)), 
        --URL to the "Subscriptions" tab on the report (which can be used to delete the subscription) 
        [URL2] = 'http://SQL-02/Reports/Pages/Report.aspx?ItemPath=' + C.[Path] + '&SelectedTabId=SubscriptionsTab' 
FROM    --actual subscriptions
        dbo.[Subscriptions] S WITH (NOLOCK) LEFT OUTER JOIN 
            --report details from Catalog 
            dbo.[Catalog] C WITH (NOLOCK) ON 
                S.[Report_OID] = C.[ItemID] LEFT OUTER JOIN 
            --Users (owner)
            dbo.[Users] [U1] WITH (NOLOCK) ON 
                S.[OwnerID] = [U1].[UserID] LEFT OUTER JOIN 
            --Users (modified by) 
            dbo.[Users] [U2] WITH (NOLOCK) ON 
                S.[ModifiedByID] = [U2].[UserID] LEFT OUTER JOIN 
            --Subscription Schedules 
            dbo.[ReportSchedule] RS WITH (NOLOCK) ON 
                S.[SubscriptionID] = RS.[SubscriptionID] LEFT OUTER JOIN 
            --Schedules 
            dbo.[Schedule] SC WITH (NOLOCK) ON 
                RS.[ScheduleID] = SC.[ScheduleID] LEFT OUTER JOIN 
            --Subjects CTE from e-mail subscriptions 
            [SUBJECT] ON 
                S.[SubscriptionID] = [SUBJECT].[SubscriptionID] 
  WHERE C.[Path] LIKE '/TMC_reports/MARITIME%'                
-- WHERE C.Name = 'Online Staff Timetables'
 
 /*
 
   Name = Online Staff Timetables
  ItemID = 9EF55ED5-E17A-4A9B-A133-229A10B5A81F
  ParentID = E8222738-17EA-46C7-94FB-A8B14D07AC92
  SubID = E11DE70F-1935-4F2A-9E28-8ECE59BFD2A4
  
  
  exec ReportServer.dbo.AddEvent @EventType='TimedSubscription', @EventData='dbd43bd9-3113-4bbd-b5b4-268a22060e98'
  
  */
  
  
  --Find the procedure names that are being used along with report, datasource names
;WITH XMLNAMESPACES (
DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition',
'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS rd
)
SELECT 
name,
x.value('CommandType[1]', 'VARCHAR(50)') AS CommandType,
x.value('CommandText[1]','VARCHAR(50)') AS CommandText,
x.value('DataSourceName[1]','VARCHAR(50)') AS DataSource

FROM (
SELECT name, 
CAST(CAST(CONTENT AS VARBINARY(MAX)) AS XML) AS reportXML 
FROM ReportServer.dbo.Catalog 
WHERE CONTENT IS NOT NULL
AND TYPE = 2
) a
CROSS APPLY reportXML.nodes('/Report/DataSets/DataSet/Query') r(x)
WHERE x.value('CommandType[1]', 'VARCHAR(50)') = 'StoredProcedure'
ORDER BY name

--Find the procedure names that are used in reports
;WITH XMLNAMESPACES (
DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition',
'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS rd
)
SELECT 
DISTINCT x.value('CommandText[1]','VARCHAR(50)') AS CommandText
FROM (
SELECT name, 
CAST(CAST(CONTENT AS VARBINARY(MAX)) AS XML) AS reportXML 
FROM ReportServer.dbo.Catalog 
WHERE CONTENT IS NOT NULL
AND TYPE = 2
) a
CROSS APPLY reportXML.nodes('/Report/DataSets/DataSet/Query') r(x)
WHERE x.value('CommandType[1]', 'VARCHAR(50)') = 'StoredProcedure'
 

--Get all text adhoc sql in the reports
;WITH XMLNAMESPACES (
DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition',
'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS rd
)
SELECT 
name,
x.value('CommandType[1]', 'VARCHAR(50)') AS CommandType,
x.value('CommandText[1]','VARCHAR(50)') AS CommandText,
x.value('DataSourceName[1]','VARCHAR(50)') AS DataSource

FROM (
SELECT name, 
CAST(CAST(CONTENT AS VARBINARY(MAX)) AS XML) AS reportXML 
FROM ReportServer.dbo.Catalog 
WHERE CONTENT IS NOT NULL
AND TYPE != 3
) a
CROSS APPLY reportXML.nodes('/Report/DataSets/DataSet/Query') r(x)
WHERE x.value('CommandType[1]', 'VARCHAR(50)') IS NULL --= 'CommandText'
ORDER BY name--Find the distinct reports
;WITH XMLNAMESPACES (
DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition',
'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS rd
)
SELECT 
DISTINCT name
FROM (
SELECT name, 
CAST(CAST(CONTENT AS VARBINARY(MAX)) AS XML) AS reportXML 
FROM ReportServer.dbo.Catalog 
WHERE CONTENT IS NOT NULL
AND TYPE = 2
) a
ORDER BY name


--Get the data sources
SELECT PATH, Name FROM ReportServer.dbo.Catalog
WHERE TYPE = 5

--Get the report names and their paths
SELECT PATH, Name FROM ReportServer.dbo.Catalog
WHERE TYPE = 2

--Get the supporting docs used in the reports
SELECT PATH, Name FROM ReportServer.dbo.Catalog
WHERE TYPE = 3

--Is there a cache policy to expire after n minutes?
SELECT PATH, Name, ExpirationFlags, CacheExpiration 
FROM ReportServer.dbo.Catalog c JOIN ReportServer.dbo.CachePolicy cp
ON c.ItemID = cp.reportID
WHERE ExpirationFlags = 1

--Is there a cache policy to expire on a report specific/shared schedule?
SELECT PATH, Name, ExpirationFlags, CacheExpiration 
FROM ReportServer.dbo.Catalog c JOIN ReportServer.dbo.CachePolicy cp
ON c.ItemID = cp.reportID
WHERE ExpirationFlags = 2

--Which users are using these reports
SELECT UserName FROM ReportServer.dbo.Users
WHERE UserName NOT IN 
('Everyone', 'NT AUTHORITY\SYSTEM', 'NT AUTHORITY\NETWORK SERVICE', 
'BUILTIN\Administrators', 'Domain Users')

--find the favorite rendering types
SELECT format, COUNT(1) AS cnt
FROM ReportServer.dbo.ExecutionLog
GROUP BY format
ORDER BY cnt

--Get the most frequently used reports
SELECT c.Path, c.Name, COUNT(1) AS cnt 
FROM ReportServer.dbo.ExecutionLog e JOIN ReportServer.dbo.Catalog c
ON e.ReportID = c.ItemID
GROUP BY c.Path, c.Name
ORDER BY cnt DESC

--Get the reports that take longer to retrieve the data
SELECT c.Path, c.Name, MAX(TimeDataRetrieval)/1000. AS seconds 
FROM ReportServer.dbo.ExecutionLog e JOIN ReportServer.dbo.Catalog c
ON e.ReportID = c.ItemID
GROUP BY c.Path, c.Name
ORDER BY seconds DESC

--Get the most frequent users
SELECT UserName, COUNT(1) AS cnt FROM ReportServer.dbo.ExecutionLog 
GROUP BY UserName
ORDER BY cnt DESC

--Get the latest subscription reports delivered
SELECT c.Path, c.Name, LastRunTime, REPLACE(LastStatus, 'Mail sent to ','') AS lastStatus  
FROM ReportServer.dbo.Subscriptions s JOIN ReportServer.dbo.Catalog c
ON s.Report_OID = c.ItemID
ORDER BY LastRunTime DESC

--get users and thier roles
SELECT UserName, RoleName, Description 
FROM ReportServer.dbo.Roles r JOIN ReportServer.dbo.PolicyUserRole pur
    ON r.roleid = pur.roleid
    JOIN ReportServer.dbo.Users u
    ON pur.userid = u.userid
    WHERE UserName NOT IN ('BUILTIN\Administrators', 'Domain Users', 'IUSR_REPORT02')
    ORDER BY UserName
    
-- Avg Rpt Runtime

select 
a.name,
 left(right([path], len([path]) - 1), charindex('/', right([path], len([path]) - 1), 0)) as Report_Path
,AVG(datediff(minute, el.TimeStart, el.TimeEnd)) as Average_RunTime_Minutes
	from catalog a
	Join ExecutionLog el
		on el.reportid = a.itemid
Where datediff(minute, el.TimeStart, el.TimeEnd) > 0
group by left(right([path], len([path]) - 1), charindex('/', right([path], len([path]) - 1), 0)), name
Order By AVG(datediff(minute, el.TimeStart, el.TimeEnd)) DESC


-- Avg Run Time Pnt Fld

Select 
Report_Path
, sum(Average_RunTime_Minutes) as Avg_Report_RunTime_Per_Parent_Path_InMinutes
From (
	select 
	a.name,
	 left(right([path], len([path]) - 1), charindex('/', right([path], len([path]) - 1), 0)) as Report_Path
	,avg(datediff(minute, el.TimeStart, el.TimeEnd)) as Average_RunTime_Minutes
		from catalog a
		Join ExecutionLog el
			on el.reportid = a.itemid
		Where datediff(minute, el.TimeStart, el.TimeEnd) > 0
	group by left(right([path], len([path]) - 1), charindex('/', right([path], len([path]) - 1), 0)), name
		) a
group by Report_Path
Order By sum(Average_RunTime_Minutes) DESC

-- SQL Agent To Report

SELECT 
dbo.Schedule.ScheduleID as SQL_Agent_Schedule_Name
, dbo.[Catalog].ItemID as SSRS_Report_ItemID
, dbo.[Catalog].Name as SSRS_Report
, dbo.[Catalog].Path as SSRS_Path
	FROM dbo.Schedule 
	INNER JOIN dbo.ReportSchedule 
		ON dbo.Schedule.ScheduleID = dbo.ReportSchedule.ScheduleID 
	INNER JOIN dbo.[Catalog] 
		ON dbo.ReportSchedule.ReportID = dbo.[Catalog].ItemID 
--where dbo.Schedule.ScheduleID in ('9F46BFE6-C2A1-48CF-8D6A-0322D67B9186',
--'9B0E034B-2C3D-4B08-8E9E-2CCFEC87AA37',
--'E3837F5C-EC72-4C07-82BC-63DB6B77D8B4',
--'47AFADF8-DCB1-41FE-B084-C290A9F86CC9',
--'F2508360-568B-405A-B9D5-E8AD428949B2')
Order by dbo.[Catalog].Name		
		

--Subscr Run When

SELECT 
u.UserName AS TheUser
, s.LastRunTime
, s.LastStatus
, s.* --you should list out the specific columns you need here and not use ‘*’ 
, c.Name AS TheReport
, c.Path as ReportPath
	FROM [Catalog] c
	INNER JOIN Subscriptions s 
		ON s.Report_OID = c.ItemID
	INNER JOIN Users u 
		ON u.UserID = s.OwnerID

ORDER BY s.LastRunTime desc--c.Name

-- Who Runs What

SELECT 
c1.Name AS ReportName,
e1.UserName AS Employee,
e1.Format, --what did they export the report to (optional)
e1.Parameters, --did they query the result set (optional)
e1.TimeStart,
e1.TimeEnd, --when did they run it ?
datediff(minute, e1.TimeStart, e1.TimeEnd) as Duration,
c1.Path as ReportPath,
e1.*
	FROM [Catalog] c1
	INNER JOIN ExecutionLog e1 
		ON e1.ReportID = c1.ItemID
where datediff(minute, e1.TimeStart, e1.TimeEnd) > 2
and e1.TimeStart >= dateadd(day, -30, getdate())
order by e1.TimeEnd

