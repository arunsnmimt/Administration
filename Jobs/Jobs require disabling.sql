USE msdb

SELECT name, 'EXEC msdb.dbo.sp_update_job @job_id=N'''+ CAST(job_id AS VARCHAR(100)) +''', @enabled=0'  AS Command
FROM dbo.sysjobs
WHERE [enabled] = 1
--AND SUBSTRING(Name,9,1) = '-' AND SUBSTRING(Name,14,1) = '-' AND SUBSTRING(Name,19,1) = '-' AND SUBSTRING(Name,24,1) = '-' 
AND name LIKE 'Admin - Collect Fragmentation Levels%'
--AND name NOT LIKE '%UAT%'
ORDER BY name

SELECT  *
FROM  dbo.sysjobs
WHERE SUBSTRING(Name,9,1) = '-' 
AND SUBSTRING(Name,14,1) = '-' 
AND SUBSTRING(Name,19,1) = '-' 
AND SUBSTRING(Name,24,1) = '-' 
--AND name LIKE 'TMC_Reports%'
--AND name NOT LIKE '%UAT%'
and [enabled] = 0

