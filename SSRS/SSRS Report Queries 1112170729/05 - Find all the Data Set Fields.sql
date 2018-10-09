-- =============================================================================
-- 05 - Find all the Data Set Fields
-- =============================================================================
-- Once we can get the catalog item contents as XML, we can use SQL Server's
-- support for XQuery to investigate the contents.  To learn more about
-- SQL Server and XQuery check out the SQL Server documentation:
--
-- http://msdn.microsoft.com/en-us/library/ms189075.aspx
-- 
-- This query will use the base data provided by the CatalogContentView and return
-- information about all of the Fields in all of the Data Sets
--
-- A Data Set's fields are exposed through <Field> elements
-- A fields name is found in the "Name" (<Field Name="fieldname" />) attribute
-- 
-- There are two basic types of Fields.
--   • "Data Field"s map to a column returned by the Data Sets command
--     The "DataField" element contains the name of the column the field maps to
--     The "TypeName" element contains the .NET data type of the value
--   • "Calculated Field"s map to an expression
--     the "Value" element contains the VB.NET Expression syntax
--
-- -----------------------------------------------------------------------------
-- History (most recent at top)
-- -----------------------------------------------------------------------------
-- 11/30/2011 - BStateham - Original Script
-- =============================================================================

SELECT 
   ItemID
  ,Name
  ,[Path]
  ,ParentID
  ,[Type]
  ,TypeDescription
  ,ContentXML
  ,ISNULL(DataSet.value('./@Name','nvarchar(1024)'),'Text') AS DataSetName
  ,CAST(DataSet.exist('./*:SharedDataSet') AS bit) AS IsSharedDataSetReference
  ,ISNULL(DataSet.value('(..//*:SharedDataSetReference/text())[1]','nvarchar(1024)'),'') AS SharedDataSetName
  ,ISNULL(DataSet.value('(./*:Query/*:CommandType/text())[1]','nvarchar(1024)'),'Text') AS CommandType 
  ,ISNULL(DataSet.value('(./*:Query/*:CommandText/text())[1]','nvarchar(max)'),'') AS CommandText 
  ,Field.value('@Name','nvarchar(max)') AS FieldName
  ,CASE 
    WHEN Field.exist('./*:DataField') = 1THEN 'Data Field' 
    WHEN Field.exist('./*:Value') = 1THEN 'Calculated Field' 
    ELSE 'Unknown Field Type' END AS FieldType
  ,ISNULL(Field.value('(./*:DataField/text())[1]','nvarchar(max)'),'') AS DataFieldName
  ,ISNULL(Field.value('(./*:TypeName/text())[1]','nvarchar(max)'),'') AS DataFieldDataType -- Note, only Data Fields have TypeName.  Calculated fields won't have a TypeName
  ,ISNULL(Field.value('(./*:Value/text())[1]','nvarchar(max)'),'') AS CalculatedFieldExpression 
FROM ReportQueries.dbo.CatalogContentView AS CCV
--Get all the Query elements (The "*:" ignores any xml namespaces) 
CROSS APPLY CCV.ContentXML.nodes('//*:DataSet') DataSets(DataSet)
CROSS APPLY DataSets.DataSet.nodes('//*:Fields/*:Field') Fields(Field)
--The outer query can be VERY expensive and time consuming if you don't limit the results...
--WHERE ItemID = 'A1B8D6EF-78B7-4C35-83D1-FE9C579E42A5'

--Add a WHERE clause if desired to limit the results to a specific item or subset of itmes
--WHERE Path='/FolderName/ReportName'
--WHERE Name='ReportName'
--WHERE ItemID='EC10F281-2A7D-43D6-9D9E-CF51C4CFBCB8'