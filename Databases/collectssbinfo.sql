use tempdb;
GO

----------------------------------------------------
-- 
-- Copyright (c) Microsoft Corporation.
--
----------------------------------------------------

-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_services
-- PURPOSE: lists all services in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_services')
begin
	drop procedure sp_ssb_show_services
end
GO

create procedure sp_ssb_show_services
	@dbname nvarchar(128),
	@xmlresults xml output
AS
BEGIN
	declare @sql nvarchar(MAX);
	select @sql = 'select @xmlresults = (select 
		s.service_id as [@service_id],
		s.name as service,
		u.name as owner,
		q.name as queue 
		from ' + QUOTENAME(@dbname) + N'.sys.services s
		left outer join ' + QUOTENAME(@dbname) + N'.sys.database_principals u on s.principal_id = u.principal_id
		left outer join ' + QUOTENAME(@dbname) + N'.sys.service_queues q on s.service_queue_id = q.object_id
		for xml path(''service''));';
	exec sp_executesql @sql, N'@xmlresults XML output', @xmlresults output;
END
GO

-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_queues
-- PURPOSE: lists all queues in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_queues')
begin
	drop procedure sp_ssb_show_queues
end
GO

create procedure sp_ssb_show_queues
	@dbname nvarchar(128),
	@xmlresults xml output
AS
BEGIN
	declare @sql nvarchar(MAX);
	select @sql = 'select @xmlresults = (select q.object_id as [@queue_id],
		s.name as [schema],
		q.name,
		q.is_receive_enabled as [status],
		q.is_retention_enabled as [retention],
		row_count = (select p.rows 
			from ' + QUOTENAME(@dbname) + '.sys.internal_tables as it
				join ' + QUOTENAME(@dbname) + '.sys.indexes as i on 
					i.object_id = it.object_id 
					and i.index_id = 1
				join ' + QUOTENAME(@dbname) + '.sys.partitions as p 
					on p.object_id = i.object_id 
					and p.index_id = i.index_id
			where it.parent_id = q.object_id
				and it.internal_type = 201),
		q.activation_procedure as [activation/procedure],
		p.name as [activation/execute_as],
		case when q.activation_procedure is null
			then NULL
			else q.is_activation_enabled
		end
		as [activation/status],
		case when q.activation_procedure is null
			then NULL
			else q.max_readers
		end
		as [activation/readers]
		from ' + QUOTENAME(@dbname) + '.sys.service_queues q
			join ' + QUOTENAME(@dbname) + '.sys.schemas s on q.schema_id = s.schema_id
			left outer join ' + QUOTENAME(@dbname) + '.sys.database_principals p on q.execute_as_principal_id = p.principal_id
		for xml path(''queue''));';
	exec sp_executesql @sql, N'@xmlresults XML output', @xmlresults output;
END
GO

-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_rsbs
-- PURPOSE: lists all RSBs in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_rsbs')
begin
	drop procedure sp_ssb_show_rsbs
end
GO

create procedure sp_ssb_show_rsbs
	@dbname nvarchar(128),
	@xmlresults xml output
AS
BEGIN
	declare @sql nvarchar(MAX);
	select @sql = 'select @xmlresults = (select rsb.remote_service_binding_id as [@remote_service_binding_id],
		rsb.name,
		rsb.remote_service_name,
		p.name as remote_principal,
		rsb.is_anonymous_on
	 from ' + QUOTENAME(@dbname) + '.sys.remote_service_bindings rsb
		join ' + QUOTENAME(@dbname) + '.sys.database_principals p on p.principal_id = rsb.remote_principal_id
		for xml path(''remote_service_binding''));';
	exec sp_executesql @sql, N'@xmlresults XML output', @xmlresults output;
END
GO

-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_routes
-- PURPOSE: lists all routes in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_routes')
begin
	drop procedure sp_ssb_show_routes
end
GO

create procedure sp_ssb_show_routes
	@dbname nvarchar(128),
	@xmlresults xml output
AS
BEGIN
	declare @sql nvarchar(MAX);
	select @sql = 'select @xmlresults = (select r.route_id as [@route_id],
		r.name,
		r.remote_service_name, 
		r.broker_instance,
		r.address,
		r.mirror_address
	from ' + QUOTENAME(@dbname) + '.sys.routes r
		for xml path(''route''));';
	exec sp_executesql @sql, N'@xmlresults XML output', @xmlresults output;
