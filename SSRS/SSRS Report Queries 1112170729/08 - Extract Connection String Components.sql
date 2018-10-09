-- =============================================================================
-- 08 - Extract Connection String Components
-- =============================================================================
-- This query builds on the query from "07 - Find all Connection Strings.sql"
-- and attempts to extract the individual components of each connection string.
-- For example, a normal connection string might look like:
--
--   Data Source=localhost;Initial Catalog=Northwind;Integrated Security=SSPI;
-- 
-- You could break that down into three components, each with a name and a value:
-- 
-- Component Name         Component Value
-- ----------------       ------------------------------------------------
-- Data Source            localhost
-- Initial Catalog        Northwind
-- Integrated Security    SSPI
-- 
-- To do this, I play some search and replace games on the original connection
-- string, and turn it into an XML representation of a connection string:
--
--   CAST('<ConnectionString><Component Name="' + REPLACE(REPLACE(ConnectionString,'=','" Value="'),';','" /><Component Name="') + '" /></ConnectionString>' AS XML) AS ConnectionStringXML
-- 
-- Turns the connection string above into the following XML 
-- 
--   <ConnectionString>
--     <Component Name="Data Source" Value="localhost" />
--     <Component Name="Initial Catalog" Value="Northwind" />
--     <Component Name="Integrated Security" Value="SSPI" />
--     <Component Name="" />
--   </ConnectionString>
-- 
-- Note that the XML above has an extra <Component Name="" /> element at the
-- end.  This is because of the trailing semicolon (";") at the end 
-- of the original connection string, and the way that I build the XML string
-- using the REPLACE function.
-- 
-- To get the Individual components that actually have valid values, I can
-- use the following CROSS APPLY....
--
-- CROSS APPLY ConnectionStringXML.nodes('//Component[@Value]') AS Components(Component) 
--
-- The '//Component[@Value]' XPath makes sure to only find Component elements
-- that have Value attribute.  This will eliminate any empty Component elements
-- 
-- Now that I have the individual component nodes, I can extract their Name
-- and Value attribute values with these expressions:
--
--   Component.value('@Name','nvarchar(max)') AS ComponentName
--   Component.value('@Value','nvarchar(max)') AS ComponentValue
--
-- I can then use SQL's XML tools to extract the various components...
--
-- -----------------------------------------------------------------------------
-- History (most recent at top)
-- -----------------------------------------------------------------------------
-- 11/30/2011 - BStateham - Original Script
-- =============================================================================

-- Start out by getting all the connection strings from the CatalogContentView
-- The query in this first CTE is explained in the "07 - Find all Connection Strings.sql"
-- script
WITH ItemConnectionStrings AS
(
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
),
--Next, convert the original "name=value;name=value;" style connection string into a more useful
--xml representation that looks like this:
--<ConnectionString><Component Name="..." Value="..." /><Component Name="..." Value="..." /></ConnectionString>
ItemConnectionStringsXML AS
(
  SELECT
     ItemID
    ,Name
    ,[Path]
    ,ParentID
    ,[Type]
    ,TypeDescription
    ,ContentXML 
    ,Provider
    ,ConnectionString
    ,CAST('<ConnectionString><Component Name="' + REPLACE(REPLACE(ConnectionString,'=','" Value="'),';','" /><Component Name="') + '" /></ConnectionString>' AS XML) AS ConnectionStringXML
  FROM ItemConnectionStrings
)
--Finally find all the components with values from XML version of the connection string 
--from above, and extract the actual Name and Value values from the XML.
SELECT
     ItemID
    ,Name
    ,[Path]
    ,ParentID
    ,[Type]
    ,TypeDescription
    ,ContentXML 
    ,Provider
    ,ConnectionString
    ,ConnectionStringXML
    ,Component.value('@Name','nvarchar(max)') AS ComponentName
    ,Component.value('@Value','nvarchar(max)') AS ComponentValue
FROM ItemConnectionStringsXML
CROSS APPLY ConnectionStringXML.nodes('//Component[@Value]') AS Components(Component) 

