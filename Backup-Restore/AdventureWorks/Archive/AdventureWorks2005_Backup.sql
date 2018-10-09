DECLARE @BackupString AS VarChar(100);
SET @BackupString = REPLACE(CONVERT(Varchar(30),GETDATE(),120),':','');
SET @BackupString = REPLACE(@BackupString,' ','_');
SET @BackupString = REPLACE(@BackupString,'-','');
SET @BackupString = '\\VBOXSVR\freenas_files\Backups\SQL Server\VBOXWIN2008R2\AdventureWorks_' + @BackupString + '.bak';

BACKUP DATABASE AdventureWorks to DISK = @BackupString WITH  NOFORMAT, INIT, NAME = N'AdventureWorks-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;

SET @BackupString = '\\VBOXSVR\c_drive\Files\Dropbox\SQL Server Backups\VBOXWIN2008R2\AdventureWorks.bak';

BACKUP DATABASE AdventureWorks to DISK = @BackupString WITH  NOFORMAT, INIT, NAME = N'AdventureWorks-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;