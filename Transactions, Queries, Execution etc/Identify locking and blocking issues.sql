-- Look at active Lock Manager resources for current database 
SELECT  request_session_id ,
DB_NAME(resource_database_id) AS [Database] ,
        resource_type ,
        resource_subtype ,
    (case resource_type
      WHEN 'OBJECT' then object_name(resource_associated_entity_id)
      WHEN 'DATABASE' then ' '
      ELSE (select object_name(object_id) 
            from sys.partitions 
            where hobt_id=resource_associated_entity_id)
    END) as objname,       
        request_type ,
        request_mode ,
        resource_description ,
        request_mode ,
        request_owner_type 
FROM    sys.dm_tran_locks
WHERE   request_session_id > 50
        AND resource_database_id = DB_ID()
        AND request_session_id <> @@SPID
ORDER BY request_session_id ;
 
-- Look for blocking 
SELECT  tl.resource_type ,
        DB_NAME(tl.resource_database_id) AS Database_Name ,
        OBJECT_NAME(object_id) AS Table_Name,
        tl.resource_database_id ,
        tl.resource_associated_entity_id ,
        tl.request_mode ,
        tl.request_session_id ,
        wt.blocking_session_id ,
        wt.wait_type ,
        wt.wait_duration_ms
FROM    sys.dm_tran_locks AS tl
        INNER JOIN sys.dm_os_waiting_tasks AS wt
           ON tl.lock_owner_address = wt.resource_address
           LEFT OUTER JOIN  sys.partitions p
           ON tl.resource_associated_entity_id = p.hobt_id
ORDER BY wait_duration_ms DESC ;


--372 368

--SELECT  OBJECT_NAME(object_id)
--FROM   sys.partitions
--WHERE hobt_id = 72057594101432320