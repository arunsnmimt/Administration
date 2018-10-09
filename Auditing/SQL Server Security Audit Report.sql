USE master
GO
SET nocount ON

/* Step 1 - Lists who has 'sa' permissions */

-- Get all roles
CREATE TABLE #temp_srvrole 
(ServerRole VARCHAR(128), Description VARCHAR(128))
INSERT INTO #temp_srvrole
EXEC sp_helpsrvrole

-- sp_help syslogins
CREATE TABLE #temp_memberrole 
(ServerRole VARCHAR(128), 
MemberName VARCHAR(265), 
MemberSID VARCHAR(300))

DECLARE @ServerRole VARCHAR(128)

DECLARE srv_role CURSOR FAST_FORWARD FOR 
SELECT ServerRole FROM #temp_srvrole
OPEN srv_role
FETCH NEXT FROM srv_role INTO @ServerRole

WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO #temp_memberrole
EXEC sp_helpsrvrolemember @ServerRole
FETCH NEXT FROM srv_role INTO @ServerRole
END

CLOSE srv_role
DEALLOCATE srv_role

SELECT ServerRole, MemberName FROM #temp_memberrole

/* Step 2 - List which accounts have local administrator access */

-- IF BUILTIN\Administrators is exist and sysadmin
IF EXISTS(SELECT *FROM #temp_memberrole 
WHERE MemberName = 'BUILTIN\Administrators' 
AND ServerRole = 'sysadmin' )
BEGIN
CREATE TABLE #temp_localadmin (output VARCHAR(8000))
INSERT INTO #temp_localadmin
EXEC xp_cmdshell 'net localgroup administrators'

SELECT output AS local_administrator 
FROM #temp_localadmin
WHERE output LIKE '%\%'
DROP TABLE #temp_localadmin
END

DROP TABLE #temp_srvrole
DROP TABLE #temp_memberrole

/* Step 3 - Lists type of logins that are used */

-- Get individual Logins
SELECT name, 'Individual NT Login' LoginType
FROM syslogins
WHERE isntgroup = 0 AND isntname = 1 
UNION
SELECT name, 'Individual SQL Login' LoginType
FROM syslogins
WHERE isntgroup = 0 AND isntname = 0 
UNION ALL
-- Get Group logins
SELECT name,'NT Group Login' LoginType
FROM syslogins
WHERE isntgroup = 1 


/* Step 4 - If NT groups are being used a list of who is in the groups */

-- get group list
-- EXEC xp_cmdshell 'net group "AnalyticsDev" /domain'
CREATE TABLE #temp_groupadmin 
(output VARCHAR(8000))
CREATE TABLE #temp_groupadmin2 
(groupName VARCHAR(256), groupMember VARCHAR(1000))
DECLARE @grpname VARCHAR(128)
DECLARE @sqlcmd VARCHAR(1000)

DECLARE grp_role CURSOR FAST_FORWARD FOR 
SELECT REPLACE(name,'US\','') 
FROM syslogins 
WHERE isntgroup = 1 AND name LIKE 'US\%'

OPEN grp_role
FETCH NEXT FROM grp_role INTO @grpname

WHILE @@FETCH_STATUS = 0
BEGIN

SET @sqlcmd = 'net group "' + @grpname + '" /domain'
TRUNCATE TABLE #temp_groupadmin

PRINT @sqlcmd 
INSERT INTO #temp_groupadmin
EXEC xp_cmdshell @sqlcmd

SET ROWCOUNT 8
DELETE FROM #temp_groupadmin

SET ROWCOUNT 0

INSERT INTO #temp_groupadmin2
SELECT @grpname, output FROM #temp_groupadmin
WHERE output NOT LIKE ('%The command completed successfully%')

FETCH NEXT FROM grp_role INTO @grpname
END


CLOSE grp_role
DEALLOCATE grp_role

SELECT * FROM #temp_groupadmin2

DROP TABLE #temp_groupadmin
DROP TABLE #temp_groupadmin2

/* Step 5 - Checks to see if any Windows accounts that are in SQL Server no longer exist */

PRINT 'EXEC sp_validatelogins '
PRINT '----------------------------------------------'
EXEC sp_validatelogins
PRINT ''


/* Step 6 - The last part shows if any user is using database roles and which roles */

-- Get all the Database Rols for that specIFic members
CREATE TABLE #temp_rolemember 
(DbRole VARCHAR(128),MemberName VARCHAR(128),MemberSID VARCHAR(1000))
CREATE TABLE #temp_rolemember_final 
(DbName VARCHAR(100), DbRole VARCHAR(128),MemberName VARCHAR(128))

DECLARE @dbname VARCHAR(128)
DECLARE @sqlcmd2 VARCHAR(1000)

DECLARE grp_role CURSOR FOR 
SELECT name FROM sysdatabases
WHERE name NOT IN ('tempdb') 
AND DATABASEPROPERTYEX(name, 'Status') = 'ONLINE' 


OPEN grp_role
FETCH NEXT FROM grp_role INTO @dbname

WHILE @@FETCH_STATUS = 0
BEGIN

TRUNCATE TABLE #temp_rolemember 
SET @sqlcmd2 = 'EXEC [' + @dbname + ']..sp_helprolemember'

PRINT @sqlcmd2 
INSERT INTO #temp_rolemember
EXECUTE(@sqlcmd2)

INSERT INTO #temp_rolemember_final
SELECT @dbname AS DbName, DbRole, MemberName
FROM #temp_rolemember

FETCH NEXT FROM grp_role INTO @dbname
END


CLOSE grp_role
DEALLOCATE grp_role

SELECT * FROM #temp_rolemember_final

DROP TABLE #temp_rolemember
DROP TABLE #temp_rolemember_final 