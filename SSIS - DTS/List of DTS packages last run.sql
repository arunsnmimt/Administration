select * from sysjobsteps
where command like 'DTSRUN%'
and last_run_date in ('20130121', '20130122')     -- Jobs ran 21st and 22nd Jan 2013
--and step_name like '%UAT%'