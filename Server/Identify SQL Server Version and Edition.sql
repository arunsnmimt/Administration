USE Master

SELECT  SERVERPROPERTY('productversion') as 'Version', SERVERPROPERTY ('productlevel') as 'Service Pack', SERVERPROPERTY ('edition') as 'Edition', SERVERPROPERTY('IsClustered') as 'Clustered', SERVERPROPERTY('LicenseType') as 'License Type', SERVERPROPERTY('NumLicenses') as 'No of Licenses'


SELECT @@version



SELECT DatabaseProperty ( 'dbccpagetest' , 'version' )



SELECT name AS 'DB Name' , cmptlevel AS 'Compatibility Level', [filename], version, crdate as 'Creation Date'
FROM sysdatabases
