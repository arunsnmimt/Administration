USE [Admin_DBA]
GO
/****** Object:  Table [dbo].[LogonAuditing]    Script Date: 03/25/2013 15:50:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[LogonAuditing]') AND TYPE IN (N'U'))
BEGIN
	CREATE TABLE [dbo].[LogonAuditing](
		[ID] [INT] IDENTITY(1,1) NOT NULL,
		[SessionId] [INT] NULL,
		[LogonTime] [DATETIME] NULL,
		[EventType] [VARCHAR](50) NULL,
		[HostName] [VARCHAR](50) NULL,
		[ProgramName] [VARCHAR](500) NULL,
		[LoginName] [VARCHAR](50) NULL,
		[LoginType] [VARCHAR](50) NULL,
		[ClientHost] [VARCHAR](50) NULL,
	 CONSTRAINT [PK_LogonAuditing] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO


USE Master
GO

IF EXISTS (SELECT * FROM sys.server_triggers where name = 'LogonAuditTrigger')
BEGIN
	DROP TRIGGER LogonAuditTrigger ON ALL SERVER	
END

GO

-- Creating DDL trigger for logon
CREATE TRIGGER LogonAuditTrigger
ON ALL SERVER WITH EXECUTE AS 'sa'
FOR LOGON
AS
BEGIN
	DECLARE @LogonTriggerData XML,
			@EventTime DATETIME,
			@EventType VARCHAR(50),
			@LoginName VARCHAR(50),
			@ClientHost VARCHAR(50),
			@LoginType VARCHAR(50),
			@HostName VARCHAR(50),
			@AppName VARCHAR(500)
	 
	SET @LogonTriggerData = eventdata()
	 
	SET @EventTime = @LogonTriggerData.value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime')
	SET @EventType = @LogonTriggerData.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)')
	SET @LoginType = @LogonTriggerData.value('(/EVENT_INSTANCE/LoginType)[1]', 'varchar(50)')
	SET @LoginName = @LogonTriggerData.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(50)')
	SET @ClientHost = @LogonTriggerData.value('(/EVENT_INSTANCE/ClientHost)[1]', 'varchar(50)')
	SET @HostName = HOST_NAME()
	SET @AppName = APP_NAME()--,program_name()
	
--	IF (LEN(@HostName) = 6  AND LEFT(@HostName,3) = 'MCS' AND ISNUMERIC(RIGHT(@HostName,3))=1 AND @LoginName IN ('TMC','sa')) --OR 
--	IF (LEN(@HostName) = 6  AND LEFT(@HostName,3) = 'MCS' AND ISNUMERIC(RIGHT(@HostName,3))=1 AND @LoginName IN ('TMC'))
--	IF (LEN(@HostName) = 6  AND LEFT(@HostName,3) = 'MCS' AND ISNUMERIC(RIGHT(@HostName,3))=1 AND (LEFT(@AppName, 38) <> 'Microsoft SQL Server Management Studio')) OR 

	IF (LEN(@HostName) = 6  AND LEFT(@HostName,3) = 'MCS' AND ISNUMERIC(RIGHT(@HostName,3))=1 AND @LoginName IN ('TMC')) OR
	   UPPER(LEFT(@HostName,11)) = 'MLCLUSTERVS'  OR
	   UPPER(LEFT(@HostName,9))  = 'TITANICVS' OR
	   UPPER(LEFT(@HostName,9))  = 'PANTHERVS' OR
	   UPPER(LEFT(@HostName,8))  = 'FALCONVS' OR
	   UPPER(LEFT(@HostName,8))  = 'ZODIACVS' OR
	   UPPER(LEFT(@HostName,9))  = 'ELECTRAVS' OR
	   UPPER(LEFT(@HostName,8))  = 'BOUNTYVS' OR
	   UPPER(LEFT(@HostName,12)) = 'NIGHTSHADEVS' OR
	   UPPER(LEFT(@HostName,7))  = 'PINTAVS' OR
	   UPPER(LEFT(@HostName,7))  = 'VIPERVS' OR
	   UPPER(LEFT(@HostName,9))  = 'WARRIORVS' 
							
	BEGIN
		BEGIN TRY
			INSERT INTO Admin_DBA.dbo.LogonAuditing
			(
				SessionId,
				LogonTime,
				EventType,
				HostName,
				ProgramName,
				LoginName,
				LoginType,
				ClientHost
			)
				SELECT
				@@SPID,
				@EventTime,
				@EventType,
				@HostName,
				@AppName,
				@LoginName,
				@LoginType,
				@ClientHost
		END TRY
		BEGIN CATCH
			do_nothing:
		END CATCH
	END
	
	 
/*
	IF @LoginName = 'TMC' 
	   AND (LEFT(@AppName, 38) = 'Microsoft SQL Server Management Studio' OR
	       (LEN(@HostName) = 6  AND LEFT(@HostName,3) = 'MCS' AND ISNUMERIC(RIGHT(@HostName,3))=1) )
	BEGIN
		BEGIN TRY
--			ROLLBACK
			INSERT INTO Admin_DBA.dbo.LogonAuditing
			(
				SessionId,
				LogonTime,
				EventType,
				HostName,
				ProgramName,
				LoginName,
				LoginType,
				ClientHost
			)
				SELECT
				@@SPID,
				@EventTime,
				@EventType,
				@HostName,
				@AppName,
				@LoginName,
				@LoginType,
				@ClientHost
		END TRY

		BEGIN CATCH
			--INSERT INTO Admin_DBA.dbo.LogonAuditing
			--(
			--ProgramName
			--) VALUES ('Failed')
			-- Do Nothing
		END CATCH
	 END
*/	 
END
GO

USE master
SELECT OBJECT_DEFINITION ([object_id]), * FROM sys.server_triggers

-- DISABLE TRIGGER LogonAuditTrigger ON ALL SERVER	


/*
DROP TRIGGER LogonAuditTrigger
ON ALL SERVER
*/

--/*
--USE Admin_DBA
--GO
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
---- =============================================
---- Author:		<Author,,Name>
---- Create date: <Create Date,,>
---- Description:	<Description,,>
---- =============================================
--CREATE TRIGGER trg_Retreive_DatabaseName
--   ON  dbo.LogonAuditing
--   AFTER  INSERT
--AS 
--BEGIN
--	-- SET NOCOUNT ON added to prevent extra result sets from
--	-- interfering with SELECT statements.
--	SET NOCOUNT ON;
	
----	WAITFOR DELAY '00:00:00.5'
	
--	UPDATE LA
--	SET DatabaseName =	(SELECT DB_NAME(dbid) FROM sys.sysprocesses sys WHERE spid IN (SELECT SessionId FROM inserted))
--	FROM LogonAuditing LA INNER JOIN  inserted INS
--	ON LA.ID = INS.ID

--END
--GO
--*/

--/*

--USE [Admin_DBA]
--GO

--/****** Object:  Trigger [trg_Retreive_DatabaseName]    Script Date: 05/09/2014 16:27:07 ******/
--IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_Retreive_DatabaseName]'))
--DROP TRIGGER [dbo].[trg_Retreive_DatabaseName]
--GO
--*/
