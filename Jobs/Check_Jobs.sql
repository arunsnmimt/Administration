DECLARE @Status CHAR(1)
DECLARE @Count INT
DECLARE @CountLimit INT
DECLARE @JobName AS VARCHAR(255)


SET @CountLimit = 6 ---5 * 4 -- Wait 5 Minutes
SET @Count		= 0
SET @JobName = 'Test'


EXEC dbo.usp_Check_Job_Status @JobName, @Status OUTPUT

WHILE @Count < @CountLimit AND @Status = 'R'
BEGIN
      
	BEGIN
		WAITFOR DELAY '00:00:15'

		EXEC dbo.usp_Check_Job_Status @JobName, @Status OUTPUT
	END
	PRINT @Status
	
	SET @Count = @Count + 1

END

IF @Status <> 'C'
BEGIN
	PRINT 1	 --  Raise Error	
END

