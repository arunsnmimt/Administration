/*  ## 1 ##
CREATE TABLE #TempTable
(
	DBName VARCHAR(128),
    NoRecs INT
)
*/


CREATE TABLE #TempTable
(
	DBName VARCHAR(128),
--	TableName VARCHAR(128),
	NoRecs INT
	--DimDepartmentCount INT,
 --   vwDepartmentCount INT
)


DECLARE @command VARCHAR(4000)


SELECT @command = 'USE ?

IF  EXISTS (SELECT DB_NAME(DB_ID()) WHERE DB_NAME(DB_ID()) LIKE ''TMC%'' AND DB_NAME(DB_ID()) NOT LIKE ''TMC_Reports%''  )
BEGIN

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[tbl_AccountFlag]'') AND type in (N''U''))
	BEGIN
		INSERT #TempTable (DBName, NoRecs)
		SELECT DB_NAME(DB_ID()) AS DBName, COUNT(*) AS No_Recs FROM tbl_AccountFlag WITH (nolock) 
	END	
END'

--PRINT @command

EXEC sp_MSforeachdb @command 


SELECT * FROM #TempTable

DROP TABLE #TempTable

/*  ## 1 ##

SELECT @command = 'USE ?

IF  EXISTS (SELECT DB_NAME(DB_ID()) WHERE DB_NAME(DB_ID()) LIKE ''TMC%'' AND DB_NAME(DB_ID()) NOT LIKE ''TMC_Reports%''  )
BEGIN

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[tbl_ConfigHistory]'') AND type in (N''U''))
	BEGIN
		INSERT #TempTable (DBName, NoRecs)
		SELECT DB_NAME(DB_ID()) AS DBName, COUNT(*) AS No_Recs FROM tbl_ConfigHistory WITH (nolock) WHERE PropertyName IN (''LastSpeedingEventProcessed'', ''LastAlert'', ''lastCleardown'', ''lastBackup'')
	END	
END'

*/


/*  ## 2 ##

SELECT @command = 'USE ?

IF  EXISTS (SELECT DB_NAME(DB_ID()) WHERE DB_NAME(DB_ID()) LIKE ''TMC%'' AND DB_NAME(DB_ID()) NOT LIKE ''TMC_Reports%''  )
BEGIN

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[tbl_AccountFlag]'') AND type in (N''U''))
	BEGIN
		INSERT #TempTable (DBName, NoRecs)
		SELECT DB_NAME(DB_ID()) AS DBName, COUNT(*) AS No_Recs FROM tbl_AccountFlag WITH (nolock) 
	END	
END'

*/

/* ## 3 ##

SELECT @command = 'USE ?

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF  EXISTS (SELECT DB_NAME(DB_ID()) WHERE DB_NAME(DB_ID()) LIKE ''TMC_Reports%''  )
BEGIN

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[tbl_DimDepartment]'') AND type in (N''U''))
	BEGIN
		INSERT #TempTable (DBName, DimDepartmentCount, vwDepartmentCount)
		SELECT DB_NAME(DB_ID()) AS DBName, COUNT(1) AS DimDepartment
		,(SELECT COUNT(1) FROM vw_department) AS department
		FROM tbl_DimDepartment
	END	
END'

*/