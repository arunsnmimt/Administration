DECLARE @command VARCHAR(4000)


SELECT @command = 'USE [?]

IF  EXISTS (SELECT DB_NAME(DB_ID()) WHERE DB_NAME(DB_ID()) LIKE ''TMC_Reports%''  )
BEGIN
	PRINT DB_NAME(DB_ID())
	GRANT EXECUTE ON [dbo].[fnc_Decrypt_String] TO [Tier1]
	GRANT EXECUTE ON [dbo].[fnc_Decrypt_String] TO [Tier2]
END'

--PRINT @command

EXEC sp_MSforeachdb @command 


