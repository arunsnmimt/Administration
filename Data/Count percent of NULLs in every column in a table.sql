USE AdventureWorks2008
 
DECLARE  @TotalCount DECIMAL(10,2), 
         @SQL        NVARCHAR(MAX) 
 
SELECT @TotalCount = COUNT(* ) 
FROM   [Production].[Product] 
 
SELECT @SQL = COALESCE(@SQL + ', ','SELECT ') + CASE 
                                                  WHEN IS_NULLABLE = 'NO' THEN '0' 
                                                  ELSE 'cast(sum (case when ' + QUOTENAME(column_Name) + ' IS NULL then 1 else 0 end)/@TotalCount*100.00 as decimal(10,2)) '
                                                END + ' as [' + column_Name + ' NULL %] ' 
FROM   INFORMATION_SCHEMA.COLUMNS 
WHERE  TABLE_NAME = 'Product' 
       AND TABLE_SCHEMA = 'Production' 
 
SET @SQL = 'set @TotalCount = NULLIF(@TotalCount,0)  ' + @SQL + ' FROM [AdventureWorks2008].Production.Product' 
 
--print @SQL 
EXECUTE SP_EXECUTESQL 
  @SQL , 
  N'@TotalCount decimal(10,2)' , 
  @TotalCount