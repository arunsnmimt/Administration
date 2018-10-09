	DECLARE @DatabaseName AS VARCHAR(128)
	DECLARE @SQL AS VARCHAR(4000)


	DECLARE database_cur CURSOR FOR
	SELECT  name
	FROM sys.databases db
	WHERE name LIKE 'TMC%'
      AND state_desc = 'ONLINE'
      AND name NOT LIKE 'TMC_Reports%'
      ORDER BY name

	CREATE TABLE ##TrackerEventIDCount
	(Database_Name VARCHAR(128),
	 TrackerEventID_Current  INT)
	


	OPEN database_cur

	FETCH NEXT FROM database_cur INTO @DatabaseName

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @SQL = '
		USE ['+@DatabaseName+']; 

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''dbo.tbl_TrackerEvents'') AND type in (N''U''))
		BEGIN
			INSERT INTO ##TrackerEventIDCount
			SELECT  DB_NAME(DB_ID()),  Ident_Current(''dbo.tbl_TrackerEvents'') AS TrackerEventID_Current
		END'



--		PRINT @SQL
		EXEC(@SQL)
		
		FETCH NEXT FROM database_cur INTO @DatabaseName
	END

	CLOSE database_cur
	DEALLOCATE database_cur	
	
	SELECT * FROM ##TrackerEventIDCount
	
	DROP TABLE ##TrackerEventIDCount



--SELECT  DB_NAME(DB_ID()),  Ident_Current('dbo.tbl_TrackerEvents') AS TrackerEventID_Current