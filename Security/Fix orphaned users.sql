--Fix orphaned users after restoring database to another server

EXEC sp_change_users_login 'UPDATE_ONE', 'Tier1','Tier1'
EXEC sp_change_users_login 'UPDATE_ONE', 'Tier2','Tier2'

EXEC sp_change_users_login 'UPDATE_ONE', 'TMC','TMC'
EXEC sp_change_users_login 'UPDATE_ONE', 'DeliveryTier1','DeliveryTier1'
EXEC sp_change_users_login 'UPDATE_ONE', 'DeliveryTier2','DeliveryTier2'
EXEC sp_change_users_login 'UPDATE_ONE', 'DevTier1','DevTier1'
EXEC sp_change_users_login 'UPDATE_ONE', 'DevTier2','DevTier2'







EXEC sp_change_users_login 'Auto_Fix', 'DBAReadRep'
GO

Declare @ExecStr varchar(256)
Declare @UserName varchar(256)

Create table #Orphanage(UserName varchar(256))

insert #Orphanage(UserName)
select UserName = name  from sysusers
where issqluser = 1 and (sid is not null and sid <> 0x0)
and suser_sname(sid) is null
--and name <> 'dbo'
--and name in ('Tier1','Tier2')
and name in ('SiteMaster','S-Nex2Nav')

DECLARE Adopt_them CURSOR
 FOR select UserName from #Orphanage

OPEN Adopt_them

FETCH NEXT FROM Adopt_them into @UserName


WHILE @@FETCH_STATUS = 0
 begin
  set @ExecStr='EXEC sp_change_users_login ''UPDATE_ONE'', ''' + @UserName +''',''' + @UserName +''''
  execute(@ExecStr)
  print @UserName + '  Updated'
  FETCH NEXT FROM Adopt_them into @UserName
 end


CLOSE Adopt_them
DEALLOCATE Adopt_them

DROP TABLE #Orphanage