---------------------------------------------------------------------------------
--*****SCRIPT1 TO CHECK PERMISSIONS LIST*******

-- run before and after script2
---------------------------------------------------------------------------------

WITH    perms_cte as

(

        select USER_NAME(p.grantee_principal_id) AS principal_name,

                dp.principal_id,

                dp.type_desc AS principal_type_desc,

                p.class_desc,

                OBJECT_NAME(p.major_id) AS object_name,

                p.permission_name,

                p.state_desc AS permission_state_desc 

        from    sys.database_permissions p

        inner   JOIN sys.database_principals dp

        on     p.grantee_principal_id = dp.principal_id

)

--users

SELECT p.principal_name,  p.principal_type_desc, p.class_desc, p.[object_name], p.permission_name, p.permission_state_desc, cast(NULL as sysname) as role_name

FROM    perms_cte p

WHERE   principal_type_desc <> 'DATABASE_ROLE'

UNION

--role members

SELECT rm.member_principal_name, rm.principal_type_desc, p.class_desc, p.object_name, p.permission_name, p.permission_state_desc,rm.role_name

FROM    perms_cte p

right outer JOIN (

    select role_principal_id, dp.type_desc as principal_type_desc, member_principal_id,user_name(member_principal_id) as member_principal_name,user_name(role_principal_id) as role_name--,*

    from    sys.database_role_members rm

    INNER   JOIN sys.database_principals dp

    ON     rm.member_principal_id = dp.principal_id

) rm

ON     rm.role_principal_id = p.principal_id

order by 1

---------------------------------------------------------------------------------
--*****SCRIPT2 TO CREATE THE REQUIRED SYNTAX*******

-- when run just right click each result to save to csv, then paste back into
-- a new query so you can run the resulting permissions scripts ;)
---------------------------------------------------------------------------------
SET NOCOUNT ON


DECLARE	@OldUser sysname, @NewUser sysname


SET	@OldUser = 'sqluser1'
SET	@NewUser = 'sqluser99'


SELECT	'USE' + SPACE(1) + QUOTENAME(DB_NAME()) AS '--Database Context'


SELECT	'--Cloning permissions from' + SPACE(1) + QUOTENAME(@OldUser) + SPACE(1) + 'to' + SPACE(1) + QUOTENAME(@NewUser) AS '--Comment'

SELECT	'EXEC sp_addrolemember @rolename =' 
	+ SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''') + ', @membername =' + SPACE(1) + QUOTENAME(@NewUser, '''') AS '--Role Memberships'
FROM	sys.database_role_members AS rm
WHERE	USER_NAME(rm.member_principal_id) = @OldUser
ORDER BY rm.role_principal_id ASC;


with schema_cte as
(select '['+a.name+'].['+b.name+']' as all_name,b.schema_id from sys.schemas a join sys.tables b
on a.schema_id =b.schema_id)

SELECT	CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END
	+ SPACE(1) + perm.permission_name + SPACE(1) + 'ON ' + (cte.all_name)  --QUOTENAME(USER_NAME(obj.schema_id)) + '.' + QUOTENAME(obj.name) 
	+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE '(' + QUOTENAME(cl.name) + ')' END
	+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(@NewUser) COLLATE database_default
	+ CASE WHEN perm.state <> 'W' THEN SPACE(0) ELSE SPACE(1) + 'WITH GRANT OPTION' END AS '--Object Level Permissions'
FROM	sys.database_permissions AS perm
	INNER JOIN
	sys.objects AS obj
	ON perm.major_id = obj.[object_id]
	INNER JOIN
	sys.database_principals AS usr
	ON perm.grantee_principal_id = usr.principal_id
	LEFT JOIN
	sys.columns AS cl
	ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id

	join schema_cte as cte
	on cte.schema_id=obj.schema_id

WHERE	usr.name = @OldUser
ORDER BY perm.permission_name ASC, perm.state_desc ASC


SELECT	CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END
	+ SPACE(1) + perm.permission_name + SPACE(1)
	+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(@NewUser) COLLATE database_default
	+ CASE WHEN perm.state <> 'W' THEN SPACE(0) ELSE SPACE(1) + 'WITH GRANT OPTION' END AS '--Database Level Permissions'
FROM	sys.database_permissions AS perm
	INNER JOIN
	sys.database_principals AS usr
	ON perm.grantee_principal_id = usr.principal_id
WHERE	usr.name = @OldUser
AND	perm.major_id = 0
ORDER BY perm.permission_name ASC, perm.state_desc ASC

