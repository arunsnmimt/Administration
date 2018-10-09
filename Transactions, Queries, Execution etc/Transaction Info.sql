/*
   Use database_transaction_log_bytes_reserved column of sys.dm_tran_database_transactions 
   to determine if the thread is actually progressing versus being hung. 
   Reserved space will decrease as the transaction rollback. 
*/

SELECT     DISTINCT    transaction_id,        DB_NAME(database_id) AS database_name,        database_id,        database_transaction_begin_time,        database_transaction_type,  Database_transaction_state,      database_transaction_log_record_count,        database_transaction_log_bytes_used,        database_transaction_log_bytes_reserved,        database_transaction_begin_lsn,        database_transaction_last_lsn  FROM sys.dm_tran_database_transactions a  INNER JOIN sys.dm_tran_locks b ON a.transaction_id = b.request_owner_id  WHERE request_session_id = 236