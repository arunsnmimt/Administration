
USE [master];
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'TEST')
	CREATE DATABASE TEST;
GO


USE [TEST];
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T1]') AND type in (N'U'))
	DROP TABLE [dbo].[T1];
GO

USE [TEST];
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T1]') AND type in (N'U'))
	DROP TABLE [dbo].[T1];
GO

CREATE TABLE [dbo].[T1]
(
	[c1] [int] IDENTITY(1,1) NOT NULL,
	[c2] [int] NOT NULL, PRIMARY KEY CLUSTERED([c1] ) 
);


INSERT T1 (c2) VALUES (10);
INSERT T1 (c2) VALUES (20);
INSERT T1 (c2) VALUES (30);
INSERT T1 (c2) VALUES (40);
INSERT T1 (c2) VALUES (50);
INSERT T1 (c2) VALUES (60);


/* Blocker */
-- Perform an UPDATE while leaving the transaction open so that the exclusive (X) lock aquired by the 
-- process does not get released making this process becoming a blocker as soon as any 
-- connection will try to perform any operation (read/ write) against the aquired resource 
-- (the index KEY on the fifth row (WHERE c1 = 5) )
USE [TEST];
BEGIN TRAN; UPDATE T1 SET c2 = 100 WHERE c1 = 5;
--ROLLBACK


/* Blocked */
USE [TEST]; SELECT * FROM TEST..T1 /* connection 1 */ ;
USE [TEST]; SELECT * FROM TEST..T1 /* connection 2 */ ;
USE [TEST]; SELECT * FROM TEST..T1 /* connection 3 */ ;
USE [TEST]; SELECT * FROM TEST..T1 /* connection 4 */ ;
USE [TEST]; SELECT * FROM TEST..T1 /* connection 5 */ ;


-- You can see that all blocked processes are waiting to be granted the resource (a KEY in this case) 
-- aquired/ held by the Lead Blocker process returned in the first reslut set.










