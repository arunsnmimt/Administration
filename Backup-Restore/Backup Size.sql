USE [AllianceBootsNewModel]
GO 
EXEC sp_spaceused @updateusage = 'true' 

/*
database_name                         database_size      unallocated space
------------------------------------- ------------------ ------------------
SQLCLR_Examples                       6031.50 MB         4326.55 MB


reserved           data               index_size         unused
------------------ ------------------ ------------------ ------------------
988624 KB          944216 KB          43200 KB           1208 KB


reserved size should similar to a uncompressed backup size

*/



