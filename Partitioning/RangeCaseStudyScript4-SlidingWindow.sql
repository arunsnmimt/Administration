-------------------------------------------------------
-- SQL Server 2005 - Scripts written for Beta 2
-- Partitioned Tables Whitepaper Examples
-- Sliding Window Scenario
-- September 2004

-- RangeCaseStudyScript4-SlidingWindow.sql
-- Written by Kimberly L. Tripp
--	Founder, SQLskills.com
-------------------------------------------------------

USE SalesDB
GO

-------------------------------------------------------
-- Quick backup to make sure that we have one.
-------------------------------------------------------
--BACKUP DATABASE SalesDB TO DISK = 'C:\SalesDB\SalesDB.bak'
--	WITH INIT
--RESTORE DATABASE SalesDB FROM DISK = 'C:\SalesDB\SalesDB.bak'
--	WITH REPLACE

-------------------------------------------------------
-- Determine the partition with which to work
-------------------------------------------------------
SELECT ps.name AS PSName, 
		dds.destination_id AS PartitionNumber, 
		fg.name AS FileGroupName
FROM (((sys.tables AS t 
	INNER JOIN sys.indexes AS i 
		ON (t.object_id = i.object_id))
	INNER JOIN sys.partition_schemes AS ps 
		ON (i.data_space_id = ps.data_space_id))
	INNER JOIN sys.destination_data_spaces AS dds 
		ON (ps.data_space_id = dds.partition_scheme_id))
	INNER JOIN sys.filegroups AS fg
		ON dds.data_space_id = fg.data_space_id
WHERE (t.name = 'Orders') and (i.index_id IN (0,1))
	AND dds.destination_id = $partition.TwoYearDateRangePFN('20021001') 

-------------------------------------------------------
-- Create a staging table for October 2004
-------------------------------------------------------
CREATE TABLE SalesDB.[dbo].[OrdersOctober2004]  
(
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NULL,
	[VendorID] [int] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[SubTotal] [money] NULL,
	[Status] [tinyint] NOT NULL,
	[RevisionNumber] [tinyint] NULL,
	[ModifiedDate] [datetime] NULL,
	[ShipMethodID] [tinyint] NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL,
	[TotalDue] [money] NULL
) ON [FG1]
GO

-- -------------------------------------------------------
-- Populate the October 2004 table with new data.
-- -------------------------------------------------------
-- Through INSERT...SELECT or through parallel bulk insert
-- statements against the text files.
INSERT dbo.[Ordersoctober2004]
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
AND [OrderDate] < '20021101')

select * from [Ordersoctober2004]

update [Ordersoctober2004]
set orderdate='20041001'

GO


-- -------------------------------------------------------
-- Once the data is loaded then you can ALTER TABLE to
-- add the constraint. Be sure to use default WITH CHECK to 
-- verify the data and create a "trusted" constraint.
-- -------------------------------------------------------
ALTER TABLE SalesDB.[dbo].[OrdersOctober2004]  
WITH CHECK
ADD CONSTRAINT OrdersOctober2004RangeYearCK
	CHECK ([OrderDate] >= '20041001' 
		AND [OrderDate] <= '20041031 23:59:59.997')
GO

-------------------------------------------------------
-- The table must have the same clustered index
-- definition!
-------------------------------------------------------
ALTER TABLE [OrdersOctober2004]
ADD CONSTRAINT OrdersOctober2004PK
 PRIMARY KEY CLUSTERED (OrderDate, OrderID)
ON [FG1]
GO

-------------------------------------------------------
-- Now that the data is ready to be moved IN you can 
-- prepare to switch out the old data.
-- Create a table for the October 2001 partition being 
-- moved out 

-- THIS MUST BE ON THE SAME FILEGROUP AS THE PARTITION
-- BEING SWITCHED OUT. 
-- Remember, a switch solely "switches" meta data - to do this
-- the objects must be on the same filegroup!
-------------------------------------------------------
CREATE TABLE SalesDB.[dbo].[OrdersOctober2002]  
(
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NULL,
	[VendorID] [int] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[SubTotal] [money] NULL,
	[Status] [tinyint] NOT NULL,
	[RevisionNumber] [tinyint] NULL,
	[ModifiedDate] [datetime] NULL,
	[ShipMethodID] [tinyint] NULL,
	[ShipDate] [datetime] NOT NULL, 
	[OrderDate] [datetime] NOT NULL, 
	[TotalDue] [money] NULL
) ON [FG1]
GO
-------------------------------------------------------
-- The table must have the same clustered index
-- definition!
-------------------------------------------------------
ALTER TABLE [OrdersOctober2002]
ADD CONSTRAINT OrdersOctober2002PK
 PRIMARY KEY CLUSTERED (OrderDate, OrderID)
ON [FG1]
GO

-------------------------------------------------------
-- "Switch" the old partition out to a new table
-------------------------------------------------------
select * from OrdersOctober2002

ALTER TABLE dbo.OrderDetails
drop CONSTRAINT OrderDetailsToOrdersFK

