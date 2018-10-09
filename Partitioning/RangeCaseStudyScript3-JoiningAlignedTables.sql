-------------------------------------------------------
-- SQL Server 2005 - Scripts written for Beta 2
-- Partitioned Tables Whitepaper Examples
-- Joining Aligned Tables
-- September 2004

-- RangeCaseStudyScript3-JoiningAlignedTables.sql
-- Written by Kimberly L. Tripp
--	Founder, SQLskills.com
-------------------------------------------------------

USE SalesDB
GO

SELECT o.OrderID, o.OrderDate, o.VendorID, od.ProductID, od.OrderQty
FROM dbo.Orders AS o
	INNER JOIN dbo.OrderDetails AS od ON o.OrderID = od.OrderID
						AND o.OrderDate = od.OrderDate
WHERE o.OrderDate >= '20040701' 
		AND o.OrderDate <= '20040930 11:59:59.997'
	
-------------------------------------------------------
-- Reminder (from previous exercise) 
-- Verify Partition Ranges using the Partition Function
-------------------------------------------------------

SELECT $partition.TwoYearDateRangePFN(o.OrderDate) 
			AS [Partition Number]
	, min(o.OrderDate) AS [Min Order Date]
	, max(o.OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM dbo.Orders AS o
WHERE $partition.TwoYearDateRangePFN(o.OrderDate) IN (21, 22, 23)
GROUP BY $partition.TwoYearDateRangePFN(o.OrderDate)
ORDER BY [Partition Number]
GO

SELECT $partition.TwoYearDateRangePFN(od.OrderDate) 
			AS [Partition Number]
	, min(od.OrderDate) AS [Min Order Date]
	, max(od.OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM dbo.OrderDetails AS od
WHERE $partition.TwoYearDateRangePFN(od.OrderDate) IN (21, 22, 23)
GROUP BY $partition.TwoYearDateRangePFN(od.OrderDate)
ORDER BY [Partition Number]
GO