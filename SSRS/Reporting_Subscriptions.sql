SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


  
  USE ReportServer3
  
  --SELECT  *
  --FROM    dbo.Catalog
  --  WHERE [PATH] LIKE '/Custom Reports for Customers/%'
  
--  SELECT  cat.Name, 
  SELECT cat.[Path], cat.CreationDate, cat.ModifiedDate, sub.LastRunTime, sub.ModifiedDate, sub.Description, sub.LastStatus,  --sc.* --sub.*
--  sc.startDate AS ScheduledStartDate, 
  CASE sc.recurrencetype 
WHEN 1 THEN 'Once' 
WHEN 3 THEN 
CASE sc.daysinterval 
WHEN 1 THEN 'Every day' ELSE 'Every other ' + CAST(sc.daysinterval AS varchar) 
+ ' day.' END WHEN 4 THEN CASE sc.daysofweek WHEN 1 THEN 'Every ' 
+ CAST(sc.weeksinterval AS varchar) 
+ ' week on Sunday' WHEN 2 THEN 'Every ' + CAST(sc.weeksinterval AS varchar) 
+ ' week on Monday' WHEN 4 THEN 'Every ' + CAST(sc.weeksinterval AS varchar) 
+ ' week on Tuesday' WHEN 8 THEN 'Every ' + CAST(sc.weeksinterval AS varchar) 
+ ' week on Wednesday' WHEN 16 THEN 'Every ' + CAST(sc.weeksinterval AS varchar) 
+ ' week on Thursday' WHEN 32 THEN 'Every ' + CAST(sc.weeksinterval AS varchar) 
+ ' week on Friday' WHEN 64 THEN 'Every ' + CAST(sc.weeksinterval AS varchar) 
+ ' week on Saturday' WHEN 42 THEN 'Every ' + CAST(sc.weeksinterval AS varchar) 
+ ' week on Monday, Wednesday, and Friday' WHEN 62 THEN 'Every ' 
+ CAST(sc.weeksinterval AS varchar) 
+ ' week on Monday, Tuesday, Wednesday, Thursday and Friday' WHEN 126 THEN 'Every ' 
+ CAST(sc.weeksinterval AS varchar) 
+ ' week from Monday to Saturday' WHEN 127 THEN 'Every ' + CAST(sc.weeksinterval AS varchar) 
+ ' week on every day' END WHEN 5 THEN CASE sc.daysofmonth WHEN 1 THEN 'Day ' 
+ '1' + ' of each month' WHEN 2 THEN 'Day ' + '2' + ' of each month'
WHEN 4 THEN 'Day ' + '3' + ' of each month' WHEN 8 THEN 'Day ' + '4' + ' of each month' WHEN 16 THEN 'Day ' + '5' + ' of each month' WHEN 32 THEN 'Day ' + '6' + ' of each month' WHEN 64 THEN 'Day ' + '7' + ' of each month' WHEN 128 THEN 'Day ' + '8' + ' of each month' WHEN 256 THEN 'Day ' + '9'
+ ' of each month' WHEN 512 THEN 'Day ' + '10' + ' of each month' 
WHEN 1024 THEN 'Day ' + '11' + ' of each month' 
WHEN 2048 THEN 'Day ' + '12' + ' of each month' 
WHEN 4096 THEN 'Day ' + '13' + ' of each month' 
WHEN 8192 THEN 'Day ' + '14' + ' of each month' 
WHEN 16384 THEN 'Day ' + '15' + ' of each month' 
WHEN 32768 THEN 'Day ' + '16' + ' of each month' 
WHEN 65536 THEN 'Day ' + '17' + ' of each month' 
WHEN 131072 THEN 'Day ' + '18' + ' of each month' WhEN 262144 THEN 'Day ' + '19' + ' of each month' WHEN 524288 THEN 'Day ' + '20' + ' of each month' WHEN 1048576 THEN 'Day ' + '21' + ' of each month'
WHEN 2097152 THEN 'Day ' + '22' + ' of each month' WHEN 4194304 THEN 'Day ' + '23' + ' of each month' WHEN 8388608 THEN 'Day ' + '24' + ' of each month'
WHEN 16777216 THEN 'Day ' + '25' + ' of each month' WHEN 33554432 THEN 'Day ' + '26' + ' of each month' WHEN 67108864 THEN 'Day ' + '27' + ' of each month'
WHEN 134217728 THEN 'Day ' + '28' + ' of each month' WHEN 268435456 THEN 'Day ' + '29' + ' of each month' WHEN 536870912 THEN 'Day ' + '30' +
' of each month' WHEN 1073741824 THEN 'Day ' + '31' + ' of each month' END WHEN 6 THEN 'The ' + CASE sc.monthlyweek WHEN 1 THEN 'first' WHEN
2 THEN 'second' WHEN 3 THEN 'third' WHEN 4 THEN 'fourth' WHEN 5 THEN 'last' ELSE 'UNKNOWN' END + ' week of each month on ' + CASE sc.daysofweek
WHEN 2 THEN 'Monday' WHEN 4 THEN 'Tuesday' ELSE 'Unknown' END ELSE 'Unknown' END + ' at ' + LTRIM(RIGHT(CONVERT(varchar, sc.StartDate, 100), 7)) 
AS 'ScheduleDetails'
  FROM    
  dbo.Catalog cat LEFT JOIN  dbo.Subscriptions sub 
  ON sub.Report_OID = cat.ItemID
  LEFT JOIN ReportSchedule rsc
  ON sub.SubscriptionID = rsc.SubscriptionID
  LEFT JOIN Schedule sc
  ON sc.ScheduleID = rsc.ScheduleID
