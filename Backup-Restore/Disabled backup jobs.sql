/*
Disabled backup jobs


This metric investigates backup jobs, searching for any that may be disabled inappropriately.

If any of your backup jobs have been disabled inappropriately, you may not be aware of their state. This may cause you grief if backups do not occur properly. Ensuring that your backup jobs are functioning as desired is paramount. Monitoring them is vital to the health of your topology.

The alert associated with this metric will keep a vigilant eye on your systems, ensuring that the appropriate jobs remain in an enabled state, allowing their functionality to continue executing properly.

*/

SELECT COUNT(*) AS [Count]
  FROM msdb.dbo.sysjobs sj
  LEFT OUTER JOIN (SELECT MAX(CASE WHEN run_date IS NULL THEN ''
                                   ELSE SUBSTRING(CONVERT(VARCHAR, sh.run_date),
                                                  1, 4) + '-'
                                        + SUBSTRING(CONVERT(VARCHAR, sh.run_date),
                                                    5, 2) + '-'
                                        + SUBSTRING(CONVERT(VARCHAR, sh.run_date),
                                                    7, 2)
                              END) AS [run_date],
                      job_id
                    FROM msdb.dbo.sysjobhistory sh
                    WHERE Step_id = 0
                    GROUP BY job_id
                  ) AS sh
  ON
    sh.job_id = sj.job_id
  WHERE sj.name LIKE '%backup%'
    AND sj.name NOT IN ('Daily Backups.Subplan_1')
    AND sj.[enabled] <> 1;