DECLARE @SQL AS VARCHAR(MAX)

DECLARE @SQLServerProductVersion AS INT
SET @SQLServerProductVersion =  LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)),0)-1)


-- Recovery model, log reuse wait description, log file size, log usage size  (Query 19) (Database Properties)
-- and compatibility level for all databases on instance

IF @SQLServerProductVersion < 11
BEGIN

SELECT  *
FROM    sys.databases

	SELECT db.[name] AS [Database Name], 
	db.create_date, 
	suser_sname(db.owner_sid) AS db_owner, 
	db.collation_name, db.recovery_model_desc AS [Recovery Model], db.state_desc, 
	db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
	CONVERT(DECIMAL(18,2), ls.cntr_value/1024.0) AS [Log Size (MB)], CONVERT(DECIMAL(18,2), lu.cntr_value/1024.0) AS [Log Used (MB)],
	CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
	db.[compatibility_level] AS [DB Compatibility Level], 
	db.page_verify_option_desc AS [Page Verify Option], 
	db.is_ansi_null_default_on,
	db.is_ansi_nulls_on,
	db.is_ansi_padding_on,
	db.is_arithabort_on,
	db.is_cursor_close_on_commit_on,
	db.is_db_chaining_on,
	db.is_read_only,
	db.is_date_correlation_on,
	db.is_concat_null_yields_null_on,
	db.is_fulltext_enabled,
	db.is_numeric_roundabort_on,
	db.page_verify_option,
	db.is_local_cursor_default,
	db.is_quoted_identifier_on,
	db.is_broker_enabled,
	db.is_recursive_triggers_on,
	db.is_trustworthy_on,
	db.is_auto_create_stats_on, db.is_auto_update_stats_on,
	db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
	db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on,
	db.is_auto_close_on, db.is_auto_shrink_on, db.is_cdc_enabled
	FROM sys.databases AS db WITH (NOLOCK)
	INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
	ON db.name = lu.instance_name
	INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
	ON db.name = ls.instance_name
	WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
	AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
	AND ls.cntr_value > 0 OPTION (RECOMPILE);
END
ELSE
BEGIN
	SET @SQL = '
	SELECT db.[name] AS [Database Name], 	db.create_date, 
	suser_sname(db.owner_sid) AS db_owner, 
	db.collation_name, db.recovery_model_desc AS [Recovery Model], db.state_desc, 
	db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
	CONVERT(DECIMAL(18,2), ls.cntr_value/1024.0) AS [Log Size (MB)], CONVERT(DECIMAL(18,2), lu.cntr_value/1024.0) AS [Log Used (MB)],
	CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
	db.[compatibility_level] AS [DB Compatibility Level], 
	db.page_verify_option_desc AS [Page Verify Option], db.is_auto_create_stats_on, db.is_auto_update_stats_on,
	db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
	db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on,
	db.is_auto_close_on, db.is_auto_shrink_on, db.target_recovery_time_in_seconds, db.is_cdc_enabled
	FROM sys.databases AS db WITH (NOLOCK)
	INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
	ON db.name = lu.instance_name
	INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
	ON db.name = ls.instance_name
	WHERE lu.counter_name LIKE N''Log File(s) Used Size (KB)%'' 
	AND ls.counter_name LIKE N''Log File(s) Size (KB)%''
	AND ls.cntr_value > 0 OPTION (RECOMPILE);'
	EXEC(@SQL)
END

-- Things to look at:
-- How many databases are on the instance?
-- What recovery models are they using?
-- What is the log reuse wait description?
-- How full are the transaction logs ?
-- What compatibility level are they on?
-- What is the Page Verify Option?
-- Make sure auto_shrink and auto_close are not enabled!


