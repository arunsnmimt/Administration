-------------------------------------------------------
-- SQL Server 2005 - Scripts written for Beta 2
-- Partitioned Tables Whitepaper Examples
-- Creating Partitioned Tables
-- September 2004

-- RangeCaseStudyScript2-PartitionedTable.sql
-- Written by Kimberly L. Tripp
--	Founder, SQLskills.com
-------------------------------------------------------

USE SalesDB
GO

-------------------------------------------------------
-- Create the partition function
-------------------------------------------------------
CREATE PARTITION FUNCTION TwoYearDateRangePFN(datetime)
AS 
RANGE LEFT FOR VALUES ('20021031 23:59:59.997',		-- Oct 2002
			'20021130 23:59:59.997',	-- Nov 2002
			'20021231 23:59:59.997',	-- Dec 2002
			'20030131 23:59:59.997',	-- Jan 2003
			'20030228 23:59:59.997',	-- Feb 2003
			'20030331 23:59:59.997',	-- Mar 2003
			'20030430 23:59:59.997',	-- Apr 2003
			'20030531 23:59:59.997',	-- May 2003
			'20030630 23:59:59.997',	-- Jun 2003
			'20030731 23:59:59.997',	-- Jul 2003
			'20030831 23:59:59.997',	-- Aug 2003
			'20030930 23:59:59.997',	-- Sep 2003
			'20031031 23:59:59.997',	-- Oct 2003
			'20031130 23:59:59.997',	-- Nov 2003
			'20031231 23:59:59.997',	-- Dec 2003
			'20040131 23:59:59.997',	-- Jan 2004
			'20040229 23:59:59.997',	-- Feb 2004
			'20040331 23:59:59.997',	-- Mar 2004
			'20040430 23:59:59.997',	-- Apr 2004
			'20040531 23:59:59.997',	-- May 2004
			'20040630 23:59:59.997',	-- Jun 2004
			'20040731 23:59:59.997',	-- Jul 2004
			'20040831 23:59:59.997',	-- Aug 2004
			'20040930 23:59:59.997')	-- Sep 2004
GO

-------------------------------------------------------
-- Create the partition scheme
-------------------------------------------------------
CREATE PARTITION SCHEME [TwoYearDateRangePScheme]
AS 
PARTITION [TwoYearDateRangePFN] TO 
		( [FG1], [FG2], [FG3], [FG4], [FG5], [FG6], 
		  [FG7], [FG8], [FG9], [FG10],[FG11],[FG12],
		  [FG13],[FG14],[FG15],[FG16],[FG17],[FG18],
		  [FG19],[FG20],[FG21],[FG22],[FG23],[FG24], 
		  [PRIMARY])
-- The last partition will ALWAYS be empty using the Rolling Range Scenario. 
-- Using the PRIMARY is acceptible for this as no data will actually reside there.
GO

-------------------------------------------------------
-- Create the Orders table on the RANGE partition scheme
-------------------------------------------------------
CREATE TABLE SalesDB.[dbo].[Orders]  
(
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NULL,
	[VendorID] [int] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[SubTotal] [money] NULL,
	[Status] [tinyint] NOT NULL ,
	[RevisionNumber] [tinyint] NULL ,
	[ModifiedDate] [datetime] NULL ,
	[ShipMethodID]	tinyint NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL
		CONSTRAINT OrdersRangeYearCK
			CHECK ([OrderDate] >= '20021001' 
				AND [OrderDate] < '20041001'), 
	[TotalDue] [money] NULL
) ON TwoYearDateRangePScheme(OrderDate)
GO

CREATE TABLE [dbo].[OrderDetails](
	[OrderID] [int] NOT NULL,
	--[LineNumber] [smallint] NOT NULL,
	[ProductID] [int] not NULL,
	[UnitPrice] [money] NULL,
	[OrderQty] [smallint] NULL,
	[ReceivedQty] [float] NULL,
	[RejectedQty] [float] NULL,
	[OrderDate] [datetime] NOT NULL
		CONSTRAINT OrderDetailsRangeYearCK
			CHECK ([OrderDate] >= '20021001' 
				 AND [OrderDate] < '20041001'), 
	[DueDate] [datetime] NULL,
	[ModifiedDate] [datetime] NOT NULL 
		CONSTRAINT [OrderDetailsModifiedDateDFLT] 
			DEFAULT (getdate()),
	[LineTotal]  AS (([UnitPrice]*[OrderQty])),
	[StockedQty]  AS (([ReceivedQty]-[RejectedQty]))
) ON TwoYearDateRangePScheme(OrderDate)
GO

