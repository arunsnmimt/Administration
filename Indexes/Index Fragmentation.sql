USE Admin_DBA

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
	SP Name:  Get_Currently_Running_Jobs
	Author:   Mike Giles
	Date:     12 Sep 2012
	DB(s):    Admin_DBA

	Purpose:
	========
	Reads the extended sp xp_sqlagent_enum_jobs to determine a list of 
	current jobs.

	Changes
	=======
	Date			- Changed By
*************************************************************************/
CREATE PROCEDURE [dbo].[sp_Fragmentation_Levels]  

AS  

BEGIN
	SET NOCOUNT ON  
	


	DECLARE @SQL VARCHAR(2000)
	DECLARE @DatabaseName VARCHAR(128)

	IF NOT EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Fragmentation_Levels]') AND TYPE IN (N'U'))
	BEGIN
		CREATE TABLE [dbo].[Fragmentation_Levels](
			[DatabaseName] [NVARCHAR](128) NULL,
			[TableName] [NVARCHAR](128) NULL,
			[IndexName] [sysname] NULL,
			[IndexType] [NVARCHAR](60) NULL,
			[avg_fragmentation_in_percent] [FLOAT] NULL,
			[page_count] [BIGINT] NULL,
			[Datetime_Checked] DATETIME
		) ON [PRIMARY]
	END


	DECLARE DatabaseCursor CURSOR  FOR  
	SELECT name
	FROM master.sys.databases d
	WHERE state_desc = 'ONLINE'
	AND name LIKE 'TMC_%'
	ORDER BY name
	--AND name = 'TMC_BSKYB_UAT'

		

	OPEN DatabaseCursor

	FETCH NEXT FROM DatabaseCursor INTO @DatabaseName

	WHILE @@FETCH_STATUS = 0
	BEGIN	

		SET @SQL = '
		USE ['+ @DatabaseName + '];

		INSERT INTO Admin_DBA.dbo.Fragmentation_Levels
		SELECT ''' + @DatabaseName + ''' AS DatabaseName,
		 OBJECT_NAME(ind.OBJECT_ID) AS TableName,
		ind.name AS IndexName, indexstats.index_type_desc AS IndexType, 
		indexstats.avg_fragmentation_in_percent, page_count, GETDATE()
		FROM sys.dm_db_index_physical_stats(DB_ID(''' + @DatabaseName + '''), NULL, NULL, NULL, NULL) indexstats
		INNER JOIN sys.indexes ind 
		ON ind.object_id = indexstats.object_id
		AND ind.index_id = indexstats.index_id
		WHERE indexstats.avg_fragmentation_in_percent > 30  
		AND indexstats.index_type_desc <> ''HEAP''
		AND page_count > 1000
		ORDER BY OBJECT_NAME(ind.OBJECT_ID) 
	'
		EXEC(@SQL)
		
		FETCH NEXT FROM DatabaseCursor INTO @DatabaseName
	END

	CLOSE DatabaseCursor
	DEALLOCATE DatabaseCursor
END


/*
SELECT DB_NAME() AS DatabaseName, OBJECT_NAME(ind.OBJECT_ID) AS TableName,
ind.name AS IndexName, indexstats.index_type_desc AS IndexType, 
indexstats.avg_fragmentation_in_percent, page_count, 'USE ' + DB_NAME() + '; ALTER INDEX ' + ind.name + ' ON ' + OBJECT_NAME(ind.OBJECT_ID) + ' REBUILD' AS Rebuild_Command
INTO Fragmentation_Above_30percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
INNER JOIN sys.indexes ind 
ON ind.object_id = indexstats.object_id
AND ind.index_id = indexstats.index_id
WHERE indexstats.avg_fragmentation_in_percent > 30  --You can specify the percent as you want
AND indexstats.index_type_desc <> 'HEAP'
AND page_count > 1000
ORDER BY OBJECT_NAME(ind.OBJECT_ID) 
*/