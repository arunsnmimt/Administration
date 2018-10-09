/*
Replication jobs


This metric investigates replication jobs, searching for any that may be disabled inappropriately.

If any of your replication jobs have been disabled inappropriately, you may not be aware of their state. If too much time passes, your publication may expire. This will inevitably cause you grief in recreating the publication. Ensuring that your replication jobs are functioning as desired is paramount. Monitoring them is vital to the health of your replication topology.

*/

SELECT @@ServerName AS [ServerName],
    sj.[Name],
    CASE WHEN sj.[enabled] = 1 THEN 'Enabled'
         ELSE 'Not Enabled - Please Investigate'
    END AS [Enabled],
    ISNULL(run_date, '') AS [Run_Date]
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
  WHERE (sj.name LIKE '%Distribution%'
    OR sj.name LIKE '%LogReader%')
    AND sj.name NOT LIKE '%backup%'
    AND sj.name NOT LIKE 'Replication monitoring refresher for distribution.'
  ORDER BY [run_date] DESC,
    sj.[name];