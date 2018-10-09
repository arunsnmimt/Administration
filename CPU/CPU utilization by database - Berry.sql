DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)

--DROP TABLE #CPU
-- Get CPU utilization by database (adapted from Robert Pearl)  (Query 20) (CPU Usage by Database)
IF OBJECT_ID('tempdb..#CPU') IS NULL
BEGIN
	CREATE TABLE #CPU (
	DatabaseName VARCHAR(128),
	CPU_Time_Ms BIGINT,
	Date_Time DATETIME
	)
END


IF @SQLServerProductVersion < 11 -- SQL Server 2008 R2 or less
BEGIN

	IF OBJECT_ID('tempdb..#CPU') IS NOT NULL
	BEGIN
		INSERT INTO #CPU (DatabaseName, CPU_Time_Ms, Date_Time)
		SELECT DB_Name(DatabaseID) AS [DatabaseName], SUM(total_worker_time) AS [CPU_Time_Ms], GETDATE()
		 FROM sys.dm_exec_query_stats AS qs
		 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
					  FROM sys.dm_exec_plan_attributes(qs.plan_handle)
					  WHERE attribute = N'dbid') AS F_DB
--				WHERE DB_Name(DatabaseID) <> 'TMC_NEXT'
			WHERE DatabaseID > 4 -- system databases
				AND DatabaseID <> 32767 -- ResourceDB
		 GROUP BY DatabaseID
	END
	ELSE
	BEGIN
		WITH DB_CPU_Stats
		AS
		(SELECT DatabaseID, DB_Name(DatabaseID) AS [DatabaseName], SUM(total_worker_time) AS [CPU_Time_Ms]
		 FROM sys.dm_exec_query_stats AS qs
		 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
					  FROM sys.dm_exec_plan_attributes(qs.plan_handle)
					  WHERE attribute = N'dbid') AS F_DB
		 GROUP BY DatabaseID)
		SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [row_num],
			   DatabaseName, [CPU_Time_Ms], 
			   CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
		FROM DB_CPU_Stats
		WHERE DatabaseID > 4 -- system databases
		AND DatabaseID <> 32767 -- ResourceDB
		ORDER BY row_num OPTION (RECOMPILE);
	END;
	


END
ELSE
BEGIN
	WITH DB_CPU_Stats
	AS
	(SELECT DatabaseID, DB_Name(DatabaseID) AS [Database Name], SUM(total_worker_time) AS [CPU_Time_Ms]
	 FROM sys.dm_exec_query_stats AS qs
	 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
				  FROM sys.dm_exec_plan_attributes(qs.plan_handle)
				  WHERE attribute = N'dbid') AS F_DB
	 GROUP BY DatabaseID)
	SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank],
		   [Database Name], [CPU_Time_Ms] AS [CPU Time (ms)], 
		   CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Percent]
	FROM DB_CPU_Stats
	WHERE DatabaseID <> 32767 -- ResourceDB
	ORDER BY [CPU Rank] OPTION (RECOMPILE);
END;

IF OBJECT_ID('tempdb..#CPU') IS NOT NULL
BEGIN
	WITH DB_CPU_Stats
	AS
	(SELECT DatabaseName, MAX(CPU_Time_Ms) - MIN(CPU_Time_Ms) AS CPU_Time_Ms
	 FROM #CPU 
	 GROUP BY DatabaseName
	 	 HAVING  MAX(CPU_Time_Ms) - MIN(CPU_Time_Ms) > 0	 )
	SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [row_num],
		   DatabaseName, [CPU_Time_Ms], 
		   CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
	FROM DB_CPU_Stats
	ORDER BY row_num OPTION (RECOMPILE);
END;

--TRUNCATE TABLE #CPU
	--DatabaseName VARCHAR(128),
	--CPU_Time_Ms BIGINT,
	--Date_Time DATETIME