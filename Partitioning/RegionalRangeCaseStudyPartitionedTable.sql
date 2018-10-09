-------------------------------------------------------
-- SQL Server 2005 - Scripts written for Beta 2
-- Partitioned Tables Whitepaper Examples
-- Creating Filegroups
-- September 2004

-- Regional Range Partitions
-- RegionalRangeCaseStudyPartitionedTable.sql
-------------------------------------------------------

USE SalesDB
GO

-------------------------------------------------------
-- Create the partition function
-------------------------------------------------------
CREATE PARTITION FUNCTION CustomersCountryPFN(char(7))
AS 
RANGE LEFT FOR VALUES ('France', 'Germany', 'Italy', 'Spain' )
GO

-------------------------------------------------------
-- Create the partition scheme
-------------------------------------------------------
CREATE PARTITION SCHEME [CustomersCountryPScheme]
AS 
PARTITION CustomersCountryPFN TO ([France], [Germany], [Italy], [Spain], [UK])
GO

-------------------------------------------------------
-- Create the Customers table on the partition scheme
-------------------------------------------------------
CREATE TABLE [dbo].[Customers](
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [char](7) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL
) ON CustomersCountryPScheme (Country)

-------------------------------------------------------
-- Add data
-------------------------------------------------------
INSERT Customers
	SELECT * 
		FROM northwind.dbo.customers 
		WHERE Country IN ('France', 'Germany', 'Italy', 'Spain', 'UK' )

-------------------------------------------------------
-- Verify Partition Ranges
-------------------------------------------------------

SELECT $partition.CustomersCountryPFN(Country) 
			AS 'Partition Number'
	, count(*) AS 'Rows In Partition'
FROM Customers
GROUP BY $partition.CustomersCountryPFN(Country)
ORDER BY 'Partition Number'
GO

-------------------------------------------------------
-- To see the partition information row by row
-------------------------------------------------------
SELECT CompanyName, Country, 
	$partition.CustomersCountryPFN(Country) 
		AS 'Partition Number'
FROM Customers
GO