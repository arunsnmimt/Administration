/*
Mirroring latency

This metric measures the latency of a mirroring stream. This is useful for checking the historical status of mirroring and also alerting when mirroring is delayed. Values are displayed in seconds and calculated every minute.

*/

DECLARE @MirroredDBToTest sysname
SET @MirroredDBToTest = DB_NAME()
DECLARE @MirroringResults TABLE
(database_name sysname,
role int,
mirroring_state int,
witness_status int,
log_generation_rate int,
unsent_log int,
send_rate int,
unrestored_log int,
recovery_rate int,
transaction_delay int,
transactions_per_sec int,
average_delay int,
time_recorded datetime,
time_behind datetime,
local_time datetime)
 
INSERT INTO @MirroringResults
EXEC msdb..sp_dbmmonitorresults @database_name = @MirroredDBToTest
 
SELECT DATEDIFF(S,time_behind, time_recorded) AS Latency FROM @MirroringResults