USE ReportServer

SELECT TOP 150 LOWER(REPLACE(UserName, 'BROXTOWE\','')) + ';', COUNT(*)
FROM ExecutionLog EL INNER JOIN CATALOG CAT 
ON EL.ReportID = CAT.ItemID
WHERE TimeStart > DATEADD(DAY,-15,GETDATE())
AND UserName NOT IN ('NT AUTHORITY\SYSTEM', 'SQL-02\ReportUser', 'BROXTOWE\stuart.pritchard',  N'BROXTOWE\nigel.percy', 'BROXTOWE\michael.giles')
--AND UserName <> 'NT AUTHORITY\SYSTEM'
--AND UserName <> 'SQL-02\ReportUser;'
--and UserName <> 'chris.lord'
GROUP BY UserName
HAVING COUNT(*) >= 5
ORDER BY COUNT(*) DESC



SELECT CAT.Name, CAT.Path, COUNT(*) 
FROM ExecutionLog EL INNER JOIN CATALOG CAT 
ON EL.ReportID = CAT.ItemID
	INNER JOIN DataSource DS 
			ON CAT.ItemID = DS.ItemID
--WHERE TimeStart > DATEADD(DAY,-8,GETDATE())
WHERE EL.UserName NOT IN ('NT AUTHORITY\SYSTEM', 'SQL-02\ReportUser;', 'BROXTOWE\stuart.pritchard', 'BROXTOWE\stuart.pritchard', N'BROXTOWE\nigel.percy')
--AND TimeStart > DATEADD(DAY,-8,GETDATE())
AND DS.Name = 'ILRAnalyser'
--AND CAT.Name NOT IN ('16-18 learners with 360 GLH or more and no Key or Functional Skills', 'Course Level Performance Report', 'Division Learning Aim Summary', 'Divisional KPI Report', 'Divisional KPI Report Part 2 - E and D', 'LR Funding', 'LR Learner Numbers', 'Apprenticeship Funding Summary', 'International Learner Funding', 'LSC ACL Funding - Learners on a course', 'LSC ACL Funding by Division', 'LSC LR Funding - Learners on a course', 'LSC LR Funding by Division', 'LSC LR Funding by Study Location', 'LSC LR Funding Summary', 'Learner Numbers Report', 'Learner Progressions', 'LR ILR Data Viewer Courses', 'LR ILR Data Viewer Divisions', 'LR ILR Data Viewer Students', 'Minimum Levels of Performance', 'Minimum Levels of Performance - Export Version', 'subRpt_KPI2') 
GROUP BY CAT.Name, CAT.Path
ORDER BY COUNT(*) DESC




-- Report Usage

SELECT     Catalog.Name, COUNT(*) AS ReportsRan, REPLACE(Catalog.Path, '/' + Catalog.Name, '') AS Folder, ExecutionLog.TimeStart
FROM         ExecutionLog RIGHT OUTER JOIN
                      CATALOG ON ExecutionLog.ReportID = Catalog.ItemID
WHERE     (NOT (ExecutionLog.UserName IN (N'NT AUTHORITY\NETWORK SERVICE',N'SQL-02\ReportUser;', N'BROXTOWE\stuart.pritchard', N'BROXTOWE\stuart.pritchard', N'BROXTOWE\nigel.percy')))
GROUP BY Catalog.Name, REPLACE(Catalog.Path, '/' + Catalog.Name, ''), ExecutionLog.TimeStart
HAVING      (NOT (Catalog.Name = N''))
ORDER BY ReportsRan DESC    