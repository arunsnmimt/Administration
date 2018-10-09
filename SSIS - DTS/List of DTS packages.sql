use msdb

--select DISTINCT name 
SELECT *
from dbo.sysdtspackages  
order by name


select top 1000 *
from msdb.dbo.sysdtspackagelog
order by endtime desc