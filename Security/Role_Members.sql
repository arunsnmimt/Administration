	SELECT USERName, REPLACE(USERName, 'BROXTOWE\','') + ';', RoleName
	from (
       select b.name as USERName, c.name as RoleName 
      	from Compliance_Audit.dbo.sysmembers a 	join Compliance_Audit.dbo.sysusers  b 	on a.memberuid = b.uid 	join Compliance_Audit.dbo.sysusers c
	         on a.groupuid = c.uid ) s 	
	         WHERE RoleName = 'Audit_Users'
	         Order By RoleName, USERName
/*

CREATE TABLE #DBROLES 
( DBName sysname NOT NULL, 
  UserName sysname NOT NULL, 
  db_owner VARCHAR(3) NOT NULL,
  db_accessadmin VARCHAR(3) NOT NULL,
  db_securityadmin VARCHAR(3) NOT NULL,
  db_ddladmin VARCHAR(3) NOT NULL,
  db_datareader VARCHAR(3) NOT NULL,
  db_datawriter VARCHAR(3) NOT NULL,
  db_denydatareader VARCHAR(3) NOT NULL,
  db_denydatawriter VARCHAR(3) NOT NULL,
  Cur_Date	DATETIME NOT NULL DEFAULT GETDATE() 
)


DECLARE @dbname VARCHAR(200)
DECLARE @mSql1	VARCHAR(8000)


DECLARE DBName_Cursor CURSOR FOR 
 SELECT name 
	FROM	master.dbo.sysdatabases 
	WHERE name NOT IN ('mssecurity','tempdb')
	ORDER BY name

OPEN DBName_Cursor

FETCH NEXT FROM DBName_Cursor INTO @dbname

WHILE @@FETCH_STATUS = 0
 BEGIN
  SET @mSQL1 = '	Insert into #DBROLES ( DBName, UserName, db_owner, db_accessadmin, 
                  db_securityadmin, db_ddladmin, db_datareader, db_datawriter,
	               db_denydatareader, db_denydatawriter )
	SELECT '+''''+@dbName +''''+ ' as DBName ,UserName, '+CHAR(13)+	'	
    Max(CASE RoleName WHEN ''db_owner''  	 THEN ''Yes'' ELSE ''No'' END) AS db_owner,
	 Max(CASE RoleName WHEN ''db_accessadmin ''   THEN ''Yes'' ELSE ''No'' END) AS db_accessadmin ,
	 Max(CASE RoleName WHEN ''db_securityadmin''  THEN ''Yes'' ELSE ''No'' END) AS db_securityadmin,
	 Max(CASE RoleName WHEN ''db_ddladmin''  	 THEN ''Yes'' ELSE ''No'' END) AS db_ddladmin,
	 Max(CASE RoleName WHEN ''db_datareader''  	 THEN ''Yes'' ELSE ''No'' END) AS db_datareader,
	 Max(CASE RoleName WHEN ''db_datawriter''  	 THEN ''Yes'' ELSE ''No'' END) AS db_datawriter,
    Max(CASE RoleName WHEN ''db_denydatareader'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatareader,
	 Max(CASE RoleName WHEN ''db_denydatawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatawriter
	from (
       select b.name as USERName, c.name as RoleName 
      	from ' + @dbName+'.dbo.sysmembers a '+CHAR(13)+ 
			'	join '+ @dbName+'.dbo.sysusers  b '+CHAR(13)+
       	'	on a.memberuid = b.uid 	join '+@dbName +'.dbo.sysusers c
	         on a.groupuid = c.uid )s 	
		   Group by USERName 
         order by UserName'

  Print @mSql1
  EXECUTE (@mSql1)

  FETCH NEXT FROM DBName_Cursor INTO @dbname
 END



CLOSE DBName_Cursor
DEALLOCATE DBName_Cursor

SELECT * FROM #DBROLES

GO
      	
      	
      	*/
      	