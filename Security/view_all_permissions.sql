WITH    perms_cte AS
(
        SELECT USER_NAME(p.grantee_principal_id) AS principal_name,
                dp.principal_id,
                dp.type_desc AS principal_type_desc,
                p.class_desc,
                OBJECT_NAME(p.major_id) AS OBJECT_NAME,
                p.permission_name,
                p.state_desc AS permission_state_desc 
        FROM    sys.database_permissions p
        INNER   JOIN sys.database_principals dp
        ON     p.grantee_principal_id = dp.principal_id
)

--users

SELECT p.principal_name,  p.principal_type_desc, p.class_desc, p.[object_name], p.permission_name, p.permission_state_desc, CAST(NULL AS sysname) AS role_name, NULL
FROM    perms_cte p
WHERE   principal_type_desc <> 'DATABASE_ROLE'
UNION

--role members

SELECT rm.member_principal_name, rm.principal_type_desc, p.class_desc, p.object_name, p.permission_name, p.permission_state_desc,rm.role_name, 'EXEC sp_addrolemember N'''+rm.role_name+''', N'''+rm.member_principal_name+'''' as rolecommand
FROM    perms_cte p
RIGHT OUTER JOIN (
    SELECT role_principal_id, dp.type_desc AS principal_type_desc, member_principal_id,USER_NAME(member_principal_id) AS member_principal_name,USER_NAME(role_principal_id) AS role_name--,*
    FROM    sys.database_role_members rm
    INNER   JOIN sys.database_principals dp
    ON     rm.member_principal_id = dp.principal_id
) rm

ON     rm.role_principal_id = p.principal_id

ORDER BY 1

