DECLARE @MaxDaysOld INT
DECLARE @SamplePercent INT
DECLARE @SampleType nvarchar(50)

SET @MaxDaysOld = 3
SET @SamplePercent = 50 --25
SET @SampleType = 'PERCENT' --'ROWS'

--BEGIN TRY
----DROP TABLE #OldStats
--END TRY
--BEGIN CATCH SELECT 1 END CATCH

SELECT
RowNum = ROW_NUMBER() OVER (ORDER BY ISNULL(STATS_DATE(st.object_id, st.stats_id),1))
,TableName = OBJECT_SCHEMA_NAME(st.object_id) + '.' + OBJECT_NAME(st.object_id)
,StatName = st.name
,StatDate = ISNULL(STATS_DATE(st.object_id, st.stats_id),1)
INTO #OldStats
FROM sys.stats st WITH (nolock) INNER JOIN sys.objects ob
ON st.object_id = ob.object_id
WHERE DATEDIFF(DAY, ISNULL(STATS_DATE(st.object_id, st.stats_id),1), GETDATE()) > @MaxDaysOld
AND ob.[type] = 'U' -- USER_TABLE
--AND OBJECT_SCHEMA_NAME(st.object_id) <> 'sys'
ORDER BY ROW_NUMBER() OVER (ORDER BY ISNULL(STATS_DATE(st.object_id, st.stats_id),1))

DECLARE @MaxRecord INT
DECLARE @CurrentRecord INT
DECLARE @TableName nvarchar(255)
DECLARE @StatName nvarchar(255)
DECLARE @SQL nvarchar(MAX)
DECLARE @SampleSize nvarchar(100)

SET @MaxRecord = (SELECT MAX(RowNum) FROM #OldStats)
SET @CurrentRecord = 1
SET @SQL = ''
SET @SampleSize = ISNULL(' WITH SAMPLE ' + CAST(@SamplePercent AS nvarchar(20)) + ' ' + @SampleType,N'')

WHILE @CurrentRecord <= @MaxRecord
BEGIN

	SELECT
	@TableName = os.TableName
	,@StatName = os.StatName
	FROM #OldStats os
	WHERE RowNum = @CurrentRecord

	SET @SQL = N'UPDATE STATISTICS ' + @TableName + ' [' + @StatName + ']' + @SampleSize

	PRINT @SQL

--	EXEC sp_executesql @SQL

	SET @CurrentRecord = @CurrentRecord + 1

END

SELECT  *
FROM  #OldStats  

DROP TABLE #OldStats

--(2628 row(s) affected)
