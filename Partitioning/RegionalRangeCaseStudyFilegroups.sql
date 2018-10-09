-------------------------------------------------------
-- SQL Server 2005 - Scripts written for Beta 2
-- Partitioned Tables Whitepaper Examples
-- Creating Filegroups
-- July 2004

-- RegionalRangeCaseStudyFilegroups.sql
-- Written by Kimberly L. Tripp
--	Founder, SQLskills.com
-------------------------------------------------------

-------------------------------------------------------
-- This script adds 5 FILEGROUPS and 5 FILES
-- (one file for each filegroup) to the SalesDB database. 

-------------------------------------------------------

-------------------------------------------------------
-- Add 5 FILEGROUPS to the Sales Database
-------------------------------------------------------
GO
-- DROP DATABASE SalesDB -- for testing
-- CREATE DATABASE SalesDB -- for testing
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [Spain]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [Italy]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [France]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [UK]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [Germany]
GO

ALTER DATABASE SalesDB 	
ADD FILE 	  
 	(NAME = N'SalesDBSpain',
        FILENAME = N'C:\SalesDB\SalesDBSpain.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [Spain]
go

ALTER DATABASE SalesDB 	
ADD FILE 	  
 	(NAME = N'SalesDBItaly',
        FILENAME = N'C:\SalesDB\SalesDBItaly.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [Italy]

ALTER DATABASE SalesDB 	
ADD FILE 	  
 	(NAME = N'SalesDBFrance',
        FILENAME = N'C:\SalesDB\SalesDBFrance.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [France]

ALTER DATABASE SalesDB 	
ADD FILE 	  
 	(NAME = N'SalesDBUK',
        FILENAME = N'C:\SalesDB\SalesDBUK.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [UK]

ALTER DATABASE SalesDB 	
ADD FILE 	  
 	(NAME = N'SalesDBGermany',
        FILENAME = N'C:\SalesDB\SalesDBGermany.ndf',
  	SIZE = 1MB,
        MAXSIZE = 100MB,
        FILEGROWTH = 5MB) 
TO FILEGROUP [Germany]

-------------------------------------------------------
-- Verify all files and filegroups
-------------------------------------------------------
USE SalesDB
go

sp_helpfilegroup
exec sp_helpfile
go
