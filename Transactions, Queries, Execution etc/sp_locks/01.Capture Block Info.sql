/*

	Save blocking information to table for troubleshooting and analysis.
	    
	19/04/2008 Yaniv Etrogi   
	http://www.sqlserverutilities.com	

*/    

USE [tempdb];
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Blocks]') AND type in (N'U'))
	DROP TABLE [dbo].[Blocks];
GO

CREATE TABLE [dbo].[Blocks](
	[Id] [int] identity(1,1) NOT NULL CONSTRAINT [PK_Blocks] PRIMARY KEY NONCLUSTERED ([Id]),
	[InsertTime] datetime CONSTRAINT [DF_Blocks_InsertTime] DEFAULT (getdate()) NOT NULL,
	[blocking] smallint NULL,
	[blocked] smallint NULL,
	[program_blocking] varchar(128) NULL,
	[program_blocked] varchar(128) NULL,
	[database] varchar(128) NULL,
	[host_blocking] varchar(128) NOT NULL,
	[host_blocked] varchar(128) NOT NULL,
	[wait_duration_ms] bigint NULL,
	[request_mode] varchar(60) NOT NULL,
	[resource_type] varchar(60) NOT NULL,
	[wait_type] varchar(60) NULL,
	[statement_blocked] varchar(max) NULL,
	[statement_blocking] varchar(max) NULL );
GO

CREATE CLUSTERED INDEX IXC_Blocks_InsertTime ON dbo.Blocks (InsertTime);



-- Loop infinity until you manually stop execution or modify the WHILE condition.
SET NOCOUNT ON;
DECLARE @i int; SELECT @i = 0;

WHILE (@i < 1000000)
BEGIN;
INSERT INTO [dbo].[Blocks]
           ([blocking]
           ,[blocked]
           ,[program_blocking]
           ,[program_blocked]
           ,[database]
           ,[host_blocking]
           ,[host_blocked]
           ,[wait_duration_ms]
           ,[request_mode]
           ,[resource_type]
           ,[wait_type]
           ,[statement_blocked]
           ,[statement_blocking])
EXEC sp_Locks @Wait_Duration_ms = 1000, @Mode = 1;

SELECT @i = @i + 1;
IF @i % 100 = 0 PRINT @i;  --print every 100 iterations 
WAITFOR DELAY '00:00:10';  --10 seconds sleep
END;



-- Retreive the blocking data captured.
SET NOCOUNT ON; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT TOP 100
			 [Id]
			,[InsertTime] 
			,[blocking]
      ,[blocked]
      ,LEFT([program_blocking], 20) AS [program_blocking]
      ,LEFT([program_blocked], 20)  AS [program_blocked]
      ,[database]
      ,[host_blocking]
      ,[host_blocked]
      ,[wait_duration_ms]
      ,[request_mode]
      ,[resource_type]
      ,[wait_type]
      ,[statement_blocked]
      ,[statement_blocking]
FROM	[dbo].[Blocks]
ORDER BY [InsertTime] DESC;
