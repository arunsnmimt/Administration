/*
Plan cache hit ratio

This metric needs to be considered alongside the Plan cache reuse metric that looks at the spread of plan reuse through your cache.

A high plan cache hit ratio does not guarantee that all queries are using the cache as well as they might. It shows the percentage of queries that are being linked to a cached plan rather than generating a new one. Knowing the percentage of queries that are satisfied from cache helps you to better understand the plan cache hit ratio value.

To appreciate the difference between plan cache reuse and plan cache hit ratio, consider the difference between 10 people each asking you the same question, and 10 people each asking you a different question. Once you have got the answer in the first scenario you can answer 9 people from memory. In the second, you can’t do this, and may have to rely on reference materials before you can answer each question correctly.
	
This metric measures how much the plan cache is being used. A high percentage here means that your SQL Server is not building a new plan for every query it is executing so is working effectively and efficiently. A low percentage here means that for some reason, the SQL Server is doing more work than it needs to. This metric needs to be considered alongside the Plan cache reuse metric which looks at the spread of plan reuse through your cache.

*/
WITH    cte1
          AS ( SELECT [dopc].[object_name] ,
                    [dopc].[instance_name] ,
                    [dopc].[counter_name] ,
                    [dopc].[cntr_value] ,
                    [dopc].[cntr_type] ,
                    ROW_NUMBER() OVER ( PARTITION BY [dopc].[object_name], [dopc].[instance_name] ORDER BY [dopc].[counter_name] ) AS r_n
                FROM [sys].[dm_os_performance_counters] AS dopc
                WHERE [dopc].[counter_name] LIKE '%Cache Hit Ratio%'
                    AND ( [dopc].[object_name] LIKE '%Plan Cache%'
                          OR [dopc].[object_name] LIKE '%Buffer Cache%'
                        )
                    AND [dopc].[instance_name] LIKE '%_Total%'
             )
    SELECT CONVERT(DECIMAL(16, 2), ( [c].[cntr_value] * 1.0 / [c1].[cntr_value] ) * 100.0) AS [hit_pct]
        FROM [cte1] AS c
            INNER JOIN [cte1] AS c1
                ON c.[object_name] = c1.[object_name]
                   AND c.[instance_name] = c1.[instance_name]
        WHERE [c].[r_n] = 1
            AND [c1].[r_n] = 2;