
Print 'Tables'
Print ''

select name from sysobjects
where xtype = 'U'
Order by name

Print 'Views'
Print ''

select name from sysobjects
where xtype = 'V'

Print 'Stored Procedures'
Print ''

select name from sysobjects
where xtype = 'P'

SELECT  *
FROM    sys.objects
WHERE type_desc = 'DEFAULT_CONSTRAINT'
AND name = 'DF_tbl_VehicleSH_intscheduleid'

SELECT  *
FROM    sys.objects
WHERE name like 'sp_JourneysToMatchForDay%'
where object_id = 613577224

