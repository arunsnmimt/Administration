-- =============================================================================
-- 07 - Find all Connection Strings
-- =============================================================================
-- This query will use the base data provided by the CatalogContentView and return
-- only those objects that have a "ConnectString" element as well as the
-- Text of the Connection String
-- 
-- This query that was based on a request that came in via a comment on my 
-- blog post.  It simply locates any <ConnectString ... /> element in the 
-- ContentCatalogView and extracts the connection string
--
-- The query also attempts to extract the Provider information.  This is made
-- more difficult because the provider is actually in a sibling element 
-- to the ConnectString and may be called either Extension or DataProvider
-- this query attempts to find the proper version if it exists...
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
  ,CASE
     WHEN ConnectionString.exist('../*:Extension') = 1 THEN ConnectionString.value('(../*:Extension/text())[1]','nvarchar(max)')
     WHEN ConnectionString.exist('../*:DataProvider') =1 THEN ConnectionString.value('(../*:DataProvider/text())[1]','nvarchar(max)')
     ELSE 'Unknown' 
   END AS Provider
  ,ConnectionString.value('(text())[1]','nvarchar(max)') AS ConnectionString
FROM ReportQueries.dbo.CatalogContentView
--Get all the ConnectString elements (The "*:" ignores any xml namespaces) 
CROSS APPLY CatalogContentView.ContentXML.nodes('//*:ConnectString') ConnectionStrings(ConnectionString)