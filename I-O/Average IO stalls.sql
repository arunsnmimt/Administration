/*
Average I/O stalls


Explanation: This is a general indicator of performance problems. High stall times indicate I/O problems, which can be attributed to busy physical disks or queries that return large data sets to the client.


Solutions may involve allocating new hardware resources in addition to performance tuning of individual queries.

Description:
Explanation: This is a general indicator of performance problems. High stall times indicate I/O problems, which can be attributed to busy physical disks or queries that return large data sets to the client. Guideline values: The ideal value for this metric should be less than 100, but this is just a rule-of-thumb. Higher values may be acceptable for your organization. Check also:

    Disk avg. read time
    Disk avg. write time
    Avg. disk queue length

Possible solutions: IO Stalls are affected by three possible factors:

    poorly performing disk subsystem (such as a misconfigured SAN)
    poorly defined queries
    overloaded disks (“data bursts”)

*/
SELECT  CAST(SUM(io_stall_read_ms + io_stall_write_ms) /
             SUM(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10, 1)
        ) AS [avg_io_stall_ms]
FROM    sys.dm_io_virtual_file_stats(DB_ID(), NULL)
WHERE   FILE_ID <> 2;