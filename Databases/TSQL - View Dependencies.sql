
with ViewRoots as(
select id, 'T' as type,name, convert(varchar(1000),name) as root
	from sys.sysobjects
	where xtype = 'U'
UNION ALL
select SD.id, 'V',SO.name,convert(varchar(1000),root+' -> '+SO.name)
	from ViewRoots VR
		inner join sys.sysdepends SD
			on SD.depid = VR.id
		inner join sys.sysobjects SO
			on SO.id = SD.id
		where xtype='V'
)
select distinct * from ViewRoots
	order by root;
