	SELECT	tb.Name as [Table Name],
			CASE WHEN ex.name = 'Description' THEN ex.value ELSE '' END AS Description,
			CASE WHEN ex.name = 'Updated By' THEN ex.value ELSE '' END AS Updated_By 
--	SELECT tb.name, ex.name, ex.value
	FROM sys.extended_properties ex INNER JOIN sys.tables tb
	ON ex.major_id = tb.object_id
	WHERE ex.name <> 'Last Updated/Populated'
	ORDER BY tb.Name



--where name != 'MS_Description'  
----	WHERE OBJECTPROPERTY(c.object_id, 'IsMsShipped')=0  
----	AND ex.name is not null
--
--select *
--from 
--sys.tables

	DECLARE @SQL NVARCHAR(4000)  
	DECLARE @DatabaseName sysname  

	SET @DatabaseName = 'Processed_Data'
 
	SET @SQL = '  	SELECT	tb.Name as [Table Name],
						  CASE WHEN ex.name = ''Description'' THEN ex.value ELSE '''' END AS Description 
							FROM [' + @DatabaseName + '].sys.extended_properties ex INNER JOIN [' + @DatabaseName + '].sys.tables tb
							ON ex.major_id = tb.object_id
							WHERE ex.name <> ''Last Updated/Populated''
							ORDER BY tb.Name'

	EXEC(@SQL)