USE msdb

/*
	List job steps 
*/

SELECT	a.Name,
--		b.last_run_date,
--		b.last_run_time,
		b.step_id, 
		b.database_name, 
		b.step_name, 
		b.subsystem, 
--		b.command
		REPLACE(REPLACE(b.command, CHAR(13), ''), CHAR(10), '') AS command
		--b.on_fail_action,
		--b.on_fail_step_id,
		--b.on_success_action,
		--b.on_success_step_id,
--		b.proxy_id,
--		prox.name AS Run_As
  FROM sysjobs a INNER JOIN sysjobsteps b
ON a.job_id = b.job_id
LEFT OUTER JOIN sysproxies prox
ON b.proxy_id = prox.proxy_id
WHERE a.enabled = 1
--and prox.name = 'NetworkAccessMikeGiles'
--AND a.Name IN ('Update SQL-02 EBS Tables')
--AND a.Name LIKE '%Tracking%'
ORDER BY a.Name , b.step_id





----a.job_id, b.step_id
--SELECT	a.Name  
--FROM sysjobs a
--WHERE a.enabled = 1
--ORDER BY a.Name

/*
select * from sysjobs 

select * from sysjobsteps 
*/
