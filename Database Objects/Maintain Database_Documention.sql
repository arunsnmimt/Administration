DECLARE @TableName 	VARCHAR(100)
DECLARE @TableID	INTEGER
DECLARE @Count		INTEGER

DECLARE Table_Cur CURSOR FOR

SELECT	Name,
		[id]
FROM 	dbo.sysobjects
WHERE 	xtype = 'U'
ORDER BY Name



OPEN Table_Cur

FETCH NEXT FROM Table_Cur INTO @TableName, @TableID	


WHILE @@Fetch_Status = 0
BEGIN
	SET @Count = (SELECT COUNT(*)
			  		FROM dbo.Database_Documention
				  WHERE	[ID] = @TableID)

	IF @Count = 0
	BEGIN
		INSERT INTO dbo.Database_Documention 
			([ID],Table_Name)
		VALUES (@TableID,@TableName)
	END
	


	FETCH NEXT FROM Table_Cur INTO @TableName, @TableID	

END

CLOSE Table_Cur
DEALLOCATE Table_Cur

