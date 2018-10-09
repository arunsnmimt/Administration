SELECT OBJECT_NAME(OBJECT_ID) AS DatabaseName, last_user_update,*
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID( 'FSPRODDB_DR')
AND OBJECT_ID=OBJECT_ID('test')