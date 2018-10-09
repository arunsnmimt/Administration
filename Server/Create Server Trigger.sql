CREATE TRIGGER DDL_Logger ON ALL SERVER
  FOR DDL_LOGIN_EVENTS, CREATE_DATABASE, DROP_DATABASE, ALTER_DATABASE

AS

DECLARE @xmlData XML

SET @xmlData = EVENTDATA()


INSERT INTO Audit.dbo.DDL_Log (Server_Name, Database_Name, DDL_Event, TSQL_Statement, Event_User, Event_Date )
	VALUES (
			@xmlData.value('(/EVENT_INSTANCE/ServerName)[1]', 'nvarchar(100)'), 
			@xmlData.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'nvarchar(128)'), 
			@xmlData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'), 
			@xmlData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2000)'),
			@xmlData.value('(/EVENT_INSTANCE/LoginName)[1]', 'nvarchar(100)'), 
			GETDATE()
			)

GO