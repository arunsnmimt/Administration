
use msdb

go
Create  procedure Index_Rebuild_All (@start_DB_ID int, @END_DB_ID int)
as 
begin 
set nocount on


declare @fragmentation as table (
    database_name sysname, [schema_name] sysname, table_name sysname, index_name sysname
    , avg_fragmentation_in_percent decimal (28,2), avg_page_space_used_in_percent decimal (28,2)
    , page_count bigint, record_count bigint, fragment_count bigint
    , recommendation nvarchar(4000)
)
                                
declare @database_name sysname
declare @query nvarchar(max)
declare @min_frag_rebuild int 
declare @min_frag_reorganize int 
declare @min_fill_rebuild int 
declare @min_fill_reorganize int 
declare @min_size int 
declare @maxdop int



set @min_frag_rebuild = 30     -- a partir de un 15% de fragmentación se reindexa
set @min_frag_reorganize = 10  -- a partir de un 10% de fragmentación se reorganiza
set @min_fill_rebuild = 40
set @min_fill_reorganize = 60
set @min_size = 5
set @maxdop = (select cpu_count from sys.dm_os_sys_info)   -- Esto es importante. Se utiliza MAXDOP = nº de procesadores

DECLARE c_databases CURSOR read_only FOR
    SELECT d1.[name] FROM sys.databases d1
    where d1.state_desc = 'ONLINE' and is_read_only = 0
          and d1.name not in ('tempdb') and d1.database_id between @start_DB_ID and @END_DB_ID
OPEN c_databases

FETCH NEXT FROM c_databases
into @database_name
WHILE @@FETCH_STATUS = 0
BEGIN	
    set @query = N'	
    with dt as ( 
        SELECT 
            index_id, object_id, database_id
            , MAX(avg_fragmentation_in_percent) avg_fragmentation_in_percent, MAX(avg_page_space_used_in_percent) avg_page_space_used_in_percent
            , MAX(page_count) page_count, MAX(record_count) record_count, MAX(fragment_count) fragment_count
        from sys.dm_db_index_physical_stats (DB_ID('''+ @database_name +'''), NULL, NULL, NULL, NULL) 
        where (     avg_fragmentation_in_percent > ' + convert(char(3), @min_frag_reorganize) +' 
               or avg_page_space_used_in_percent < ' + convert(char(3), @min_fill_reorganize) + ') 
                              and page_count > ' + convert(char(10), @min_size) + '
        GROUP BY index_id, object_id, database_id
    ) 
    SELECT  
        db_name(database_id) database_name, s.name schema_name, t.name table_name, i.name index_name
        , dt.avg_fragmentation_in_percent, dt.avg_page_space_used_in_percent, page_count, record_count, fragment_count
        ,	case 
                when ( avg_page_space_used_in_percent < ' + convert(char(3),@min_fill_rebuild) + 
    '				or   avg_fragmentation_in_percent > ' + convert(char(3),@min_frag_rebuild) +                   
    ') then ''ALTER INDEX '' + QUOTENAME(i.name)+ '' ON '+ QUOTENAME(@database_name) + '.'' + QUOTENAME(s.name) +''.''+ QUOTENAME(t.name) +'' REBUILD '' 
                else ''ALTER INDEX '' + QUOTENAME(i.name)+ '' ON '+ QUOTENAME(@database_name) + '.'' + QUOTENAME(s.name) +''.''+ QUOTENAME(t.name) +'' REORGANIZE ''
            end SENTENCIA_RECOMENDADA  
    FROM dt 
        INNER JOIN '+ QUOTENAME(@database_name) + '.sys.indexes i
            ON dt.object_id = i.object_id and dt.index_id = i.index_id 
        INNER JOIN '+ QUOTENAME(@database_name) + '.sys.tables t 
            ON i.object_id = t.object_id 
        INNER JOIN '+ QUOTENAME(@database_name) + '.sys.schemas s
            ON t.schema_id = s.schema_id 
    WHERE dt.index_id <> 0 
    ORDER BY database_name, s.name, t.name, i.name' 

   insert into @fragmentation ( 
        database_name, [schema_name], table_name, index_name
        , avg_fragmentation_in_percent, avg_page_space_used_in_percent
        , page_count, record_count, fragment_count
        , recommendation) 

   execute(@query)

   FETCH NEXT FROM c_databases
   into @database_name
END

CLOSE c_databases
DEALLOCATE c_databases

-- Get the fragmentation report
select * from @fragmentation

-- Defragment the indexes
if exists(select 1 from @fragmentation)
begin
    DECLARE cursorBBDD_new CURSOR read_only fast_forward forward_only FOR
    select database_name, [table_name], index_name, recommendation from @fragmentation
    
OPEN cursorBBDD_new

declare @nombreBBDD sysname
declare @nombreTabla nvarchar(100)
declare @Recommendation nvarchar(1024)
declare @Recommendation_new nvarchar (1024)
declare @indexname nvarchar(20)


FETCH NEXT FROM cursorBBDD_new
into @nombreBBDD, @nombreTabla, @indexname, @Recommendation
WHILE @@FETCH_STATUS = 0
BEGIN
        -- Try to do it online and failback to offline mode if it is not possible
        BEGIN TRY
             IF (patindex('%REBUILD%',@Recommendation) <> 0 )
                set @Recommendation_new='use ' + @nombreBBDD + ';' + @Recommendation + 'WITH (ONLINE=ON, MAXDOP=' + CAST(@maxdop as varchar(10)) + ')'
             ELSE 
                set @Recommendation_new='use ' + @nombreBBDD + ';' + @Recommendation 
             -- Execute the command and then print it
             exec (@recommendation_new)
             print @Recommendation_new
        END TRY
        BEGIN CATCH
             IF (patindex('%REBUILD%',@Recommendation) <> 0 )
                set @Recommendation_new='use ' + @nombreBBDD + ';' + @Recommendation + 'WITH (ONLINE=OFF, MAXDOP=' + CAST(@maxdop as varchar(10)) + ')'
             ELSE 
                set @Recommendation_new='use ' + @nombreBBDD + ';' + @Recommendation 
             -- Execute the command and then print it	
             exec (@recommendation_new)
             print @Recommendation_new
        END CATCH

    FETCH NEXT FROM cursorBBDD_new
    into @nombreBBDD, @nombreTabla, @indexname, @Recommendation
END

CLOSE cursorBBDD_new
DEALLOCATE cursorBBDD_new
end

end

