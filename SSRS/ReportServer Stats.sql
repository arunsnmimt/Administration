Use ReportServer
go
--select * from executionlog where [Status]='rsSuccess'
select DB_NAME() AS DatabaseName
	,c.[Path]
	,c.[Name]
	,Count(*) as 'FreshRequests'
	,SUM(CASE WHEN [Status]='rsSuccess' THEN 1 ELSE 0 END) as 'CompleteRequests'
	,SUM(CASE WHEN [Status]<>'rsSuccess' THEN 1 ELSE 0 END) as 'InCompleteRequests'
	,SUM(CASE WHEN RequestType=1 THEN 1 ELSE 0 END) as 'SubscriptionRequests'
	,SUM(CASE WHEN RequestType=0 THEN 1 ELSE 0 END) as 'WebAppRequests'
	,SUM(CASE WHEN Format='MHTML' THEN 1 ELSE 0 END) as 'MHTML'
	,SUM(CASE WHEN Format='HTML4.0' THEN 1 ELSE 0 END) as 'HTML'
	,SUM(CASE WHEN Format='PDF' THEN 1 ELSE 0 END) as 'PDF'
	,SUM(CASE WHEN Format='RPL' THEN 1 ELSE 0 END) as 'RPL'
	,SUM(CASE WHEN Format='XML' THEN 1 ELSE 0 END) as 'XML'
	,SUM(CASE WHEN Format='CSV' THEN 1 ELSE 0 END) as 'CSV'
	,SUM(CASE WHEN Format='EXCEL' THEN 1 ELSE 0 END) as 'Excel'
	,SUM(CASE WHEN Format='IMAGE' THEN 1 ELSE 0 END) as 'IMAGE'
	,AVG(TimeDataRetrieval) as 'AVGTime_Data'
	,AVG(TimeProcessing) as 'AVGTime_Processing'
	,AVG(TimeRendering) as 'AVGTime_Render'
	,STDEV(TimeDataRetrieval) as 'stdDevTime_Data'
	,STDEV(TimeProcessing) as 'stdDevTime_Processing'
	,STDEV(TimeRendering) as 'stdDevTime_Render'
	,AVG([RowCount]) as 'AVG_RowCount'
	,STDEV([RowCount]) as 'stdDev_RowCount'
	,MIN(TimeStart) as 'FirstRun'
	,MAX(TimeStart) as 'LastRun'
FROM ExecutionLog el
JOIN Catalog c
	ON el.ReportID=c.ItemID
WHERE Format IS NOT NULL
GROUP BY c.[Path]
	,c.[Name]
