PRINT LEFT(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)-1)

DECLARE @BackupString AS VarChar(100);
SET @BackupString = REPLACE(CONVERT(Varchar(30),GETDATE(),120),':','');
SET @BackupString = REPLACE(@BackupString,' ','_');
SET @BackupString = REPLACE(@BackupString,'-','');
SET @BackupString = '\\VBOXSVR\freenas_files\Backups\SQL Server\VBOXWIN2008R2\AdventureWorks2012_' + @BackupString + '.bak';

BACKUP DATABASE AdventureWorks2012 to DISK = @BackupString WITH  NOFORMAT, INIT, COMPRESSION, NAME = N'AdventureWorks2012-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;

SET @BackupString = '\\VBOXSVR\c_drive\Files\Dropbox\SQL Server Backups\VBOXWIN2008R2\AdventureWorks2012.bak';

BACKUP DATABASE AdventureWorks2012 to DISK = @BackupString WITH  NOFORMAT, INIT, COMPRESSION, NAME = N'AdventureWorks2012-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;