END
GO

-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_certificates
-- PURPOSE: lists all routes in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_certificates')
begin
	drop procedure sp_ssb_show_certificates
end
GO

create procedure sp_ssb_show_certificates
	@dbname nvarchar(128),
	@xmlresults xml output
AS
BEGIN
	declare @sql nvarchar(MAX);
	select @sql = 'select @xmlresults = (select c.certificate_id as [@certificate_id],
		c.name,
		p.name as owner,
		c.is_active_for_begin_dialog,
		c.pvt_key_encryption_type_desc,
		c.issuer_name as [issuer/name],
		c.cert_serial_number as [issuer/serial_number],
		c.thumbprint
	from ' + QUOTENAME(@dbname) + '.sys.certificates c
			left outer join ' + QUOTENAME(@dbname) + '.sys.database_principals p on c.principal_id = p.principal_id
		for xml path(''certificate''));';
	exec sp_executesql @sql, N'@xmlresults XML output', @xmlresults output;
END
GO

-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_queue_permissions
-- PURPOSE: lists all GRANTs/DENYs pertinent to queues in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_queue_permissions')
begin
	drop procedure sp_ssb_show_queue_permissions
end
GO

create procedure sp_ssb_show_queue_permissions
	@dbname nvarchar(128),
	@xmlresults xml output
AS
BEGIN
	declare @sql nvarchar(MAX);
	select @sql = 'select @xmlresults = (select q.object_id as [@queue_id],
		q.name as queue,
		u.name as grantee,
		permission_name, state_desc
		from ' + QUOTENAME(@dbname) + N'.sys.database_permissions p
		left outer join ' + QUOTENAME(@dbname) + '.sys.database_principals u on p.grantee_principal_id = u.principal_id
		join ' + QUOTENAME(@dbname) + N'.sys.service_queues q
			on p.major_id = q.object_id and p.class = 1 and p.minor_id = 0
		for xml path(''permission''));';
	exec sp_executesql @sql, N'@xmlresults XML output', @xmlresults output;
END
GO

-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_service_permissions
-- PURPOSE: lists all GRANTs/DENYs pertinent to services in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_service_permissions')
begin
	drop procedure sp_ssb_show_service_permissions
end
GO

create procedure sp_ssb_show_service_permissions
	@dbname nvarchar(128),
	@xmlresults xml output
AS
BEGIN
	declare @sql nvarchar(MAX);
	select @sql = 'select @xmlresults = (select s.service_id as [@service_id],
		s.name as service,
		u.name as grantee,
		permission_name, state_desc
		from ' + QUOTENAME(@dbname) + N'.sys.database_permissions p
		left outer join ' + QUOTENAME(@dbname) + '.sys.database_principals u on p.grantee_principal_id = u.principal_id
		join ' + QUOTENAME(@dbname) + N'.sys.services s 
			on p.major_id = s.service_id and p.class = 17 and p.minor_id = 0
		for xml path(''permission''));';
	exec sp_executesql @sql, N'@xmlresults XML output', @xmlresults output;
END
GO

-- NAME: sp_ssb_show_service_conversations
-- PURPOSE: lists all conversations and all pending messages in TQ in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_service_conversations')
begin
	drop procedure sp_ssb_show_service_conversations
end
GO

create procedure sp_ssb_show_service_conversations
	@dbname nvarchar(128),
	@xmlresults xml output
AS
BEGIN
	declare @sql nvarchar(MAX);
	select @sql = 'select @xmlresults = (select ep.conversation_handle as [@conversation_handle],
	ep.conversation_id,
	ep.is_initiator,
	ep.state_desc,
	s.name as [near_service],
	ep.far_service,
	pn.name as [near_user],
	pf.name as [far_user],
	ep.outbound_session_key_identifier,
	ep.send_sequence,
	ep.receive_sequence,
	(select 
			message_sequence_number, 
			message_type_name,
			is_conversation_error,
			is_end_of_dialog,
			transmission_status
			from ' + QUOTENAME(@dbname) + N'.sys.transmission_queue tq 
		where ep.conversation_handle = tq.conversation_handle 
		order by message_sequence_number asc
		for xml path(''message''), type) as messages
	from ' + QUOTENAME(@dbname) + N'.sys.conversation_endpoints ep
		left outer join ' + QUOTENAME(@dbname) + N'.sys.services s on ep.service_id = s.service_id
		left outer join ' + QUOTENAME(@dbname) + N'.sys.database_principals pn on ep.principal_id = pn.principal_id
		left outer join ' + QUOTENAME(@dbname) + N'.sys.database_principals pf on ep.far_principal_id = pf.principal_id
	for xml path(''conversation''));';
	exec sp_executesql @sql, N'@xmlresults XML output', @xmlresults output;
