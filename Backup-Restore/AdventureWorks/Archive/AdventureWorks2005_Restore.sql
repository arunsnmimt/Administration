DECLARE @RestoreString AS VarChar(100);

SET @RestoreString = '\\VBOXSVR\c_drive\Files\Dropbox\SQL Server Backups\VBOXWIN2008R2\AdventureWorks.bak'

RESTORE DATABASE AdventureWorks FROM DISK = @RestoreString