SELECT	name, 
		crdate as CreationDate,
		cmptlevel AS [CmptLevel],
		[filename] AS [Filename],
		DATABASEPROPERTYEX(name, 'Recovery') As [Recovery],
		DATABASEPROPERTYEX(name, 'Status') As [Status],
		DATABASEPROPERTYEX(name, 'Collation') As Collation,
		DATABASEPROPERTYEX(name, 'SQLSortOrder') As SQLSortOrder,
		DATABASEPROPERTYEX(name, 'Updateability') As Updateability,
		DATABASEPROPERTYEX(name, 'UserAccess') As UserAccess,
		DATABASEPROPERTYEX(name, 'Version') As Version,
		DATABASEPROPERTYEX(name, 'IsAutoClose') As IsAutoClose,
		DATABASEPROPERTYEX(name, 'IsAutoCreateStatistics') As IsAutoCreateStatistics,
		DATABASEPROPERTYEX(name, 'IsAutoShrink') As IsAutoShrink,
		DATABASEPROPERTYEX(name, 'IsAutoUpdateStatistics') As IsAutoUpdateStatistics,
		DATABASEPROPERTYEX(name, 'IsCloseCursorsOnCommitEnabled') As IsCloseCursorsOnCommitEnabled,
		DATABASEPROPERTYEX(name, 'IsFulltextEnabled') As IsFulltextEnabled,
		DATABASEPROPERTYEX(name, 'IsInStandBy') As IsInStandBy,
		DATABASEPROPERTYEX(name, 'IsMergePublished') As IsMergePublished,
		DATABASEPROPERTYEX(name, 'IsPublished') As IsPublished,
		DATABASEPROPERTYEX(name, 'IsSubscribed') As IsSubscribed,
		DATABASEPROPERTYEX(name, 'IsTornPageDetectionEnabled') As IsTornPageDetectionEnabled
FROM   master.dbo.sysdatabases
WHERE name = 'NexphaseV6'
ORDER BY 1





/*
		DATABASEPROPERTYEX(name, 'Collation') As Collation,
		DATABASEPROPERTYEX(name, 'ComparisonStyle') As ComparisonStyle,
		DATABASEPROPERTYEX(name, 'IsAnsiNullDefault') As IsAnsiNullDefault,
		DATABASEPROPERTYEX(name, 'IsAnsiNullsEnabled') As IsAnsiNullsEnabled,
		DATABASEPROPERTYEX(name, 'IsAnsiPaddingEnabled') As IsAnsiPaddingEnabled,
		DATABASEPROPERTYEX(name, 'IsAnsiWarningsEnabled') As IsAnsiWarningsEnabled,
		DATABASEPROPERTYEX(name, 'IsArithmeticAbortEnabled') As IsArithmeticAbortEnabled,
		DATABASEPROPERTYEX(name, 'IsAutoClose') As IsAutoClose,
		DATABASEPROPERTYEX(name, 'IsAutoCreateStatistics') As IsAutoCreateStatistics,
		DATABASEPROPERTYEX(name, 'IsAutoShrink') As IsAutoShrink,
		DATABASEPROPERTYEX(name, 'IsAutoUpdateStatistics') As IsAutoUpdateStatistics,
		DATABASEPROPERTYEX(name, 'IsCloseCursorsOnCommitEnabled') As IsCloseCursorsOnCommitEnabled,
		DATABASEPROPERTYEX(name, 'IsFulltextEnabled') As IsFulltextEnabled,
		DATABASEPROPERTYEX(name, 'IsInStandBy') As IsInStandBy,
		DATABASEPROPERTYEX(name, 'IsLocalCursorsDefault') As IsLocalCursorsDefault,
		DATABASEPROPERTYEX(name, 'IsMergePublished') As IsMergePublished,
		DATABASEPROPERTYEX(name, 'IsNullConcat') As IsNullConcat,
		DATABASEPROPERTYEX(name, 'IsNumericRoundAbortEnabled') As IsNumericRoundAbortEnabled,
		DATABASEPROPERTYEX(name, 'IsParameterizationForced') As IsParameterizationForced,
		DATABASEPROPERTYEX(name, 'IsPublished') As IsPublished,
		DATABASEPROPERTYEX(name, 'IsQuotedIdentifiersEnabled') As IsQuotedIdentifiersEnabled,
		DATABASEPROPERTYEX(name, 'IsRecursiveTriggersEnabled') As IsRecursiveTriggersEnabled,
		DATABASEPROPERTYEX(name, 'IsSubscribed') As IsSubscribed,
		DATABASEPROPERTYEX(name, 'IsSyncWithBackup') As IsSyncWithBackup,
		DATABASEPROPERTYEX(name, 'IsTornPageDetectionEnabled') As IsTornPageDetectionEnabled
		DATABASEPROPERTYEX(name, 'LCID') As LCID,
		DATABASEPROPERTYEX(name, 'Recovery') As [Recovery],
		DATABASEPROPERTYEX(name, 'SQLSortOrder') As SQLSortOrder,
		DATABASEPROPERTYEX(name, 'Status') As [Status],
		DATABASEPROPERTYEX(name, 'Updateability') As Updateability,
		DATABASEPROPERTYEX(name, 'UserAccess') As UserAccess,
		DATABASEPROPERTYEX(name, 'Version') As Version,


*/
