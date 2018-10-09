USE master
GO
CHECKPOINT
GO
DBCC DROPCLEANBUFFERS
GO
DBCC FREEPROCCACHE
GO
DBCC FREESYSTEMCACHE ('ALL')
GO
DBCC FREESESSIONCACHE
GO
USE [tempdb]; DBCC SHRINKFILE(tempdev, 256)
GO

select * from sys.databases