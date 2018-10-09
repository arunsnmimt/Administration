-- =============================================================================
-- 06 - Determine Fields Actually Used
-- =============================================================================
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- WARNING:  THIS QUERY IS EXPENSIVE!!! It took my SQL Server instance two
-- two seconds just to come up with the PLAN, and my plan has an estimated 
-- cost of 4,394,660 units.  No joke.  I absolutely do not recommend running
-- this on a production server, nor do I recommend running it on all 
-- objects in the ReportServer.dbo.Catalog table at once.  Make sure to 
-- use the WHERE Clause in the "DataSetFields" CTE to limit the number of 
-- reports that are processed by this query (Using a WHERE clause to limit 
-- the processing to a single ItemID helps performance significantly)
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--
-- This query builds on the list of fields found in the 
-- "05 - Find all the Data Set Fields.sql" script and attempts to determine
-- if the field is actually used somewhere in the report.  
-- 
-- To do this the query checks the Report's XML for the existence of a 
-- string in the format of "Fields!FieldName" (where FieldName is the 
-- current field being investigated).  If the field were used in a report
-- it would be as part of a VB.NET expression that might look something
-- like:
-- 
--   =Fields!FieldName.value
--
-- However, the field might be accessed for something other than it's value
-- property (in the case of a field returned by an MDX query) or it might 
-- be used in the middle of a more complex expression.  Therefore, the
-- script just searches just for the "Fields!FieldName" text to which will
-- always be in the expression regardless of how the field is used.  
--
-- It uses the XQuery concat function to combine the "Fields!" literal
-- the the current value in the sql FieldName column:
-- 
--   concat("Fields!",sql:column("FieldName"))
--
-- It then uses the concatenated string as the argument of a contains()
-- XQuery function call on each of the <Body ... />, <PageHeader ... /> and 
-- <PageFooter ... /> elements to see if the string exists in any text() node
-- within those elements:
--
--   ContentXML.exist('//*:Body//text()[contains(.,concat("Fields!",sql:column("FieldName")))]') AS IsUsedInBody
--   ContentXML.exist('//*:PageHeader//text()[contains(.,concat("Fields!",sql:column("FieldName")))]') AS IsUsedInPageHeader
--   ContentXML.exist('//*:PageFooter//text()[contains(.,concat("Fields!",sql:column("FieldName")))]') AS IsUsedInPageFooter--
-- 
-- NOTE: This query isn't exactly precise.  The VB.Net expressions contain only
-- the field name, and not the name of the data set that the field is from. 
-- If a report contains two datasets, and there is a field with same name in 
-- each dataset, then they will both report as being used even if only one of 
-- them actually is.  If all field names are unique though, then this won't be 
-- a problem.
--
-- -----------------------------------------------------------------------------
-- History (most recent at top)
-- -----------------------------------------------------------------------------
-- 11/30/2011 - BStateham - Original Script
-- =============================================================================

WITH DataSetFields AS
(
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
)
SELECT
   DSF.*
  ,ContentXML.exist('//*:Body//text()[contains(.,concat("Fields!",sql:column("FieldName")))]') AS IsUsedInBody
  ,ContentXML.exist('//*:PageHeader//text()[contains(.,concat("Fields!",sql:column("FieldName")))]') AS IsUsedInPageHeader
  ,ContentXML.exist('//*:PageFooter//text()[contains(.,concat("Fields!",sql:column("FieldName")))]') AS IsUsedInPageFooter
FROM DataSetFields AS DSF

