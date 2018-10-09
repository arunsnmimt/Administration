--http://blogs.techrepublic.com.com/datacenter/?p=466&tag=nl.e040

SELECT      dp.class_desc, dp.permission_name, dp.state_desc,ObjectName = OBJECT_NAME(major_id), GranteeName = grantee.name, GrantorName = grantor.name 
FROM sys.database_permissions dp JOIN sys.database_principals grantee 
on dp.grantee_principal_id = grantee.principal_id 
JOIN sys.database_principals grantor 
on dp.grantor_principal_id = grantor.principal_id

-- role membership

SELECT p.name, p.type_desc, pp.name, pp.type_desc, pp.is_fixed_role
FROM sys.database_role_members roles JOIN sys.database_principals p 
ON roles.member_principal_id = p.principal_id
JOIN sys.database_principals pp 
ON roles.role_principal_id = pp.principal_id


-- SQL Server 2000 - The sysprotects system table reports all of the permissions granted or denied in a given database.

SELECT 
    su.name AS 'User'
  , CASE sp.protecttype
      WHEN 204 THEN 'GRANT w/ GRANT'
      WHEN 205 THEN 'GRANT'
      WHEN 206 THEN 'DENY' END AS 'Permission'
  , CASE sp.action
      WHEN 26 THEN 'REFERENCES'
      WHEN 193 THEN 'SELECT'
      WHEN 195 THEN 'INSERT'
      WHEN 196 THEN 'DELETE'
      WHEN 197 THEN 'UPDATE'
      WHEN 224 THEN 'EXECUTE' END AS 'Action'
  , so.name AS 'Object'
FROM sysprotects sp
  INNER JOIN sysusers su
    ON sp.uid = su.uid
  INNER JOIN sysobjects so
    ON sp.id = so.id
WHERE sp.action IN (26, 193, 195, 196, 197, 224) 
ORDER BY su.name, so.name;

-- SQL Server 2000 - Using sp_helprotect

--EXEC sp_helprotect @name = 'CENTRE1\Andy.Normington';