--  WHERE cat.[Path] LIKE '/Custom Reports%/%'
--  WHERE cat.[Path] LIKE '%Polypipe%'
--  WHERE cat.[Path] LIKE '/TrackerEvents Vehicle Exception/%'
--  WHERE cat.[Path] LIKE '/TMC_reports/CELTIC_TUNING%'
--  AND sub.LastRunTime IS NOT NULL
  WHERE cat.[Type] = 2
 -- WHERE cat.ItemID = 'AD2BD96C-AF7E-4A4E-913C-43014F0B3131'
--   AND sub.laststatus LIKE 'Failure%'
--   where sub.laststatus LIKE '%grace%'
 
   -- WHERE sub.LastStatus NOT LIKE 'Mail sent%'
--WHERE sub.LastStatus  LIKE '%uksmrouteplanning@carlsberg.co.uk%'
AND ExtensionSettings LIKE '%michael.giles@microlise.com%'
--ORDER BY sub.LastRunTime DESC
  ORDER BY [Path]  --sub.LastRunTime DESC
 
 /*
 SELECT TOP 1000 [ScheduleID]
      ,[ReportID]
      ,[SubscriptionID]
      ,[ReportAction]
  FROM [ReportServer].[dbo].[ReportSchedule]
 
 SELECT  *
 FROM    EVENT
 
 SELECT  *
 FROM     dbo.Catalog
 WHERE Name LIKE '%DHL Healthcare - PVA data%'
 
 WHERE ItemID = 'FBDBBB08-6A7D-415B-B2A5-01BAB3AE1479'
 
 SELECT  *
 FROM    ReportServer.dbo.Subscriptions 
 WHERE ExtensionSettings LIKE '%stephen.warden@jcb.com%'
 
UNION ALL

 SELECT  *
 FROM    ReportServer2.dbo.Subscriptions
 WHERE ExtensionSettings LIKE '%whasmith%'
 
 UNION ALL
 
  SELECT  *
 FROM    ReportServer3.dbo.Subscriptions
 WHERE ExtensionSettings LIKE '%whasmith%'



  SELECT  *
 FROM    ReportServer2.dbo.Subscriptions
 WHERE ExtensionSettings LIKE '%ftp%'


-- where sub.laststatus LIKE '%grace%'
 
 
 

 
 */