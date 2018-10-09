-------------------------------------------------------
-- SQL Server 2005 - Scripts written for Beta 2
-- Partitioned Tables Whitepaper Examples
-- Creating Filegroups
-- September 2004

-- RangeCaseStudyScript1-Filegroups.sql
-- Written by Kimberly L. Tripp
--	Founder, SQLskills.com
-------------------------------------------------------

-------------------------------------------------------
-- This script adds 24 FILEGROUPS and 24 FILES
-- (one file for each filegroup) to Sales database. 

-- This script uses a table to build the filegroups - make sure
-- to modify the INSERT statements to use the appropriate disks. 
-- Also, the initial size (1MB), maximum size (100MB) and the
-- growth rate (5MB) for these filegroups is different (MUCH smaller)
-- than the whitepaper showed. If desired, change the 
-- string to use the desired sizes.
-- 
-- Make sure you CREATE the database first and make sure 
-- you create a C:\SalesDB subdir (you can modify this location in 
-- this script) before executing this!
-------------------------------------------------------

-------------------------------------------------------
-- Add 24 FILEGROUPS to the Sales Database
-------------------------------------------------------
GO
-- DROP DATABASE SalesDB -- for testing
-- CREATE DATABASE SalesDB -- for testing
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG1]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG2]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG3]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG4]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG5]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG6]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG7]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG8]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG9]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG10]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG11]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG12]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG13]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG14]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG15]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG16]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG17]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG18]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG19]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG20]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG21]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG22]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG23]
GO

ALTER DATABASE SalesDB
ADD FILEGROUP [FG24]
GO

-------------------------------------------------------
-- Add Files to each Filegroup
-------------------------------------------------------
USE SalesDB
go
CREATE TABLE SalesDB.dbo.FilegroupInfo
(
	PartitionNumber	smallint,
	FilegroupNumber	tinyint,
	Location	nvarchar(50)
)
go

-- All files go to DRIVE C:\SalesDB - for testing...
INSERT dbo.FilegroupInfo VALUES (1, 1, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (2, 2, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (3, 3, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (4, 4, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (5, 5, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (6, 7, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (7, 8, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (8, 9, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (9, 9, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (10, 10, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (11, 11, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (12, 12, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (13, 13, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (14, 14, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (15, 15, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (16, 16, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (17, 17, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (18, 18, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (19, 19, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (20, 20, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (21, 21, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (22, 22, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (23, 23, N'C:\SalesDB')
INSERT dbo.FilegroupInfo VALUES (24, 24, N'C:\SalesDB')
-- go

-- All files directed to the disks as shown in the whitepaper
-- INSERT dbo.FilegroupInfo VALUES (1, 1, N'E:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (2, 2, N'F:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (3, 3, N'G:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (4, 4, N'H:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (5, 5, N'I:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (6, 7, N'J:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (7, 8, N'K:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (8, 9, N'L:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (9, 9, N'M:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (10, 10, N'N:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (11, 11, N'O:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (12, 12, N'P:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (13, 13, N'K:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (14, 14, N'L:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (15, 15, N'M:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (16, 16, N'N:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (17, 17, N'O:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (18, 18, N'P:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (19, 19, N'E:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (20, 20, N'F:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (21, 21, N'G:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (22, 22, N'H:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (23, 23, N'I:\SalesDB')
-- INSERT dbo.FilegroupInfo VALUES (24, 24, N'J:\SalesDB')
-- go

DECLARE @PartitionNumber	smallint,
	@FilegroupNumber	tinyint,
	@Location		nvarchar(50),
	@ExecStr		nvarchar(300)

DECLARE FilegroupsToCreate CURSOR FOR 
	SELECT * FROM dbo.FileGroupInfo
	ORDER BY PartitionNumber
OPEN FilegroupsToCreate 
FETCH NEXT FROM FilegroupsToCreate INTO @PartitionNumber, @FilegroupNumber, @Location

WHILE (@@fetch_status <> -1) -- (-1) you've fetched beyond the cursor
BEGIN
    IF (@@fetch_status <> -2) -- (-2) you've fetched a row that no longer exists
    BEGIN  -- Fetch_status must be 0
	SELECT @ExecStr = N'ALTER DATABASE SalesDB ' + 
			  N'	ADD FILE ' + 
			  N'	  (NAME = N''SalesDBFG' + CONVERT(nvarchar, @PartitionNumber) + N'File1'',' +
			  N'       FILENAME = N''' + @Location + N'\SalesDBFG' + CONVERT(nvarchar, @PartitionNumber) + 'File1.ndf'',' + 
			  N'       SIZE = 1MB,' +  
			  N'       MAXSIZE = 100MB,' +
			  N'       FILEGROWTH = 5MB)' +
			  N' TO FILEGROUP ' + N'[FG' + CONVERT(nvarchar, @PartitionNumber) + N']'
	--SELECT (@ExecStr)
	EXEC (@ExecStr) -- DO NOT UNCOMMENT THIS UNTIL YOU ARE SURE THE NAMES and LOCATIONS are correct.
    END

FETCH NEXT FROM FilegroupsToCreate INTO @PartitionNumber, @FilegroupNumber, @Location
END

DEALLOCATE FilegroupsToCreate 
GO

-- Each of the twenty four files should be added with the information you used within the FileGroupInfo table
-- ALTER DATABASE SalesDB 	
-- ADD FILE 	  
-- 	(NAME = N'SalesDBFG1File1',
--         FILENAME = N'E:\SalesDB\SalesDBFG1File1.ndf'
--   	SIZE = 1MB,
--         MAXSIZE = 100MB,
--         FILEGROWTH = 5MB) 
-- TO FILEGROUP [FG1]

-------------------------------------------------------
-- Verify all files and filegroups
-------------------------------------------------------
USE SalesDB
go

sp_helpfilegroup
exec sp_helpfile
go
