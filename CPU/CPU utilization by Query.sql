SELECT TOP 50	qs.creation_time, 
				qs.execution_count, 
				qs.total_worker_time as total_cpu_time, 
				qs.max_worker_time as max_cpu_time,
				qs.total_elapsed_time, 
				qs.max_elapsed_time, 
				qs.total_logical_reads, 
				qs.max_logical_reads, 
				qs.total_physical_reads, 
				qs.max_physical_reads,
				t.[text], 
				qp.query_plan, 
				DB_NAME(t.dbid) AS Database_Name, 
				t.objectid AS [Object_Name], 
				t.encrypted, 
				qs.plan_handle, 
				qs.plan_generation_num 
				FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
--				WHERE DB_NAME(t.dbid) = 'TMC_DHL_NISA'
				ORDER BY qs.total_worker_time DESC
				
				
	--			0x05000F00AC32DC4940C16CDF060000000000000000000000
	/*
	
(@TenantID int,@MinEasting float,@MaxEasting float,@MinNorthing float,@MaxNorthing float,@UserID int)-- User geofence permissions    -- get all the geofence map objects in a latlong square that the current user  -- may see based on their group membership where the group is a particular ID  -- or where the group is 'all groups'  -- Also indicate if the user can edit landmarks for that group  -- Do it in one row per geofence/landmark    SELECT   -- This geofence information   l.LocationId as geofenceId, l.LocationName AS gname, g.geofenceType, g.GeofenceRadiusInMetres,    gp.LocationGroupName AS gpname, ISNULL(gp.LocationGroupColour, 'Purple') as locationgroupcolour, ISNULL(gp.LocationGroupCode, 'None') as LocationGroupCode,    L.LocationContactName, L.LocationEmailAddress, L.LocationPhoneNumber,    L.LocationAddress1, L.LocationAddress2, L.LocationAddress3, L.LocationPostcode,    L.LocationAddress4, L.LocationAddress5 ,   ISNULL(L.LocationLatitude,lgp.GeofencePointLat) AS LocationLatitude ,    ISNULL(L.LocationLongitude, lgp.GeofencePointLon) AS LocationLongitude,   lgp.GeofencePointLat as GeofenceLatitude,   lgp.GeofencePointLon as GeofenceLongitude  FROM   tbl_LocationGeofence AS g   INNER JOIN tbl_Locations L on g.GeofenceLocationId = L.LocationId   -- Bring in the profile the geofence belongs to   LEFT OUTER JOIN tbl_GroupLocation gp ON gp.locationgroupid = L.LocationGroupId   LEFT OUTER JOIN tbl_LocationGeofencePoint lgp ON g.GeofenceId = lgp.GeofenceId AND lgp.GeofencePointSequenceNum = 0  WHERE   -- The geofence hasn't been deleted   g.GeofenceDeleted = 0 AND L.LocationTenantId = @TenantID   -- The geofence is in our box  AND   g.geofenceminEasting <= @MaxEasting AND g.geofencemaxEasting >= @MinEasting  AND   g.geofenceminNorthing <= @MaxNorthing AND g.geofencemaxNorthing >= @MinNorthing  

*/