END
GO


-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_database
-- PURPOSE: lists all ssb related stuff in a given db
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_database')
begin
	drop procedure sp_ssb_show_database
end
GO

create procedure sp_ssb_show_database
	@dbname nvarchar(128),
	@xmlresults xml output
AS
declare @xmls XML;
declare @xmlsq XML;
declare @xmlsp XML;
declare @xmlsqp XML;
declare @xmlrsb XML;
declare @xmlroutes XML;
declare @xmlcerts XML;
declare @xmlep XML;
declare @xmlerr XML;
begin try
	exec tempdb..sp_ssb_show_services @dbname, @xmls output;
	exec tempdb..sp_ssb_show_queues @dbname, @xmlsq output;
	exec tempdb..sp_ssb_show_rsbs @dbname, @xmlrsb output;
	exec tempdb..sp_ssb_show_routes @dbname, @xmlroutes output;
	exec tempdb..sp_ssb_show_service_permissions @dbname, @xmlsp output;
	exec tempdb..sp_ssb_show_queue_permissions @dbname, @xmlsqp output;
	exec tempdb..sp_ssb_show_certificates @dbname, @xmlcerts output;
	exec tempdb..sp_ssb_show_service_conversations @dbname, @xmlep output;
end try
begin catch
	select @xmlerr = (select 
			ERROR_NUMBER() as [@number],
			ERROR_SEVERITY() as [@severity],
			ERROR_STATE() as [@state],
			ERROR_MESSAGE() as [text()]	
		for xml path('error'));
end catch
select @xmlresults = (select 
	d.database_id as [@database_id], 
	d.name,
	d.user_access_desc,
	d.state_desc,
	d.is_read_only,
	d.is_auto_close_on,
	d.service_broker_guid,
	d.is_broker_enabled,
	d.is_trustworthy_on,
	d.is_master_key_encrypted_by_server,
	d.owner_sid as [owner/sid],
	p.name as [owner/name],
	@xmls as services, 
	@xmlsq as queues,
	@xmlroutes as routes,
	@xmlrsb as remote_service_bindings,
	@xmlcerts as certificates,
	@xmlsp as service_permissions,
	@xmlsqp as queue_permissions,
	@xmlep as conversations,
	@xmlerr as errors
	from sys.databases d
		left outer join sys.server_principals p on d.owner_sid = p.sid
		where d.name = @dbname
	for xml path('database'));
GO

-----------------------------------------------------------------------------------
-- NAME: sp_ssb_show_server
-- PURPOSE: lists all ssb related stuff the whole server
-----------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'sp_ssb_show_server')
begin
	drop procedure sp_ssb_show_server
end
GO

create procedure sp_ssb_show_server
	@xmlresults xml output
AS
BEGIN
	declare crsAllDatabases cursor forward_only for 
		select [name] from sys.databases;
	open crsAllDatabases
	declare @dbname nvarchar(128);
	declare @xml XML;
	declare @allxml nvarchar(max);
	select @allxml = N'';
	fetch from crsAllDatabases into @dbname
	while @@fetch_status = 0
	begin
		print @dbname;
		select @xml = NULL;
		execute tempdb..sp_ssb_show_database @dbname, @xml output;
		select @allxml = @allxml + cast(@xml as nvarchar(MAX));
		fetch next from crsAllDatabases into @dbname;
	end
	close crsAllDatabases;
	deallocate crsAllDatabases;
	select @xmlresults = (select 
		@@servername as [@servername],
		@@version as version,
		serverproperty('machinename') as machinename,
		cast (@allxml as XML) as [databases]
		for xml path('server'));
END
GO

declare @xml XML;
exec tempdb..sp_ssb_show_server @xml output;
select @xml;