/*
http://www.sqlservercentral.com/blogs/dotnine-sql-server-and-more/2014/06/26/finding-the-last-successful-checkdb/

The information we are looking for is in the field ‘dbi_dbccLastKnownGood’ as that shows us the last successful CHECKDB run.

If you see a date of ‘1900-01-01 00:00:00.000’ it means CHECKDB has either never ran, or – even worse – has never had a successful run.

*/ 

DECLARE @DatabaseName VARCHAR(128)
SET @DatabaseName = (SELECT DB_NAME(DB_ID()))

DBCC PAGE (@DatabaseName, 1, 9, 3) WITH TABLERESULTS

