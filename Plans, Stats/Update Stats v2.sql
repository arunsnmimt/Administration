--SELECT 
--RowNum = ROW_NUMBER() OVER (ORDER BY name)
--, name
--INTO #DBStats
--FROM sys.databases db
--WHERE name LIKE 'TMC%'
-- AND state_desc = 'ONLINE'
 



DECLARE @MaxDaysOld INT
DECLARE @SamplePercent INT
DECLARE @SampleType nvarchar(50)
DECLARE @SampleSize nvarchar(100)
--DECLARE @RowCount AS SMALLINT
--DECLARE @DBsPerDay AS DECIMAL(9,3)
DECLARE @DayofWeek AS TINYINT
DECLARE @DatabaseName AS VARCHAR(128)
DECLARE @SQL AS VARCHAR(4000)
DECLARE @TableName AS VARCHAR(128)
DECLARE @StatsName AS VARCHAR(128)
DECLARE @Option AS VARCHAR(10)

SET @DayofWeek =  DATEPART(DW, GETDATE() - 2) 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Database_Stats_Order]') AND type in (N'U'))
    AND @DayofWeek = 1
BEGIN
	DROP TABLE [dbo].[Database_Stats_Order]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Database_Stats_Order]') AND type in (N'U'))
BEGIN
	 SELECT 
	 RowNum = ROW_NUMBER() OVER (ORDER BY  (SUM(mf.size) * 8)/1024 DESC),
--	RowNum = ROW_NUMBER() OVER (ORDER BY RAND() DESC),
	 db.name,
	 SUM(mf.size * 8)/1024 AS DB_Size
	 INTO  Database_Stats_Order
	FROM sys.databases db 
	INNER JOIN sys.master_files mf
	ON db.database_id = mf.database_id
	WHERE db.name LIKE 'TMC%'
	 AND db.state_desc = 'ONLINE'
	GROUP BY  db.name
END


SET @MaxDaysOld = 7
SET @SamplePercent = 35 --25
SET @SampleType = 'PERCENT' --'ROWS'
--SET @Option = 'INDEX'

SET @SampleSize = ISNULL(' WITH SAMPLE ' + CAST(@SamplePercent AS nvarchar(20)) + ' ' + @SampleType,N'')


SET @DatabaseName = DB_NAME(DB_ID())

CREATE TABLE ##UpdateStats (
DatabaseName VARCHAR(128),
TableName    VARCHAR(128),
StatsName	 VARCHAR(128))



	SET @SQL = 'USE ['+@DatabaseName+']; 
	INSERT INTO ##UpdateStats
	SELECT ''' + @DatabaseName +  ''' AS DatabaseName, 
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
	
	SET @SQL = @SQL + ' WHERE DATEDIFF(DAY, ISNULL(STATS_DATE(st.object_id, st.stats_id),1), GETDATE()) >  '+ CAST(@MaxDaysOld AS VARCHAR(3)) + '
	AND ob.[type] = ''U'' -- USER_TABLE'

--	PRINT @SQL

	EXEC(@SQL)
	


DECLARE Update_Stats_Statments CURSOR FOR
SELECT DatabaseName, TableName, StatsName
FROM ##UpdateStats
ORDER BY DatabaseName, TableName, StatsName

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


DROP TABLE ##UpdateStats



/*
USE Admin_DBA

DECLARE @Adjust INT
DECLARE @DayofWeek AS TINYINT

SET @Adjust = -2
SET @DayofWeek =  DATEPART(DW, GETDATE() + @Adjust) 

PRINT @DayofWeek

SELECT  *
FROM    Database_Stats_Order
WHERE ((RowNum+@DayofWeek)/7.0)*7.0 = ((RowNum+@DayofWeek)/7)*7

SET @DayofWeek =  DATEPART(DW, GETDATE() + 1 + @Adjust) 

SELECT  *
FROM    Database_Stats_Order
WHERE ((RowNum+@DayofWeek)/7.0)*7.0 = ((RowNum+@DayofWeek)/7)*7

SET @DayofWeek =  DATEPART(DW, GETDATE() + 2 + @Adjust) 

SELECT  *
FROM    Database_Stats_Order
WHERE ((RowNum+@DayofWeek)/7.0)*7.0 = ((RowNum+@DayofWeek)/7)*7

SET @DayofWeek =  DATEPART(DW, GETDATE() + 3 + @Adjust) 

SELECT  *
FROM    Database_Stats_Order
WHERE ((RowNum+@DayofWeek)/7.0)*7.0 = ((RowNum+@DayofWeek)/7)*7

SET @DayofWeek =  DATEPART(DW, GETDATE() + 4 + @Adjust) 

SELECT  *
FROM    Database_Stats_Order
WHERE ((RowNum+@DayofWeek)/7.0)*7.0 = ((RowNum+@DayofWeek)/7)*7

SET @DayofWeek =  DATEPART(DW, GETDATE() + 5 + @Adjust) 

SELECT  *
FROM    Database_Stats_Order
WHERE ((RowNum+@DayofWeek)/7.0)*7.0 = ((RowNum+@DayofWeek)/7)*7

SET @DayofWeek =  DATEPART(DW, GETDATE() + 6 + @Adjust) 

SELECT  *
FROM    Database_Stats_Order
WHERE ((RowNum+@DayofWeek)/7.0)*7.0 = ((RowNum+@DayofWeek)/7)*7

*/


--DROP TABLE #DBStats