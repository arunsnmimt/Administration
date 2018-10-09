SET NOCOUNT ON;

DECLARE @SpID smallint

DECLARE spID_Cursor CURSOR
FORWARD_ONLY READ_ONLY FOR


SELECT TOP 15 spid
FROM master..sysprocesses
WHERE status = 'runnable'
AND spid > 50 -- Eliminate system SPIDs
AND spid <> 556 -- Replace with your SPID
ORDER BY CPU DESC

OPEN spID_Cursor
FETCH NEXT FROM spID_Cursor
INTO @spID
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Spid #: ' + STR(@spID)
    EXEC ('DBCC INPUTBUFFER (' + @spID + ')')
    FETCH NEXT FROM spID_Cursor
    INTO @spID
END

-- Close and deallocate the cursor
CLOSE spID_Cursor
DEALLOCATE spID_Cursor