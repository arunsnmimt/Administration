USE JCB_Live_Link_UAT1_SATELLITE1

-- Ensure a USE <databasename> statement has been executed first.
SELECT i.[name] AS IndexName
, SUM(s.[used_page_count]) AS Page_Count
    ,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
    ,CAST((SUM(s.[used_page_count]) * 8) / 1024 / 1024. AS DECIMAL(10,2)) AS IndexSizeGB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
    WHERE i.[name] = 'PK_tbl_TrackedEvent'
GROUP BY i.[name]
ORDER BY i.[name]


-- Ensure a USE  statement has been executed first.
SELECT [DatabaseName]
    ,[ObjectId]
    ,[ObjectName]
    ,[IndexId]
    ,[IndexDescription]
    ,CONVERT(DECIMAL(16, 1), (SUM([avg_record_size_in_bytes] * [record_count]) / (1024.0 * 1024))) AS [IndexSize(MB)]
    ,[lastupdated] AS [StatisticLastUpdated]
    ,[AvgFragmentationInPercent]
FROM (
    SELECT DISTINCT DB_Name(Database_id) AS 'DatabaseName'
        ,OBJECT_ID AS ObjectId
        ,Object_Name(Object_id) AS ObjectName
        ,Index_ID AS IndexId
        ,Index_Type_Desc AS IndexDescription
        ,avg_record_size_in_bytes
        ,record_count
        ,STATS_DATE(object_id, index_id) AS 'lastupdated'
        ,CONVERT([varchar](512), round(Avg_Fragmentation_In_Percent, 3)) AS 'AvgFragmentationInPercent'
    FROM sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'detailed')
    WHERE OBJECT_ID IS NOT NULL
        AND Avg_Fragmentation_In_Percent <> 0
    ) T
GROUP BY DatabaseName
    ,ObjectId
    ,ObjectName
    ,IndexId
    ,IndexDescription
    ,lastupdated
    ,AvgFragmentationInPercent