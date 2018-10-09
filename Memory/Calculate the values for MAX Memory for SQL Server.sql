-- ** Calculate the values for MAX Memory for SQL Server **
-- SQL script created by Rudy Panigas Nov 2011 with reference from "TroubleShooting SQL Server A Guide for the Accidental DBA"
-- which was written by Jonathan Kehayias and Ted Krueger ISBN: 978-1-90643477-9

PRINT ' '
PRINT ' ** Calculate the values for MAX Memory for SQL Server **'
PRINT ' '
PRINT ' Calculating the SQL Server MAX Memory setting, as general base configuration for a *dedicated* SQL Server machine.'
PRINT ' *dedicated* means that only SQL Server and related services are running on the server. NO other application is install'
PRINT ' and running on the server. Therefore it is only dedicated to run SQL Server.'
PRINT ' '
PRINT ' Below is the formula used to calculate the value to be used by SQL Server.'
PRINT ' '
PRINT ' 1. Reserve 1 Gigabyte (GB) of RAM for the Operating System (OS)'
PRINT ' 2. Reseeve 1GB of RAM for each 4GB of RAM installed from 4 - 16 GB'
PRINT ' 3. Add 1GB of RAM for every 8GB of RAM above 16GB'
PRINT ' '
PRINT ' This is a good starting point, then monitoring "Memory\Available Mbytes" performance counter to fine tune your value.'
PRINT ' '

-- Setting up variables for script
DECLARE 
@TotalMEMORYinBytes NUMERIC, -- Intial memory value of physical server in bytes
@TotalMEMORYinMegaBytes NUMERIC, -- Converted value of physical server memory in megabytes
@SQLMaxMemoryMegaByte NUMERIC, -- Value to use for SQL server MAX memory value in megabytes
@RamOver16GB NUMERIC -- Used to check if physical memory is over 16 gigabytes

-- Read physical memory on server 
SET @TotalMEMORYinBytes = (select physical_memory_in_bytes from sys.dm_os_sys_info) 

-- Coverting value from bytes to megabytes
SET @TotalMEMORYinMegaBytes = (@TotalMEMORYinBytes /(1024*1024)) 

-- OS need mim 1GB of RAM. Add 1 gigabyte to final value of MAX memory
SET @SQLMaxMemoryMegaByte = 1024 

-- If Total Memory is great thatn 16 GB of RAM then add 4 GB of RAM
IF @TotalMEMORYinMegaBytes > 16384 
BEGIN
 SET @SQLMaxMemoryMegaByte = (@SQLMaxMemoryMegaByte + 4096) -- Add 4 gigabytes to final value of MAX memory
 SET @RamOver16GB = ((@TotalMEMORYinMegaBytes - 16384)/8) -- Determine how much memory of over the 16GB of RAM
 SET @SQLMaxMemoryMegaByte = (@SQLMaxMemoryMegaByte + @RamOver16GB) -- Add 1GB of RAM for every 8GB of RAM above 16GB to sub total
END

-- Check if Total Memory is less than 16 GB but more than 12 GB
IF (@TotalMEMORYinMegaBytes <= 16384 and @TotalMEMORYinMegaBytes > 12288 ) SET @SQLMaxMemoryMegaByte = (@SQLMaxMemoryMegaByte + 4096 )

-- Check if Total Memory is less than 12 GB but more than 8 GB
IF (@TotalMEMORYinMegaBytes <= 12288 and @TotalMEMORYinMegaBytes > 8192) SET @SQLMaxMemoryMegaByte = (@SQLMaxMemoryMegaByte + 3072 )

-- Check if Total Memory is less than 8 GB but more than 4 GB
IF (@TotalMEMORYinMegaBytes <= 8192 and @TotalMEMORYinMegaBytes > 4096) SET @SQLMaxMemoryMegaByte = (@SQLMaxMemoryMegaByte + 2048 )

-- Check if Total Memory is less than 4 GB 

IF @TotalMEMORYinMegaBytes < 4096 SET @SQLMaxMemoryMegaByte = (@SQLMaxMemoryMegaByte + 0 )

-- Calculate Maximum Memory settings in megabytes
SET @SQLMaxMemoryMegaByte = (@TotalMEMORYinMegaBytes - @SQLMaxMemoryMegaByte) 

-- Show final value to use for MAX memory in SQL server. Value is set to megabytes because interface as for value in megabytes
SELECT @TotalMEMORYinMegaBytes / 1024.0 AS 'Total Server Memory in Gigabytes ***', @SQLMaxMemoryMegaByte / 1024.0 AS 'SQL Server MAX Memory Value in Gigabytes ***'
GO

