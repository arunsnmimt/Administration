USE master
GO 
SELECT name as SQLServerLogIn,SID as SQLServerSID FROM sys.syslogins
WHERE  [name] IN ('TMC','Tier1','Tier2','DeliveryTier1','DeliveryTier2','DevTier1','DevTier2')
ORDER BY [name]
GO

USE TMC_Reports_NFT_MG
GO 
SELECT name DataBaseID,SID as DatabaseSID FROM sysusers
WHERE  [name] IN ('TMC','Tier1','Tier2','DeliveryTier1','DeliveryTier2','DevTier1','DevTier2')
ORDER BY [name]
GO

--USE TMC_IVECO
--GO 
--SELECT name DataBaseID,SID as DatabaseSID FROM sysusers
--WHERE [name] = 'TMC'
--GO



/*
	Users which have not a login
*/

USE TMC_TESCO_UAT_ME

SELECT  *
FROM   sys.database_principals 
WHERE name NOT IN (SELECT name COLLATE SQL_Latin1_General_CP1_CI_AS
						FROM master.sys.server_principals)
	AND is_fixed_role = 0
	AND principal_id > 4
WHERE owning_principal_id IS NULL

/*
	Obtain HASH password for login
*/

SELECT  sl.name, sl.password_hash --, sp.[sid] --, 'CREATE LOGIN ' + sl.name + ' WITH PASSWORD = ' + sl.password_hash + ' HASH, SID = ' +s p.[sid]
FROM    master.sys.sql_logins sl INNER JOIN master.sys.server_principals sp
ON sl.principal_id = sp.principal_id
where sl.name IN ('sitemaster','S-Nex2Nav')

USE master
CREATE LOGIN SiteMaster WITH PASSWORD = 0x01009E3F42BABEC8F624A8276906891CF1C57671FBC5A23132DF HASHED
CREATE LOGIN S-Nex2Nav WITH PASSWORD = 0x01005044C7B64B1F3D52809D954058FA4B2B457D5C54B5A9501D HASHED

 --, SID = 0x260509CB5E24B44785247A9DBAC0946B


--CREATE LOGIN TMCREP WITH PASSWORD = 0x0100070CED9D9FB0AE95965E4660591FE406055B767255965317 HASHED, SID = 0x09003E256EABC34F8F92BD4431DBEBF5


			
		

		



/* Lists Orphaned Users */
--sp_change_users_login @Action='Report'

EXEC sp_change_users_login 'Auto_Fix', 'DevTier1'
GO

EXEC sp_change_users_login 'Auto_Fix', 'DevTier2'
GO

EXEC sp_change_users_login 'Auto_Fix', 'TMC'
GO


EXEC sp_change_users_login 'Auto_Fix', 'DeliveryTier1'
GO

EXEC sp_change_users_login 'Auto_Fix', 'DeliveryTier2'
GO


EXEC sp_change_users_login 'Auto_Fix', 'Tier1'
GO

EXEC sp_change_users_login 'Auto_Fix', 'Tier2'
GO

EXEC sp_change_users_login 'Auto_Fix', 'DBAReadRep'
GO


/*

USE TMC_TESCO_COM
GO 
SELECT 'CREATE LOGIN ' + name + ' WITH PASSWORD = '''', SID = ' FROM sysusers
WHERE [name] IN ('Tier1','Tier2','DeliveryTier1','DeliveryTier2','DevTier1','DevTier2')
GO

*/



/*

--#region Script to create logins

USE master

CREATE LOGIN TMC with PASSWORD = 'TMC', SID = 0xF106BCDC8B350E459C470515EDED0800
CREATE LOGIN DeliveryTier1 WITH PASSWORD = 'DT!er1', SID = 0x3E4F4E04ECDAE84F8E7250FB3B8406E0
CREATE LOGIN DeliveryTier2 WITH PASSWORD = 'D3T!er2', SID = 0x8EB1128B5C94274B9B1037D07330F6A0
CREATE LOGIN DevTier1 WITH PASSWORD = 'DevT!er1', SID = 0xDD07209E3E96FA45869111CF1024423D
CREATE LOGIN DevTier2 WITH PASSWORD = 'DevT2er2', SID = 0xB73AE54A047856419942090670D1CE76
CREATE LOGIN Tier1 WITH PASSWORD = 'T1er1', SID = 0xD01043FD4ABCD6488562CBF5632DF6EF
CREATE LOGIN Tier2 WITH PASSWORD = 'T!er2', SID = 0xB925F5FF5D755B44B7278ABA2533B23C

--#endregion

*/

/*
DeliveryTier1	0x3E4F4E04ECDAE84F8E7250FB3B8406E0
DeliveryTier2	0x8EB1128B5C94274B9B1037D07330F6A0
DevTier1	0xDD07209E3E96FA45869111CF1024423D
DevTier2	0xB73AE54A047856419942090670D1CE76
Tier1	0xD01043FD4ABCD6488562CBF5632DF6EF
Tier2	0xB925F5FF5D755B44B7278ABA2533B23C
*/
