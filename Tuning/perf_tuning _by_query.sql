--Capturing Executing Queries Using sys.dm_exec_requests

SELECT r.session_id, r.status, r.start_time, r.command, s.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
WHERE r.status = 'running'

-----------------------------

--Viewing Performance Statistics for Cached Query Plans

DBCC FREEPROCCACHE
GO
SELECT CustomerID, ContactID, Demographics, ModifiedDate
FROM Sales.Individual

--Now, I’ll query the sys.dm_exec_query_stats dynamic management view, which contains statistical
--information regarding queries cached on the SQL Server instance. This view contains a sql_handle,
--which I’ll use as an input to the sys.dm_exec_sql_text dynamic management function. This function
--is used to return the text of a Transact-SQL statement:

SELECT t.text,
st.total_logical_reads,
st.total_physical_reads,
st.total_elapsed_time/1000000 Total_Time_Secs,
st.total_logical_writes
FROM sys.dm_exec_query_stats st
CROSS APPLY sys.dm_exec_sql_text(st.sql_handle) t

----------------------------------
-- find frag >30%
SELECT OBJECT_NAME(object_id) ObjectName,
index_id,
index_type_desc,
avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats
(DB_ID('AdventureWorks'),NULL, NULL, NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 30
ORDER BY avg_fragmentation_in_percent desc

------------------------------------------

--In this example, the sys.dm_db_index_usage_stats dynamic management view is
--queried to see if the indexes on the Sales.Customer table are being used. Prior to referencing
--sys.dm_db_index_usage_stats, two queries will be executed against the Sales.Customer table,
--one returning all rows and columns and the second returning the AccountNumber column for
--a specific TerritoryID:

SELECT *
FROM Sales.Customer

SELECT AccountNumber
FROM Sales.Customer
WHERE TerritoryID = 4

--After executing the queries, the sys.dm_db_index_usage_stats dynamic management view is queried:

SELECT i.name IndexName, user_seeks, user_scans,
last_user_seek, last_user_scan
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON
s.object_id = i.object_id AND
s.index_id = i.index_id
WHERE database_id = DB_ID('AdventureWorks') AND
s.object_id = OBJECT_ID('Sales.Customer')

