DECLARE @login VARCHAR(30) 

SET @login = 'devview'
/*
Included Object Types are: 
	P - Stored Procedure 
	V - View 
	FN - SQL scalar-function
	TR - Trigger 
	IF - SQL inlined table-valued function
	TF - SQL table-valued function
	U - Table (user-defined)
*/ 
SET NOCOUNT ON 

--CREATE TABLE #runSQL
--(runSQL VARCHAR(2000) NOT NULL) 

--Declare @execSQL varchar(2000), @login varchar(30), @space char (1), @TO char (2) 
--DECLARE @execSQL VARCHAR(2000), @space CHAR (1), @TO CHAR (2) 
DECLARE @SQL VARCHAR(4000)


--SET @to = 'TO'
--SET @execSQL = 'Grant View Definition ON ' 
SET @login = REPLACE(REPLACE (@login, '[', ''), ']', '')
SET @login = '[' + @login + ']'
--SET @space = ' '


--INSERT INTO #runSQL 
DECLARE view_def CURSOR FOR 
SELECT 'GRANT VIEW DEFINITION ON '  + SCHEMA_NAME(SCHEMA_ID) + '.' + [name] + ' TO ' + @login 
FROM sys.all_objects s 
WHERE TYPE IN ('P', 'V', 'FN', 'TR', 'IF', 'TF', 'U') 
AND is_ms_shipped = 0 
ORDER BY s.type, s.name 

OPEN view_def

FETCH NEXT FROM view_def INTO @SQL

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @SQL
--	EXEC(@SQL)
	FETCH NEXT FROM view_def INTO @SQL
END

CLOSE view_def;
DEALLOCATE view_def;

--SET @execSQL = '' 

--Execute_SQL: 

--SET ROWCOUNT 1 

--SELECT @execSQL = runSQL FROM #runSQL

--PRINT @execSQL --Comment out if you don't want to see the output

--EXEC (@execSQL)

--DELETE FROM #runSQL WHERE runSQL = @execSQL

--IF EXISTS (SELECT * FROM #runSQL) 
--   GOTO Execute_SQL 

--SET ROWCOUNT 0

--DROP TABLE #runSQL  