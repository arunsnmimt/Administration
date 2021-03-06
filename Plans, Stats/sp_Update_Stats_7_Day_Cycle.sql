USE [Admin_DBA]
GO

/****** Object:  StoredProcedure [dbo].[sp_Update_Stats_7_Day_Cycle]    Script Date: 04/08/2014 11:33:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[sp_Update_Stats_7_Day_Cycle]

AS

BEGIN
	SELECT 
	RowNum = ROW_NUMBER() OVER (ORDER BY name)
	, name
	INTO #DBStats
	FROM sys.databases db
	WHERE name LIKE 'TMC%'
	 AND state_desc = 'ONLINE'
	DECLARE @MaxDaysOld INT
	DECLARE @SamplePercent INT
	DECLARE @SampleType nvarchar(50)
	DECLARE @SampleSize nvarchar(100)
	DECLARE @Option AS VARCHAR(10)

	SET @MaxDaysOld = 3
	SET @SamplePercent = 35 --25
	SET @SampleType = 'PERCENT' --'ROWS'
	SET @Option = 'INDEX'


	DECLARE @RowCount AS SMALLINT
	DECLARE @DBsPerDay AS DECIMAL(9,3)
	DECLARE @DayofWeek AS TINYINT
	DECLARE @DatabaseName AS VARCHAR(128)
	DECLARE @SQL AS VARCHAR(4000)
	DECLARE @TableName AS VARCHAR(128)
	DECLARE @SchemaName AS VARCHAR(128)
	DECLARE @StatsName AS VARCHAR(128)
	SET @SampleSize = ISNULL(' WITH SAMPLE ' + CAST(@SamplePercent AS nvarchar(20)) + ' ' + @SampleType,N'')

	SET @RowCount = (SELECT COUNT(*)
					   FROM #DBStats)
					   

	SET @DBsPerDay = @RowCount / 7.000
	SET @DayofWeek =  DATEPART(DW, GETDATE())

	--SET @DayofWeek =  DATEPART(DW, GETDATE()+2)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+3)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+4)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+5)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+6)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+0)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+1)


	--PRINT ROUND(((@DayofWeek - 1) * @DBsPerDay) + 1 ,0, 1)
	--PRINT ROUND((@DayofWeek * @DBsPerDay) + .99 ,0 ,1)

	--SELECT  *
	--FROM    #DBStats
	--WHERE RowNum BETWEEN ROUND(((@DayofWeek - 1) * @DBsPerDay) + 1 ,0, 1) AND ROUND((@DayofWeek * @DBsPerDay) + .99 ,0 ,1)


	DECLARE database_stats CURSOR FOR
	SELECT name
	FROM    #DBStats
	WHERE RowNum BETWEEN ROUND(((@DayofWeek - 1) * @DBsPerDay) + 1 ,0, 1) AND ROUND((@DayofWeek * @DBsPerDay) + .99 ,0 ,1)
	--UNION ALL
--	SELECT 'TMC_CARLSBERG_UAT' AS name

	CREATE TABLE ##UpdateStats (
	DatabaseName VARCHAR(128),
	SchemaName   VARCHAR(128),
	TableName    VARCHAR(128),
	StatsName	 VARCHAR(128))



	OPEN database_stats

	FETCH NEXT FROM database_stats INTO @DatabaseName

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @SQL = 'USE ['+@DatabaseName+']; 
		INSERT INTO ##UpdateStats
		SELECT ''' + @DatabaseName +  ''' AS DatabaseName, 
		ist.table_schema as SchemaName,
		ob.name AS TableName
		,st.name AS StatName
		FROM ['+@DatabaseName+'].sys.stats st WITH (nolock) INNER JOIN ['+@DatabaseName+'].sys.objects ob
		ON st.object_id = ob.object_id'
		
		IF @Option = 'INDEX'
		BEGIN
			SET @SQL = @SQL + ' INNER JOIN  ['+@DatabaseName+'].sys.indexes ix
					ON st.object_id = ix.object_id
					AND st.name = ix.name'
		END
		
		SET @SQL = @SQL + ' INNER JOIN  ['+@DatabaseName+'].information_schema.tables ist
		    ON ob.name = ist.table_name
		WHERE DATEDIFF(DAY, ISNULL(STATS_DATE(st.object_id, st.stats_id),1), GETDATE()) >  '+ CAST(@MaxDaysOld AS VARCHAR(3)) + '
		AND ob.[type] = ''U'' 
		AND ob.name NOT LIKE ''tbl_imp_%''
		ORDER BY ob.name, st.name
		-- USER_TABLE'


--		PRINT @SQL
		EXEC(@SQL)
		
		FETCH NEXT FROM database_stats INTO @DatabaseName
	END

	CLOSE database_stats
	DEALLOCATE database_stats		

	DECLARE Update_Stats_Statments CURSOR FOR
	SELECT DatabaseName, SchemaName, TableName, StatsName
	FROM ##UpdateStats
	--WHERE DatabaseName = 'TMC_CARLSBERG_UAT'

	OPEN Update_Stats_Statments

	FETCH NEXT FROM Update_Stats_Statments INTO @DatabaseName, @SchemaName, @TableName, @StatsName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		
		SET @SQL = 'USE ['+@DatabaseName +']; UPDATE STATISTICS ['+ @SchemaName + '].[' + @TableName + '] [' + @StatsName + ']' + @SampleSize

--		PRINT @SQL
		
		EXEC(@SQL)

		FETCH NEXT FROM Update_Stats_Statments INTO @DatabaseName, @SchemaName,  @TableName, @StatsName
		
	END	

	CLOSE Update_Stats_Statments
	DEALLOCATE Update_Stats_Statments		


	DROP TABLE ##UpdateStats

	--SELECT  RowNum, ((RowNum+1)/7.0)*7.0, ((RowNum+1)/7)*7, name
	--FROM    #DBStats
	--WHERE ((RowNum+1)/7.0)*7.0 = ((RowNum+1)/7)*7

	DROP TABLE #DBStats
END
