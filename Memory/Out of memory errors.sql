/*
Out of memory errors


The number of out of memory errors that have occurred within a rolling five minute window. If you just want to keep an eye out for any memory errors, you can watch the ring buffers for the Out of memory errors alert when it gets registered there. This won’t provide you with information about specifically what errors might be occurring, but it will help you keep an eye on the system to just be aware of the issue. Use this on a system that is basically configured and operating well as an indicator that you may have an issue. Should you begin to get these on a regular basis you’ll need to add additional memory monitoring.
*/

DECLARE @tmp INT;
 
SELECT  @tmp = 1
FROM    sys.dm_os_ring_buffers AS dorb
        CROSS JOIN sys.dm_os_sys_info AS dosi
WHERE   dorb.ring_buffer_type = 'RING_BUFFER_OOM'
        AND DATEADD(ss,
                    (-1 * ((dosi.cpu_ticks / CONVERT (FLOAT, (dosi.cpu_ticks
                                                              / dosi.ms_ticks)))
                           - dorb.timestamp) / 1000), GETDATE()) > DATEADD(mi,
                                                              -5, GETDATE());
 
SELECT ISNULL(@tmp, 0);