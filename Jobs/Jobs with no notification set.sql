USE msdb

SELECT name, 'EXEC msdb.dbo.sp_update_job @job_id=N'''+ CAST(job_id AS VARCHAR(100)) +''', @notify_level_email=2, @notify_level_netsend=2, @notify_level_page=2, 	@notify_email_operator_name=N''Microlise DBA'''  AS Command
FROM dbo.sysjobs
WHERE notify_level_email = 0
AND SUBSTRING(Name,9,1) <> '-' 
AND SUBSTRING(Name,14,1) <> '-' 
AND SUBSTRING(Name,19,1) <> '-' 
AND SUBSTRING(Name,25,1) <> '-' 
AND name NOT IN ('syspolicy_purge_history','Expired subscription clean up','Agent history clean up: distribution','Distribution clean up: distribution','Reinitialize subscriptions having data validation failures','Replication agents checkup')
AND name NOT LIKE '%SQLVS%'
AND name NOT LIKE '%SQLCLUSTER05%'
AND name NOT LIKE '%SQLRPVS01%'
AND name NOT LIKE '%ETL%'
--AND name LIKE 'TMC_Reports%'
--AND name NOT LIKE '%UAT%'
and [enabled] = 1
ORDER BY name