---- ================================
---- Enable Database for CDC Template
---- ================================
--USE ILRAnalyserNew3
--GO

--EXEC sys.sp_cdc_enable_db
--GO

-- =================================
-- Disable Database for CDC Template
-- =================================
--USE ILRAnalyserNew3
--GO

--EXEC sys.sp_cdc_disable_db
--GO




---- ===================================================
---- Enable a Table Without Using a Gating Role Template
---- ===================================================


--EXEC sys.sp_cdc_enable_table
--	@source_schema = N'dbo',
--	@source_name   = N'tblAim',
--	@role_name     = NULL,
--	@supports_net_changes = 1
--GO

---- ===============================================
---- Disable a Capture Instance for a Table Template
---- ===============================================
--EXEC sys.sp_cdc_disable_table
--	@source_schema = N'dbo',
--	@source_name   = N'tblAim',
--	@capture_instance = N'dbo_tblAim'
--GO


DECLARE @from_lsn binary(10), @to_lsn binary(10)
SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo_tblAim')
SET @to_lsn   = sys.fn_cdc_get_max_lsn()
SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_tblAim(@from_lsn, @to_lsn, N'all')
GO

