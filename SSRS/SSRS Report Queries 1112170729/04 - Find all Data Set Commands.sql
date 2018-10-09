-- =============================================================================
-- 04 - Find all Data Set Commands
-- =============================================================================
-- Once we can get the catalog item contents as XML, we can use SQL Server's
-- support for XQuery to investigate the contents.  To learn more about
-- SQL Server and XQuery check out the SQL Server documentation:
--
-- http://msdn.microsoft.com/en-us/library/ms189075.aspx
-- 
-- This query will use the base data provided by the CatalogContentView and return
-- only those objects that have a "DataSet" element, and then from those DataSet
-- elements, extract the "Query" elements "Commandtext" and "CommandType"
--
-- -----------------------------------------------------------------------------
-- History (most recent at top)
-- -----------------------------------------------------------------------------
-- 11/30/2011 - BStateham - Original Script
-- =============================================================================

SELECT 
   ItemID,Name,[Path],ParentID,[Type],TypeDescription,ContentXML 
  ,ISNULL(DataSet.value('./@Name','nvarchar(1024)'),'Text') AS DataSetName
  ,CAST(DataSet.exist('./*:SharedDataSet') AS bit) AS IsSharedDataSetReference
  ,ISNULL(DataSet.value('(..//*:SharedDataSetReference/text())[1]','nvarchar(1024)'),'') AS SharedDataSetName
  ,ISNULL(DataSet.value('(./*:Query/*:CommandType/text())[1]','nvarchar(1024)'),'Text') AS CommandType 
  ,ISNULL(DataSet.value('(./*:Query/*:CommandText/text())[1]','nvarchar(max)'),'') AS CommandText 
FROM ReportQueries.dbo.CatalogContentView AS CCV
--Get all the Query elements (The "*:" ignores any xml namespaces) 
CROSS APPLY CCV.ContentXML.nodes('//*:DataSet') DataSets(DataSet)
