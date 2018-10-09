	DECLARE @DataBaseName AS VARCHAR(500) 
	DECLARE @DataBaseNameInclude VARCHAR(200)
	DECLARE @DataBaseNameIncludeList VARCHAR(4000)
	DECLARE @DataBaseNameExcludeList VARCHAR(4000)
	DECLARE @DataBaseNameExclude VARCHAR(200)
	DECLARE @BackupPath AS VARCHAR(100)
	DECLARE @Compression AS BIT 
	DECLARE @CopyOnly AS BIT
	DECLARE @BackupType AS TINYINT

	DECLARE @DateTimeString AS VARCHAR(50)
	DECLARE @BackupFileName AS VARCHAR(1000)
	DECLARE @SQL AS VARCHAR(2000)
	DECLARE @Options AS VARCHAR(1000)
	DECLARE @BackupStatement VARCHAR(128)
	
	DECLARE @pos INT
	DECLARE @piece NVARCHAR(500)
	DECLARE @DatabaseIncludeList TABLE(DatabaseName NVARCHAR(512))
	DECLARE @DatabaseExcludeList TABLE(DatabaseName NVARCHAR(512))
	

/* Parameters */
-- Include
	SET @DataBaseNameInclude = ''  -- 	'%%' = All, '' = Nothing
	SET @DataBaseNameIncludeList = 'TMC_INTERSERVE_MG_CC, TMC_Reports_Interserve_MG_CC'   -- Delimited by comma
-- Exclude
	SET @DataBaseNameExclude = ''    -- 	'%%' = All, '' = Nothing
	SET @DataBaseNameExcludeList = 'model, distribution'   -- Delimited by comma e.g (model, distribution)
-- Options	
	SET @BackupPath	= 'F:\Backup\PreDelete'
	SET @Compression = 1
	SET @BackupType = 1   -- (1 = Full)  (2 = Diff)  (3 = Log)
	SET @CopyOnly = 1

/* Parameters */

	SET NOCOUNT ON

	IF RIGHT(RTRIM(@DataBaseNameIncludeList),1) <> ','
	   SELECT @DataBaseNameIncludeList = @DataBaseNameIncludeList  + ','

	SELECT @pos =  PATINDEX('%,%' , @DataBaseNameIncludeList)
	WHILE @pos <> 0 
	BEGIN
	 SELECT @piece = LEFT(@DataBaseNameIncludeList, (@pos-1))

	 --you now have your string in @piece
	 INSERT INTO @DatabaseIncludeList(DatabaseName) VALUES ( CAST(@piece AS NVARCHAR(512)))

	 SELECT @DataBaseNameIncludeList = LTRIM(STUFF(@DataBaseNameIncludeList, 1, @pos, ''))
	 SELECT @pos =  PATINDEX('%,%' , @DataBaseNameIncludeList)
	END


	IF RIGHT(RTRIM(@DataBaseNameExcludeList),1) <> ','
	   SELECT @DataBaseNameExcludeList = @DataBaseNameExcludeList  + ','

	SELECT @pos =  PATINDEX('%,%' , @DataBaseNameExcludeList)
	WHILE @pos <> 0 
	BEGIN
	 SELECT @piece = LEFT(@DataBaseNameExcludeList, (@pos-1))

	 --you now have your string in @piece
	 INSERT INTO @DatabaseExcludeList(DatabaseName) VALUES ( CAST(@piece AS NVARCHAR(512)))

	 SELECT @DataBaseNameExcludeList = LTRIM(STUFF(@DataBaseNameExcludeList, 1, @pos, ''))
	 SELECT @pos =  PATINDEX('%,%' , @DataBaseNameExcludeList)
	END


	SET NOCOUNT OFF
	
	SET @Options = ' WITH INIT'
	SET @BackupStatement = 'BACKUP DATABASE '
	
	IF @Compression = 1 AND  @BackupType <> 3
	BEGIN
		SET @Options = @Options + ', COPY_ONLY'
	END

	IF @Compression = 1
	BEGIN
		SET @Options = @Options + ', COMPRESSION'
	END
	
	IF @BackupType = 2
	BEGIN
		SET @Options =  @Options + ', DIFFERENTIAL'
	END
	
	IF @BackupType = 3
	BEGIN
		SET @BackupStatement = 'BACKUP LOG '
	END
	
	IF RIGHT(@BackupPath,1) <> '\' 
	BEGIN
		SET @BackupPath = @BackupPath + '\'
	END
		
--		SET @BackupName = @DatabaseName + '_backup_' + @DateTimeString  

--		SELECT @BackupFileName, @BackupName
--	EXECUTE master.dbo.xp_create_subdir @BackupPath
	
	DECLARE DatabaseCursor INSENSITIVE CURSOR  FOR  
		SELECT name FROM master.sys.databases
		WHERE STATE = 0 -- Online
		AND is_read_only = 0 -- Read/Write
		AND name <> 'ReportServerTempDB'
		AND name <> 'tempdb'
		AND (name LIKE @DataBaseNameInclude OR name = @DataBaseNameInclude OR name IN (SELECT * FROM @DatabaseIncludeList))
		AND (name NOT LIKE @DataBaseNameExclude AND name <> @DataBaseNameExclude AND name NOT IN (SELECT * FROM @DatabaseExcludeList) )
		AND recovery_model <=  5 - @BackupType 
		--WHERE STATE = 6 -- Offline
		ORDER BY name
  
	OPEN DatabaseCursor

	FETCH NEXT FROM DatabaseCursor INTO @DatabaseName  

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @DateTimeString = REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(50), GETDATE(), 120),'-',''),' ','_'),'.','_'),':','') 
		SET @BackupFileName = @BackupPath + @DatabaseName +  '_(FULL)_' +  @DateTimeString + '.bak' 

		SET @SQL = @BackupStatement + '[' + @DatabaseName + '] TO DISK = ''' + @BackupFileName + '''' + @Options
		
		PRINT @SQL
--		EXEC(@SQL)


		FETCH NEXT FROM DatabaseCursor INTO @DatabaseName  		

	END
	
	CLOSE DatabaseCursor
	DEALLOCATE DatabaseCursor		

