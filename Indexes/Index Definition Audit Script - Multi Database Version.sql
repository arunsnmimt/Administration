IF OBJECT_ID('tempdb..#IndexAudit') IS NOT NULL
    DROP TABLE #IndexAudit;
 
CREATE TABLE #IndexAudit
(
      serverName                SYSNAME
    , databaseName              SYSNAME
    , tableName                 VARCHAR(128)
    , indexName                 VARCHAR(128)
    , indexType                 NVARCHAR(60)
    , indexKeys                 VARCHAR(8000)
    , includedColumns           VARCHAR(8000)
    , partitionColumns          VARCHAR(8000)
    , isPrimaryKey              BIT
    , isUnique                  BIT
    , isUniqueConstraint        BIT
    , isFilteredIndex           BIT
    , FilterDefinition          VARCHAR(8000)
);
 
--EXECUTE sp_foreachdb 'USE ?;
EXECUTE sp_msforeachdb 'USE ?;
WITH indexCTE AS
(
    SELECT st.object_id                                                                         AS objectID
        , st.name                                                                               AS tableName
        , si.index_id                                                                           AS indexID
        , si.type_desc                                                                          AS indexType
        , si.name                                                                               AS indexName
        , sc.column_id                                                                          AS columnID
        , sc.name + CASE WHEN sic.is_descending_key = 1 THEN '' DESC'' ELSE '''' END            AS columnName
        , sic.key_ordinal                                                                       AS ordinalPosition
        , CASE WHEN sic.is_included_column = 0 AND key_ordinal > 0 THEN sc.name ELSE NULL END   AS indexKeys
        , CASE WHEN sic.is_included_column = 1 THEN sc.name ELSE NULL END                       AS includedColumns
        , sic.partition_ordinal                                                                 AS partitionOrdinal
        , CASE WHEN sic.partition_ordinal > 0 THEN sc.name ELSE NULL END                        AS partitionColumns
        , si.is_primary_key                                                                     AS isPrimaryKey
        , si.is_unique                                                                          AS isUnique
        , si.is_unique_constraint                                                               AS isUniqueConstraint
        , si.has_filter                                                                         AS isFilteredIndex
        , COALESCE(si.filter_definition, '''')                                                  AS filterDefinition
    FROM sys.tables                         AS st
    INNER JOIN sys.indexes                  AS si 
        ON si.object_id =   st.object_id
    INNER JOIN sys.index_columns            AS sic 
	    ON sic.object_id=si.object_id
        AND sic.index_id=si.index_id 
    INNER JOIN sys.columns                  AS sc 
	    ON sc.object_id = sic.object_id 
	    and sc.column_id = sic.column_id
) 
 
INSERT INTO #IndexAudit
SELECT DISTINCT 
      @@SERVERNAME                                              AS ServerName
    , DB_NAME()                                                 AS DatabaseName
    , tableName
    , indexName
    , indexType
    , STUFF((
            SELECT '', '' + indexKeys
                FROM indexCTE
            WHERE objectID = cte.objectID
                AND indexID = cte.indexID
                AND indexKeys IS NOT NULL 
            ORDER BY ordinalPosition
                FOR XML PATH(''''), 
      TYPE).value(''.'',''varchar(max)''),1,1,'''')             AS indexKeys
    , COALESCE(STUFF((
            SELECT '', '' + includedColumns
                FROM indexCTE
            WHERE objectID = cte.objectID
                AND indexID = cte.indexID
                AND includedColumns IS NOT NULL 
            ORDER BY columnID
                FOR XML PATH(''''), 
      TYPE).value(''.'',''varchar(max)''),1,1,''''), '''')      AS includedColumns
    , COALESCE(STUFF((
            SELECT '', '' + partitionColumns
                FROM indexCTE
            WHERE objectID = cte.objectID
                AND indexID = cte.indexID
                AND partitionColumns IS NOT NULL 
            ORDER BY partitionOrdinal
                FOR XML PATH(''''), 
      TYPE).value(''.'',''varchar(max)''),1,1,''''), '''')      AS partitionKeys
    , isPrimaryKey
    , isUnique
    , isUniqueConstraint
    , isFilteredIndex
    , FilterDefinition
FROM indexCTE AS cte
ORDER BY tableName
    , indexName;
';
 
-- For multi-server testing, dump results to a temp table and compare tables
SELECT *
FROM #IndexAudit
WHERE databaseName NOT IN ('tempdb', 'master', 'msdb', 'model')
ORDER BY serverName
    , databaseName
    , tableName
    , indexName;