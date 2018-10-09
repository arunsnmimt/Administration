-- total I/O for each database

SELECT name AS 'Database Name'
      ,SUM(num_of_reads) AS 'Number of Reads'
      ,SUM(num_of_writes) AS 'Number of Writes' 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) I
  INNER JOIN sys.databases D  
      ON I.database_id = d.database_id
GROUP BY name ORDER BY 'Number of Reads' DESC;

-- amount of I/O performed by each database in the last 5 minutes


DECLARE @Sample TABLE (
  DBName varchar(128) 
 ,NumberOfReads bigint
 ,NumberOfWrites bigint)

INSERT INTO @Sample 
SELECT name AS 'DBName'
      ,SUM(num_of_reads) AS 'NumberOfRead'
      ,SUM(num_of_writes) AS 'NumberOfWrites' 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) I
  INNER JOIN sys.databases D  
      ON I.database_id = d.database_id
GROUP BY name 

WAITFOR DELAY '00:01:00.000';

SELECT FirstSample.DBName
      ,(SecondSample.NumberOfReads - FirstSample.NumberOfReads) AS 'Number of Reads'
      ,(SecondSample.NumberOfWrites - FirstSample.NumberOfWrites) AS 'Number of Writes'
FROM 
(SELECT * FROM @Sample) FirstSample
INNER JOIN
(SELECT name AS 'DBName'
      ,SUM(num_of_reads) AS 'NumberOfReads'
      ,SUM(num_of_writes) AS 'NumberOfWrites' 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) I
  INNER JOIN sys.databases D  
      ON I.database_id = d.database_id
GROUP BY name) AS SecondSample
ON FirstSample.DBName = SecondSample.DBName
ORDER BY 'Number of Reads' DESC;




--Displaying I/O statistics by physical drive letter

SELECT left(f.physical_name, 1) AS DriveLetter, 
	DATEADD(MS,sample_ms * -1, GETDATE()) AS [Start Date],
	SUM(v.num_of_writes) AS total_num_of_writes, 
	SUM(v.num_of_bytes_written) AS total_num_of_bytes_written, 
	SUM(v.num_of_reads) AS total_num_of_reads, 
	SUM(v.num_of_bytes_read) AS total_num_of_bytes_read, 
	SUM(v.size_on_disk_bytes) AS total_size_on_disk_bytes
FROM sys.master_files f
INNER JOIN sys.dm_io_virtual_file_stats(NULL, NULL) v
ON f.database_id=v.database_id and f.file_id=v.file_id
GROUP BY left(f.physical_name, 1),DATEADD(MS,sample_ms * -1, GETDATE());


/*
-- Calculated Disk Latency for your different database drives

When you run this code on your instance your disk latency information should be in-line with the disk latency numbers associated with your hard drive specifications. Typically your latency numbers should be below 30 ms (your mileage might vary depending on your hardware).

*/
SELECT  LEFT(physical_name, 1) AS drive,
        CAST(SUM(io_stall_read_ms) / 
            (1.0 + SUM(num_of_reads)) AS NUMERIC(10,1)) 
                          AS 'avg_read_disk_latency_ms',
        CAST(SUM(io_stall_write_ms) / 
            (1.0 + SUM(num_of_writes) ) AS NUMERIC(10,1)) 
                          AS 'avg_write_disk_latency_ms',
        CAST((SUM(io_stall)) / 
            (1.0 + SUM(num_of_reads + num_of_writes)) AS NUMERIC(10,1)) 
                          AS 'avg_disk_latency_ms'
FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs
        JOIN sys.master_files AS mf ON mf.database_id = divfs.database_id
                                       AND mf.file_id = divfs.file_id
GROUP BY LEFT(physical_name, 1)
ORDER BY avg_disk_latency_ms DESC;


-- Display the Top 25 Most expensive read I/O queries

SELECT TOP 25 cp.usecounts AS [execution_count]
      ,qs.total_worker_time AS CPU
      ,qs.total_elapsed_time AS ELAPSED_TIME
      ,qs.total_logical_reads AS LOGICAL_READS
      ,qs.total_logical_writes AS LOGICAL_WRITES
      ,qs.total_physical_reads AS PHYSICAL_READS 
      ,SUBSTRING(text, 
                   CASE WHEN statement_start_offset = 0 
                          OR statement_start_offset IS NULL  
                           THEN 1  
                           ELSE statement_start_offset/2 + 1 END, 
                   CASE WHEN statement_end_offset = 0 
                          OR statement_end_offset = -1  
                          OR statement_end_offset IS NULL  
                           THEN LEN(text)  
                           ELSE statement_end_offset/2 END - 
                     CASE WHEN statement_start_offset = 0 
                            OR statement_start_offset IS NULL 
                             THEN 1  
                             ELSE statement_start_offset/2  END + 1 
                  )  AS [Statement]        
FROM sys.dm_exec_query_stats qs  
   join sys.dm_exec_cached_plans cp on qs.plan_handle = cp.plan_handle 
   CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
ORDER BY qs.total_logical_reads DESC;