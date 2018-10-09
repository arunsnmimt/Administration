------ unused tables & indexes.  Tables have index_id’s of either 0 = Heap table or 1 = Clustered Index

Declare @dbid int

Select @dbid = db_id('Northwind')

Select objectname=object_name(i.object_id)

                        , indexname=i.name, i.index_id 

from sys.indexes i, sys.objects o 

where objectproperty(o.object_id,'IsUserTable') = 1

and i.index_id NOT IN (select s.index_id 

       from sys.dm_db_index_usage_stats s 

               where s.object_id=i.object_id and 

                        i.index_id=s.index_id and 

                        database_id = @dbid )

and o.object_id = i.object_id

order by objectname,i.index_id,indexname asc

----------------------------
--- rarely used indexes appear first

declare @dbid int

select @dbid = db_id()

select objectname=object_name(s.object_id), s.object_id, indexname=i.name, i.index_id

            , user_seeks, user_scans, user_lookups, user_updates

from sys.dm_db_index_usage_stats s,

            sys.indexes i

where database_id = @dbid and objectproperty(s.object_id,'IsUserTable') = 1

and i.object_id = s.object_id

and i.index_id = s.index_id

order by (user_seeks + user_scans + user_lookups + user_updates) asc

----------------------
--If a table is heavily updated and also has indexes that are rarely used, 
--the cost of maintaining the indexes could exceed the benefits.  
--To compare the cost and benefit, you can use the table valued function 
--sys.dm_db_index_operational_stats as follows:

 

--- sys.dm_db_index_operational_stats

declare @dbid int

select @dbid = db_id()

            

select objectname=object_name(s.object_id), indexname=i.name, i.index_id

            , reads=range_scan_count + singleton_lookup_count

            , 'leaf_writes'=leaf_insert_count+leaf_update_count+ leaf_delete_count 

            , 'leaf_page_splits' = leaf_allocation_count

            , 'nonleaf_writes'=nonleaf_insert_count + nonleaf_update_count + nonleaf_delete_count

            , 'nonleaf_page_splits' = nonleaf_allocation_count

from sys.dm_db_index_operational_stats (@dbid,NULL,NULL,NULL) s,

                        sys.indexes i

where objectproperty(s.object_id,'IsUserTable') = 1

and i.object_id = s.object_id

and i.index_id = s.index_id

order by reads desc, leaf_writes, nonleaf_writes

 

--- sys.dm_db_index_usage_stats

select objectname=object_name(s.object_id), indexname=i.name, i.index_id

                        ,reads=user_seeks + user_scans + user_lookups

                        ,writes =  user_updates

from sys.dm_db_index_usage_stats s,

            sys.indexes i

where objectproperty(s.object_id,'IsUserTable') = 1

and s.object_id = i.object_id

and i.index_id = s.index_id

and s.database_id = @dbid

order by reads desc

go

---------------------------


