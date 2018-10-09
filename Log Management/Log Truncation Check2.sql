USE [TMC_Reports_TESCO_COM_UAT]


DECLARE @LogResueNothingCount AS TINYINT
DECLARE @NoOfAttempts		  AS SMALLINT = 0
DECLARE @LogShrunk AS BIT = 0

-- See if log can be shrunk

WHILE @NoOfAttempts <= 10 AND @LogShrunk = 0
BEGIN
	SET @LogResueNothingCount = (SELECT COUNT(*) AS RecCount
								   FROM sys.databases
								  WHERE name = 'TMC_Reports_TESCO_COM_UAT'
									AND log_reuse_wait_desc = 'NOTHING')

	IF @LogResueNothingCount = 1
	BEGIN
		DBCC SHRINKFILE(TMC_REPORTS_TESCO_log, 256)
		SET @LogShrunk = 1
	END
	ELSE
	BEGIN
		SET @NoOfAttempts = @NoOfAttempts + 1

		WAITFOR DELAY '00:05'
		
	END
END
