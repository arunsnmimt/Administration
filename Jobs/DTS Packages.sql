use msdb

SELECT * --, REPLACE(command,'DTSRun dtsrun /S dhlsqlcluster01 /U sa /P xxxxxxxx /N ','') AS DTS_Package
FROM dbo.sysjobs j INNER JOIN dbo.sysjobsteps js
ON j.job_id = js.job_id
WHERE Command like '%DTSRun%'
--and [enabled] = 1
--and   (j.name LIKE '%UAT%' or j.name LIKE '%Network_Rail%')
ORDER BY name


