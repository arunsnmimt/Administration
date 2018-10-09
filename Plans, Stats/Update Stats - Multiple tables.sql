USE [Admin_DBA]


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
	DECLARE @TablesPerDay AS DECIMAL(9,3)
	DECLARE @DayofWeek AS TINYINT
	DECLARE @DatabaseName AS VARCHAR(128)
	DECLARE @SQL AS VARCHAR(4000)
	DECLARE @TableName AS VARCHAR(128)
	DECLARE @StatsName AS VARCHAR(128)
	SET @SampleSize = ISNULL(' WITH SAMPLE ' + CAST(@SamplePercent AS nvarchar(20)) + ' ' + @SampleType,N'')

--	DROP TABLE ##UpdateStats

	CREATE TABLE ##UpdateStats (
--	RowNum INT  IDENTITY(1,1) NOT NULL,
	DatabaseName VARCHAR(128),
	TableName    VARCHAR(128),
	ObjectID	INT,
	StatsName	 VARCHAR(128),
	LastUpdated	DATETIME)
	
	
	CREATE TABLE ##UpdateStatsTables (
	RowNum INT  IDENTITY(1,1) NOT NULL,
	DatabaseName VARCHAR(128),
	TableName    VARCHAR(128))--,
--	ObjectID	INT)

	DECLARE database_cur CURSOR FOR
		SELECT 
		   name
		FROM sys.databases db 
		WHERE name LIKE 'TMC%'
		 AND state_desc = 'ONLINE'

	OPEN database_cur

	FETCH NEXT FROM database_cur INTO @DatabaseName

	WHILE @@FETCH_STATUS = 0
	BEGIN	 

		SET @SQL = 'USE ['+@DatabaseName+']; 
		INSERT INTO ##UpdateStats (DatabaseName,  TableName, ObjectID, StatsName, LastUpdated)
		SELECT ''' + @DatabaseName +  ''' AS DatabaseName, 
		ob.name AS TableName,
		ob.object_id,
		st.name AS StatName,
		STATS_DATE(st.object_id, st.stats_id)
		FROM ['+@DatabaseName+'].sys.stats st WITH (nolock) INNER JOIN ['+@DatabaseName+'].sys.objects ob
		ON st.object_id = ob.object_id'
		
		IF @Option = 'INDEX'
		BEGIN
			SET @SQL = @SQL + ' INNER JOIN  ['+@DatabaseName+'].sys.indexes ix
					ON st.object_id = ix.object_id
					AND st.name = ix.name'
		END
		
		SET @SQL = @SQL + '
		AND ob.[type] = ''U'' 
		ORDER BY ob.name, st.name
		-- USER_TABLE'
		
		
		EXEC(@SQL)
		
		SET @SQL = 'USE ['+@DatabaseName+']; 
					INSERT INTO ##UpdateStatsTables (DatabaseName,  TableName)
					SELECT DISTINCT
					''' + @DatabaseName +  ''' AS DatabaseName, 
					t.NAME AS TableName
				FROM 
					sys.tables t INNER JOIN sys.indexes i 
					ON t.OBJECT_ID = i.object_id
					INNER JOIN sys.partitions p 
					ON i.object_id = p.OBJECT_ID 
					AND i.index_id = p.index_id
					INNER JOIN sys.allocation_units a 
					ON p.partition_id = a.container_id
				WHERE t.NAME NOT LIKE ''dt%'' 
				  AND t.is_ms_shipped = 0
				  AND i.OBJECT_ID > 255
				  AND p.rows > 1000'
		
		
		--INSERT INTO ##UpdateStatsTables (DatabaseName,  TableName)
		--SELECT ''' + @DatabaseName +  ''' AS DatabaseName, 
		--ob.name AS TableName
		--FROM ['+@DatabaseName+'].sys.objects ob 
		--WHERE ob.[type] = ''U'' 
		--ORDER BY ob.name		'
		
		
		EXEC(@SQL)
		
		FETCH NEXT FROM database_cur INTO @DatabaseName
	END

	CLOSE database_cur
	DEALLOCATE database_cur			 



	SET @RowCount = (SELECT COUNT(*)
					   FROM ##UpdateStatsTables)
					   

	SET @TablesPerDay = @RowCount / 7.000
	SET @DayofWeek =  DATEPART(DW, GETDATE())
	
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+1)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+2)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+3)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+4)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+5)
	--SET @DayofWeek =  DATEPART(DW, GETDATE()+6)
	

	--DECLARE Update_Stats_Statments CURSOR FOR
	--SELECT DatabaseName, TableName, StatsName
	--FROM    ##UpdateStats
	DECLARE Update_Stats_Statments CURSOR FOR
	SELECT UST.DatabaseName, UST.TableName, StatsName
	FROM    ##UpdateStatsTables UST INNER JOIN ##UpdateStats US
	ON UST.DatabaseName = US.DatabaseName
	AND UST.TableName = US.TableName
	WHERE UST.RowNum BETWEEN ROUND(((@DayofWeek - 1) * @TablesPerDay) + 1 ,0, 1) AND ROUND((@DayofWeek * @TablesPerDay) + .99 ,0 ,1)
--	AND DATEDIFF(DAY, ISNULL(US.LastUpdated,1), GETDATE()) >  CAST(@MaxDaysOld AS VARCHAR(3)) 	--WHERE DatabaseName = 'TMC_SPIRIT_26436'

	OPEN Update_Stats_Statments

	FETCH NEXT FROM Update_Stats_Statments INTO @DatabaseName, @TableName, @StatsName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @SQL = 'USE ['+@DatabaseName +']; UPDATE STATISTICS [' + @TableName + '] [' + @StatsName + ']' + @SampleSize

		PRINT @SQL
		
	--	EXEC(@SQL)

		FETCH NEXT FROM Update_Stats_Statments INTO @DatabaseName, @TableName, @StatsName
		
	END	

	CLOSE Update_Stats_Statments
	DEALLOCATE Update_Stats_Statments		

	--SELECT  *
	--FROM  ##UpdateStats
	--ORDER BY DatabaseName, TableName
	
	--SELECT  *
	--FROM ##UpdateStatsTables
	--ORDER BY DatabaseName, TableName     

	DROP TABLE ##UpdateStats
	DROP TABLE ##UpdateStatsTables





