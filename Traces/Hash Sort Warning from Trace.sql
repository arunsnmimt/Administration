/*
Sort/hash issues it can be done by profiling for Hash warning/Sort warning events or by reading from sql server log file using something like this:
*/


DECLARE @filename VARCHAR(500) 
SELECT @filename = CAST(value AS VARCHAR(500)) 
FROM fn_trace_getinfo(DEFAULT) 
WHERE property = 2 
  AND value IS NOT NULL 

select @filename

--Check if you have any Sort/Hash Warnings
SELECT gt.HostName, 
       gt.ApplicationName, 
       gt.NTUserName, 
       gt.NTDomainName, 
       gt.LoginName, 
       gt.SPID, 
       gt.EventClass, 
       te.Name AS EventName,
       gt.EventSubClass,      
       gt.TEXTData, 
       gt.StartTime, 
       gt.EndTime, 
       gt.ObjectName, 
       gt.DatabaseName, 
       gt.FileName 
FROM fn_trace_gettable(@fileName, DEFAULT) gt 
JOIN sys.trace_events te ON gt.EventClass = te.trace_event_id 
WHERE EventClass IN(55, 69) -- Hash/Sort warnings
ORDER BY StartTime desc;