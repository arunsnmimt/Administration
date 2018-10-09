DECLARE @Version AS VARCHAR(500)
--DECLARE @SQL AS VARCHAR(500)

SET @Version = @@VERSION

--PRINT LEFT(@Version,25)

IF LEFT(@Version,25) = 'Microsoft SQL Server 2008'
BEGIN
	SELECT  name, CONVERT(xml,CONVERT(varbinary(max),PackageData)) AS PackageSource
	FROM msdb.dbo.sysssispackages 
END
ELSE
BEGIN
	SELECT sdp.name --, CONVERT(xml,CONVERT(varbinary(max),PackageData)) AS PackageSource
	FROM  msdb.dbo.sysdtspackages90 sdp INNER JOIN msdb.dbo.sysjobs sj
	ON sdp.name = sj.name
	WHERE sj.[enabled] = 1
	
--	WHERE name LIKE 'TMC_Reports_RYDER%' 
END

--EXEC(@SQL)
SELECT 
name FROM msdb.dbo.sysjobs

SELECT name --, CONVERT(xml,CONVERT(varbinary(max),PackageData)) AS PackageSource
	FROM  msdb.dbo.sysdtspackages90 