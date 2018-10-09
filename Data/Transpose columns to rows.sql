

-- Transpose columns to rows

-- Solution 1

DECLARE @SQL NVARCHAR(MAX)
 
SELECT @SQL = COALESCE(@SQL + '
FROM AdventureWorks2008.Person.Address 
 UNION ALL
','') + 'SELECT convert(nvarchar(max),' + QUOTENAME(column_name) + ') as Column_Value, ' +
QUOTENAME(Column_Name,'''') + ' as Column_Name'
 FROM AdventureWorks2008.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Address' AND TABLE_SCHEMA = 'Person'
--print @cols
 
 
SET @SQL =' ;with cte as (' + @SQL + '
FROM AdventureWorks2008.Person.Address) 
-- get 10 records per each column
select * from (select *, 
row_number() over (partition by Column_Name order by Column_Value) as row 
from cte) X 
where Row <=10
order by Row, Column_Name'
--print @SQL
 
EXECUTE(@SQL)

-- Hunchback’s (Alejandro Mesa) solution using SQL Server 2008 specific syntax:

USE AdventureWorks2008

SELECT
    C.*
FROM
    (
 SELECT TOP (3)
     AddressID,
     AddressLine1,
     AddressLine2,
     City,
     StateProvinceID,
     PostalCode
 FROM
     Person.Address
 ORDER BY
  ModifiedDate
 ) AS T
 CROSS APPLY
 (
 VALUES
  (AddressID, 'AddressID', CAST(AddressID AS sql_variant)),
  (AddressID, 'AddressLine1', CAST(AddressLine1 AS sql_variant)),
  (AddressID, 'AddressLine2', CAST(AddressLine2 AS sql_variant)),
  (AddressID, 'City', CAST(City AS sql_variant)),
  (AddressID, 'StateProvinceID', CAST(StateProvinceID AS sql_variant)),
  (AddressID, 'PostalCode', CAST(PostalCode AS sql_variant))
 ) AS C(rowident, cn, cv)
ORDER BY
 rowident,
 cn;
GO