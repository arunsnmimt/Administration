/*
When you change the name of the computer that is running SQL Server, the new name is recognized during SQL Server startup. You do not have to run Setup again to reset the computer name. Instead, use the following steps to update system metadata that is stored in sys.servers and reported by the system function @@SERVERNAME:

*/

sp_dropserver 'WIN-I1MEKS4SE8R\SQL2014'
GO
sp_addserver 'VBOXWIN2012R2\SQL2014', local;
GO

sp_dropserver 'WIN-I1MEKS4SE8R\SQL2012'
GO
sp_addserver 'VBOXWIN2012R2\SQL2012', local;
GO
