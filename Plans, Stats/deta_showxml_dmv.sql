--rc + 'analyse in DETA'
SELECT CustomerID, PurchaseOrderNumber, TotalDue
FROM Sales.SalesOrderHeader
WHERE ShipMethodID > 2
AND TotalDue > 200.00
AND TerritoryID = 3
GO

SET STATISTICS XML ON
GO
Use Adventureworks
SELECT CustomerID, PurchaseOrderNumber, TotalDue
FROM Sales.SalesOrderHeader
WHERE ShipMethodID > 2
AND TotalDue > 200.00
AND TerritoryID = 3;
GO
SET STATISTICS XML OFF
GO

SELECT CustomerID, PurchaseOrderNumber, TotalDue
FROM Sales.SalesOrderHeader
WHERE ShipMethodID > 2
AND TotalDue > 200.00
AND TerritoryID = 3
GO
select * from sys.dm_db_missing_index_details

CREATE NONCLUSTERED INDEX TestIndex
ON Sales.SalesOrderHeader (TerritoryID, ShipMethodID, TotalDue)
INCLUDE (PurchaseOrderNumber, CustomerID)