-------------------------------------------------------
-- Copy data from AdventureWorks to create the Orders 
-- and OrderDetails tables. You MUST install the AdeventureWorks
-- Database in order for these next two INSERT/SELECT
-- statements to populate the tables.
-- See the BOL topic: "Running Setup to Install AventureWorks 
-- Sample Database and Samples" for information on how to 
-- install the AdventureWorks sample database.
-------------------------------------------------------

-- Use the two following two queries to populate the SalesDB 
-- tables with AdventureWorks data. Note: A few partitions
-- will NOT contain any data.

INSERT dbo.[Orders]
	SELECT o.[PurchaseOrderID] 
			, o.[EmployeeID]
			, o.[VendorID]
			, o.[TaxAmt]
			, o.[Freight] 
			, o.[SubTotal] 
			, o.[Status] 
			, o.[RevisionNumber] 
			, o.[ModifiedDate] 
			, o.[ShipMethodID] 
			, o.[ShipDate] 
			, o.[OrderDate] 
			, o.[TotalDue] 
	FROM AdventureWorks.Purchasing.PurchaseOrderHeader AS o
		WHERE ([OrderDate] >= '20021001' 
				 AND [OrderDate] < '20041001')

INSERT dbo.[OrderDetails]
	SELECT 	od.PurchaseOrderID
			--, od.LineNumber
			, od.ProductID
			, od.UnitPrice
			, od.OrderQty
			, od.ReceivedQty
			, od.RejectedQty
			, o.OrderDate
			, od.DueDate
			, od.ModifiedDate
	FROM AdventureWorks.Purchasing.PurchaseOrderDetail AS od
		JOIN AdventureWorks.Purchasing.PurchaseOrderHeader AS o
				ON o.PurchaseOrderID = od.PurchaseOrderID
		WHERE (o.[OrderDate] >= '20021001' 
				 AND o.[OrderDate] < '20041001')

-------------------------------------------------------
-- Verify Partition Ranges
-------------------------------------------------------

-- Note: Partitions 3,4,5 and 7 do NOT contain any data.

SELECT $partition.TwoYearDateRangePFN(o.OrderDate) 
			AS [Partition Number]
	, min(o.OrderDate) AS [Min Order Date]
	, max(o.OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM dbo.Orders AS o
GROUP BY $partition.TwoYearDateRangePFN(o.OrderDate)
ORDER BY [Partition Number]
GO

SELECT $partition.TwoYearDateRangePFN(od.OrderDate) 
			AS [Partition Number]
	, min(od.OrderDate) AS [Min Order Date]
	, max(od.OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM dbo.OrderDetails AS od
GROUP BY $partition.TwoYearDateRangePFN(od.OrderDate)
ORDER BY [Partition Number]
GO
-------------------------------------------------------
-- To see the partition information row by row - just for Orders
-------------------------------------------------------

SELECT OrderDate, 
	$partition.TwoYearDateRangePFN(OrderDate) 
		AS [Partition Number]
FROM Orders
ORDER BY OrderDate
GO

-------------------------------------------------------
-- Create the clustered indexes as Primary keys
-- for both partitioned tables. Specifying the SCHEME 
-- is optional. If the table is partitioned the defaulf 
-- behavior is for SQL Server to create the cl index 
-- on the same partition scheme.
-------------------------------------------------------
ALTER TABLE Orders
ADD CONSTRAINT OrdersPK
	PRIMARY KEY CLUSTERED (OrderDate, OrderID)
	ON TwoYearDateRangePScheme(OrderDate)
GO

ALTER TABLE dbo.OrderDetails
add CONSTRAINT OrderDetailsPK
	PRIMARY KEY CLUSTERED (OrderDate, OrderID,productid)--, LineNumber)
	ON TwoYearDateRangePScheme(OrderDate)
GO

-- Finally, create the foreign key reference so that OrderDetails
-- rows must match their corresponding Orders rows.
ALTER TABLE dbo.OrderDetails
ADD CONSTRAINT OrderDetailsToOrdersFK
	FOREIGN KEY (OrderDate, OrderID)
		REFERENCES dbo.Orders (OrderDate, OrderID)