ALTER TABLE Orders
SWITCH PARTITION 1
TO OrdersOctober2002
GO

ALTER TABLE dbo.OrderDetails
ADD CONSTRAINT OrderDetailsToOrdersFK
	FOREIGN KEY (OrderDate, OrderID)
		REFERENCES dbo.Orders (OrderDate, OrderID)

select * from OrdersOctober2002




	





-- Next you could back up the table and/or just drop it,
-- depending on what your archiving rules are, etc.

-------------------------------------------------------
-- Verify Data In Partition Ranges 2, 3, 4, ... 24
-------------------------------------------------------
SELECT $partition.TwoYearDateRangePFN(OrderDate)
			AS [Parition Number]
	, min(OrderDate) AS [Min Order Date]
	, max(OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM Orders
GROUP BY $partition.TwoYearDateRangePFN(OrderDate)
ORDER BY [Parition Number]
GO

-------------------------------------------------------
-- Alter the partition function to drop the old range
-- The idea is that when paritions are merged a boundary
-- point is removed.
-- If there's data on the paritions then it needs to be
-- reconciled to one partition therefore which partition's
-- filegroup will get the data?
-- The one that DOES NOT contain the boundary point that
-- is being removed. 
-- In this case, the original partition function was 
-- defined as LEFT and therefore the boundary point is in
-- the LEFT partition - all remaining data (in the LEFT 
-- partition) will be moved to the next partition.

-- The benefit in this case is that all of the data to the 
-- LEFT of the boundary point has been removed already - 
-- during the SWITCH - therefore there is no data to move.

-- The merge operation should be extremely fast!
-------------------------------------------------------
ALTER PARTITION FUNCTION TwoYearDateRangePFN()
MERGE RANGE ('20021031 23:59:59.997')
GO 

-------------------------------------------------------
-- Verify Partition Ranges
-- Data was in partitions 2 through 24 and now merge removed
-- partiton 1...
-- SQL Server always numbers the data based on the CURRENT
-- number of partitions so if you run the query again you 
-- will see ONLY 23 partitions but the partition numbers
-- will be 1, 2 and 3 even though NO DATA HAS MOVED (only 
-- the logical partition numbers have changed).
-------------------------------------------------------

SELECT $partition.TwoYearDateRangePFN(OrderDate)
			AS [Parition Number]
	, min(OrderDate) AS [Min Order Date]
	, max(OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM Orders
GROUP BY $partition.TwoYearDateRangePFN(OrderDate)
ORDER BY [Parition Number]
GO

-------------------------------------------------------
-- This also removes the filegroup associated with the
-- partition scheme (meaning that [FG1] filegroup is 
-- no longer associated. If you want to roll the new data
-- through the same existing 24 partitions then you
-- will need to make FG1 next used again.
-------------------------------------------------------

--Use the following query to see to see ALL filegroups
SELECT * FROM sys.filegroups

-- Use the following query to see to see ONLY the filegroups
-- associated with OrdersRange

-------------------------------------------------------
-- Alter the partition SCHEME to add the next partition
-------------------------------------------------------
ALTER PARTITION SCHEME TwoYearDateRangePScheme NEXT USED [FG1]
GO

-------------------------------------------------------
-- Alter the partition function to add the new range
-------------------------------------------------------
ALTER PARTITION FUNCTION TwoYearDateRangePFN() 
SPLIT RANGE ('20041031 23:59:59.997')
GO 

-------------------------------------------------------
-- BEFORE you can add this data you must allow it.
-------------------------------------------------------
ALTER TABLE Orders
ADD CONSTRAINT OrdersRangeMaxOctober2004
	CHECK ([OrderDate] < '20041101')

ALTER TABLE Orders
ADD CONSTRAINT OrdersRangeMinNovember2002
	CHECK ([OrderDate] >= '20021101')

ALTER TABLE Orders
DROP CONSTRAINT OrdersRangeYearCK
go

-------------------------------------------------------
-- "Switch" the new partition in.
-------------------------------------------------------
select * from OrdersOctober2004

ALTER TABLE OrdersOctober2004
SWITCH TO Orders PARTITION 24
GO

-------------------------------------------------------
-- Verify Date Ranges for partitions - All 24!
-------------------------------------------------------
SELECT $partition.TwoYearDateRangePFN(OrderDate)
			AS [Parition Number]
	, min(OrderDate) AS [Min Order Date]
	, max(OrderDate) AS [Max Order Date]
	, count(*) AS [Rows In Partition]
FROM Orders
GROUP BY $partition.TwoYearDateRangePFN(OrderDate)
ORDER BY [Parition Number]
GO

-------------------------------------------------------
-- Drop the staging tables
-------------------------------------------------------
DROP TABLE dbo.OrdersOctober2002
GO

DROP TABLE dbo.OrdersOctober2004
GO

-------------------------------------------------------
-- Backup the filegroup
-------------------------------------------------------
BACKUP DATABASE SalesDB 
	FILEGROUP = N'FG1' 
TO DISK = N'C:\SalesDB\SalesDB.bak'
GO