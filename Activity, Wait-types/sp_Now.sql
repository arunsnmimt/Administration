use master
IF (object_id('sp_Now')) is not null
BEGIN
  PRINT 'Dropping: sp_Now'
  DROP PROCEDURE sp_Now
END
PRINT 'Creating: sp_Now'
GO
CREATE PROCEDURE sp_Now
as
set nocount on
declare @handle binary(20), 
        @spid   smallint,
        @rowcnt smallint,
        @output varchar(500)

declare ActiveSpids CURSOR FOR
select sql_handle, spid
  from sysprocesses 
 where sql_handle <> 0x0000000000000000000000000000000000000000
   --and spid <> @@SPID
order by cpu desc

OPEN ActiveSpids
FETCH NEXT FROM ActiveSpids
INTO @handle,
     @spid


set @rowcnt = @@CURSOR_ROWS

print '===================='
print '= CURRENT ACTIVITY ='
print '===================='
print ' '
set @output = 'ACTIVE SPIDS: ' + convert(varchar(4),@rowcnt)
print @output


WHILE (@@FETCH_STATUS = 0)
BEGIN
  print ' '
  print ' '
  print 'O' + replicate('x',120) + 'O'
  print 'O' + replicate('x',120) + 'O'
  print ' '
  print ' '
  print ' '

select 'loginame'     = left(loginame, 30),  
       'hostname'     = left(hostname,30),
       'datagbase'    = left(db_name(dbid),30),
       'spid'         = str(spid,4,0), 
       'block'        = str(blocked,5,0), 
       'phys_io'      = str(physical_io,8,0), 
       'cpu(mm:ss)'   = str((cpu/1000/60),6) + ':' + case when left((str(((cpu/1000) % 60),2)),1) = ' ' then stuff(str(((cpu/1000) % 60),2),1,1,'0') else str(((cpu/1000) % 60),2) END ,
       'mem(MB)'      = str((convert(float,memusage) * 8192.0 / 1024.0 / 1024.0),8,2),
       'program_name' = left(program_name,50), 
       'command'      = cmd,
       'lastwaittype' = left(lastwaittype,15),
       'login_time'   = convert(char(19),login_time,120), 
       'last_batch'   = convert(char(19),last_batch,120), 
       'status'       = left(status, 10),
       'nt_username'  = left(nt_username,20)
  from master..sysprocesses
  where spid = @spid
  print ' '
  print ' '
  
  -- Dump the inputbuffer to get an idea of what the spid is doing
  dbcc inputbuffer(@spid)
  print ' '
  print ' '

  -- Use the built-in function to show the exact SQL that the spid is running
  select * from ::fn_get_sql(@handle)
  
  FETCH NEXT FROM ActiveSpids
  INTO @handle,
       @spid
END
close ActiveSpids
deallocate ActiveSpids
GO
IF (object_id('sp_Now')) is not null
  PRINT 'Procedure created.'
ELSE
  PRINT 'Procedure NOT created.'
GO
