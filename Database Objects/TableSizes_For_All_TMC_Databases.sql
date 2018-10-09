
--A procedure level temp table to store the results
CREATE TABLE #TempTable
(
	DBName VARCHAR(128),
    tableName VARCHAR(100),
    numberofRows VARCHAR(100),
    reservedSize VARCHAR(50),
    dataSize VARCHAR(50),
    indexSize VARCHAR(50),
    unusedSize VARCHAR(50)
)

DECLARE @command VARCHAR(4000)


SELECT @command = 'USE ?

IF  EXISTS (SELECT DB_NAME(DB_ID()) WHERE DB_NAME(DB_ID()) LIKE ''TMC%'')
BEGIN

	DECLARE @TableName VARCHAR(100)    --For storing values in the cursor

	--Cursor to get the name of all user tables from the sysobjects listing
	DECLARE tableCursor CURSOR
	FOR 
	select [name]
	from dbo.sysobjects 
	where  OBJECTPROPERTY(id, N''IsUserTable'') = 1
	AND [name] = ''tbl_IncaStatus''
	FOR READ ONLY


	--Open the cursor
	OPEN tableCursor

	--Get the first table name from the cursor
	FETCH NEXT FROM tableCursor INTO @TableName

	--Loop until the cursor was not able to fetch
	WHILE (@@Fetch_Status >= 0)
	BEGIN
		--Dump the results of the sp_spaceused query to the temp table
		INSERT #TempTable (tableName, numberofRows, reservedSize, dataSize,indexSize,unusedSize)
			EXEC sp_spaceused @TableName
			
		--Get the next table name
		FETCH NEXT FROM tableCursor INTO @TableName
	END

	--Get rid of the cursor
	CLOSE tableCursor
	DEALLOCATE tableCursor

	UPDATE #TempTable 
	  SET DBName = DB_NAME(DB_ID()) 
	WHERE DBName IS NULL

END'

--PRINT @command

EXEC sp_MSforeachdb @command 


--Select all records so we can use the reults
SELECT * 
FROM #TempTable
ORDER BY tableName

--Final cleanup!
DROP TABLE #TempTable
