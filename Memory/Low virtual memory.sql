/*
Low virtual memory


Determining if your SQL Server instance is experiencing memory issues within the SQL Server Virtual Address Space (VAS) can be a challenge. One way around it is to use the sys.dm_os_ring_buffers to capture alerts registered there that show when virtual memory (also known as internal memory) is low. This is especially useful in situations where you’re running SQL Server on a shared environment with some other service or application.

For more information, see Using sys.dm_os_ring_buffers To Diagnose Memory Issues in SQL Server.



This metric uses the sys.dm_os_ring_buffers to identify low virtual memory on the SQL Server system. It uses the RING_BUFFER_RESOURCE_MONITOR to identify when the latest alert has a Notification value of RESOURCE_MEMVIRTUAL_LOW.
*/

WITH    RingBuffer
          AS (SELECT    CAST(record AS XML) AS xRecord,
                        DATEADD(ss,
                                (-1 * ((dosi.cpu_ticks
                                        / CONVERT (FLOAT, (dosi.cpu_ticks
                                                           / dosi.ms_ticks)))
                                       - dorb.timestamp) / 1000), GETDATE()) AS DateOccurred
              FROM      sys.dm_os_ring_buffers AS dorb
                        CROSS JOIN sys.dm_os_sys_info AS dosi
              WHERE     ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
             )
    SELECT TOP 1
            CASE (xr.value('(ResourceMonitor/Notification)[1]', 'varchar(75)'))
              WHEN 'RESOURCE_MEMVIRTUAL_LOW' THEN 1
              ELSE 0
            END AS LowMemAlert
    FROM    RingBuffer AS rb
            CROSS APPLY rb.xRecord.nodes('Record') record (xr)
    WHERE   xr.value('(ResourceMonitor/Notification)[1]', 'varchar(75)') = 'RESOURCE_MEMVIRTUAL_LOW'
            AND rb.DateOccurred > DATEADD(mm, -5, GETDATE())
    ORDER BY rb.DateOccurred DESC;