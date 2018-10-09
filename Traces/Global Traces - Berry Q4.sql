
-- Returns a list of all global trace flags that are enabled (Query 4) (Global Trace Flags)
DBCC TRACESTATUS (-1);



-- If no global trace flags are enabled, no results will be returned.
-- It is very useful to know what global trace flags are currently enabled
-- as part of the diagnostic process.

/*

DBCC TRACEOFF (1222, -1);  -- disables trace flag 1222 globally
*/