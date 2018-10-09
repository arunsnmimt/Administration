/*
Plan cache reuse


This metric shows the percentage of cached plans that are being used more than once. If a plan is cached but never reused, there may be an opportunity to tune your server to work more effectively by rewriting the TSQL or creating a parameterized plan.
Metric definition
Metric Name:
	
Reuse of plans that are stored in the plan cache is important to the efficiency of SQL Server. Having the cache full of plans that are not reused is wasteful, and it means that there may be lots of queries not using the cache efficiently. If this metric is low then investigate the number of plans in your cache that have a usecount of 1 and see if any can be parameterized.
*/

DECLARE @single DECIMAL(18, 2)
DECLARE @reused DECIMAL(18, 2)
DECLARE @total DECIMAL(18, 2)
-- the above variables may need a precision greater than 18 on VLDB instances. This will incur a storage penalty in the RedgateMonitor database however.
SELECT @single = SUM(CASE ( usecounts )
                       WHEN 1 THEN 1
                       ELSE 0
                     END) * 1.0 ,
        @reused = SUM(CASE ( usecounts )
                        WHEN 1 THEN 0
                        ELSE 1
                      END) * 1.0 ,
        @total = COUNT(usecounts) * 1.0
    FROM sys.dm_exec_cached_plans;
 
 
SELECT ( @single / @total ) * 100.0;
