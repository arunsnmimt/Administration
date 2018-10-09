USE master
GO

EXEC sp_configure 'allow updates', 0
RECONFIGURE

EXEC sp_configure 'show advanced option', '1';
RECONFIGURE

EXEC sp_configure