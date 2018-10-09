-- default Trace Finish https://www.simple-talk.com/sql/performance/the-default-trace-in-sql-server---the-power-of-performance-and-security-auditing/

-- Events Captured by Default trace

DECLARE @TraceID INT;

SELECT @TraceID = id FROM sys.traces WHERE is_default = 1;

SELECT t.EventID, e.name as Event_Description
  FROM sys.fn_trace_geteventinfo(@TraceID) t
  JOIN sys.trace_events e ON t.eventID = e.trace_event_id
  GROUP BY t.EventID, e.name;


--


DECLARE @path NVARCHAR(260);

SELECT 
   @path = REVERSE(SUBSTRING(REVERSE([path]), 
   CHARINDEX(CHAR(92), REVERSE([path])), 260)) + N'log.trc'
FROM    sys.traces
WHERE   is_default = 1;



--  List the data file growths and shrinkages
SELECT  TE.name AS [EventName] ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.Duration ,
        t.StartTime ,
        t.EndTime
FROM sys.fn_trace_gettable ( @path , 1 )  T      
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE   te.name = 'Data File Auto Grow'
        OR te.name = 'Data File Auto Shrink'
ORDER BY t.StartTime ; 


-- log growths and log shrinking.

SELECT  TE.name AS [EventName] ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.Duration ,
        t.StartTime ,
        t.EndTime
FROM sys.fn_trace_gettable ( @path , 1 )  T      
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE   te.name = 'Log File Auto Grow'
        OR te.name = 'Log File Auto Shrink'
ORDER BY t.StartTime ; 


/*
These categories of errors and warnings are:

Errorlog
Hash warning
Missing Column Statistics
Missing Join Predicate
Sort Warning
Here is a script which will outline the errors:
*/


SELECT  TE.name AS [EventName] ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime ,
        t.TextData ,
        t.Severity ,
        t.Error
FROM sys.fn_trace_gettable ( @path , 1 )  T      
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE   te.name = 'ErrorLog'

-- Here is another script which will outline the sort and hash warnings:

SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name = 'Hash Warning'
        OR te.name = 'Sort Warnings'
-- and finally, one more script which outlines the missing statistics and join predicates.
SELECT  TE.name AS [EventName] ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE   te.name = 'Missing Column Statistics'
        OR te.name = 'Missing Join Predicate'
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
/*        
Server Memory Change Events

And now, let’s move on to the last event class in our default trace: the Server class. It contains only one event – Server Memory Change.

The following query will tell us when the memory use has changed:
*/

SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        t.IsSystem
FROM sys.fn_trace_gettable ( 'F:\MSSQL10_50.MSSQLSERVER\MSSQL\Log\log_3019.trc' , 1 )  T            
--FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
--                                                              f.[value]
--                                                      FROM    sys.fn_trace_getinfo(NULL) f
--                                                      WHERE   f.property = 2
--                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ( 'Server Memory Change' )        