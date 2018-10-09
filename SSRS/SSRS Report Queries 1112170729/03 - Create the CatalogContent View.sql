USE ReportQueries;

PRINT '----------------------------------------'
IF OBJECT_ID('CatalogContentView','V') IS NOT NULL
  BEGIN 
    PRINT 'Dropping View dbo.CatalogContentView...'
    DROP VIEW dbo.CatalogContentView
  END
GO
PRINT 'Creating View dbo.CatalogContentView...'
GO
-- =============================================================================
-- View:	              CatalogContentView
-- Author:              Bret Stateham
-- Description:         
--
-- Update History (most recent at the top):
--
-- 12/16/2011 - BStateham - Updated to include the removal of Null Terminiation
--                          characters.  A WHERE clause was added to the first
--                          CTE to limit the query to only Items of types
--                          2,5,7 or 8.  The previous version allowed non-xml
--                          items to be retrieved and cause XML parsing errors.  
--                          Note that you could probably also include Type 6
--                          (Report Model) records as well although I haven't 
--                          tested that yet.
-- 11/30/2011 - BStateham - Created
-- =============================================================================
CREATE VIEW [dbo].[CatalogContentView]
AS 
--The first CTE gets the content as a varbinary(max) 
--as well as the other important columns for all items
WITH ItemContentBinaries AS 
( 
  SELECT 
     ItemID
    ,CASE WHEN ParentID IS NOT NULL THEN Name ELSE 'Home' END AS Name
    ,CASE WHEN ParentID IS NOT NULL THEN [Path] ELSE '/' END AS [Path]
    ,ParentID
    ,[Type] 
    ,CASE Type 
      WHEN 1 THEN 'Folder'
      WHEN 2 THEN 'Report' 
      WHEN 3 THEN 'Resource'
      WHEN 4 THEN 'Linked Report'
      WHEN 5 THEN 'Data Source' 
      WHEN 6 THEN 'Report Model'
      WHEN 7 THEN 'Report Part'
      WHEN 8 THEN 'Shared Dataset' 
      ELSE 'Other' 
     END AS TypeDescription 
    ,CONVERT(varbinary(max),Content) AS Content    
  FROM ReportServer.dbo.Catalog 
  WHERE Type IN (2,5,7,8)  --You could limit the query to return only certain types here....
), 
-- The second CTE strips off the BOM if it exists from the 
-- beginning of the XML.  
ItemContentNoBOM AS 
( 
  SELECT 
     ItemID
    ,Name
    ,[Path]
    ,ParentID
    ,[Type] 
    ,TypeDescription 
    ,CASE 
      WHEN LEFT(Content,3) = 0xEFBBBF 
        THEN CONVERT(varbinary(max),SUBSTRING(Content,4,LEN(Content))) 
      ELSE 
        Content 
    END AS Content 
  FROM ItemContentBinaries 
),
--This CTE strips off the trailing 0x00 if there is one
ItemContentNoNullTerm AS
(
  SELECT 
     ItemID
    ,Name
    ,[Path]
    ,ParentID
    ,[Type] 
    ,TypeDescription 
    ,CASE 
      WHEN RIGHT(Content,1) = 0x00 
        THEN CONVERT(varbinary(max),LEFT(Content,LEN(Content)-1)) 
      ELSE 
        Content 
    END AS Content 
  FROM ItemContentNoBOM 
)
--The outer query gets the content in its varbinary, varchar and xml representations... 
SELECT 
   ItemID
  ,Name
  ,[Path]
  ,ParentID
  ,[Type] 
  ,TypeDescription 
  ,Content                                           --varbinary 
  ,CONVERT(varchar(max),Content) AS ContentVarchar   --varchar 
  ,CONVERT(xml,Content) AS ContentXML                --xml 
FROM ItemContentNoNullTerm
GO
PRINT 'Setting Permissions on View CatalogContentView...'
GRANT SELECT ON dbo.CatalogContentView TO Public;
GO
/*
--Place Test Scripts within this block comment...

--Query the view
SELECT * FROM dbo.CatalogContentView;

--Add other useful tests below...
*/