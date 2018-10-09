/*
OS Wait Time: Async_Network_IO


This metric gives you an indication of how much time is spent waiting to send information over a network. High values may indicate slow network performance, but may also indicate that clients are not fetching data quickly, or are leaving connections open with data still available to be fetched.

Asynchronous network IO references the amount of time that SQL Server processes spend waiting on data to be transmitted to and from the client. High values may indicate slow network performance, but may also indicate that clients are not fetching data quickly, or are leaving connections open with data still available to be fetched. Values are displayed in seconds, and are collected once per server (this is a server-centric value).
*/

SELECT  wait_time_ms / 1000.0 AS wait_time_sec
FROM    sys.dm_os_wait_stats
WHERE   wait_type = 'ASYNC_NETWORK_IO';