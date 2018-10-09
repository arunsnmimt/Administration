SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

USE ReportServer

 
 
SELECT  *
FROM    ReportServer3.dbo.CATALOG
WHERE name LIKE '%Activity by Driver%'
--where Type = 2
--WHERE Name LIKE '%ILR%'
--AND PATH NOT LIKE '/Data Sources%'
--AND PATH NOT LIKE '/Models%'


SELECT * 
FROM Catalog
where ItemID = '8F30B28A-E5FB-443F-8BB2-6D41B2C38756'


SELECT * 
FROM  dbo.DataSource