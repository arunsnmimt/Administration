USE [DBA_ADMIN]
GO
/****** Object:  StoredProcedure [dbo].[PRC_DBA_INDEX_DEFRAG_90]    Script Date: 12/07/2012 10:18:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[PRC_DBA_INDEX_DEFRAG_90]
(
 @DBNAME sysname =NULL,		-- SPECIFIC DB NAME / NULL FOR DB'S
 @ACTION VARCHAR(20)=NULL,		-- POSSIBLE VALUES REBUILD/REORGANIZE / NULL
 @ONLINE VARCHAR(3)='OFF',		-- ON FOR ONLINE INDEX REBUILD, OFF FOR OFFLINE INDEX REBUILD
								-- Online = ON will work only with ENTERPRISE EDITION of SQL server
@SORT_IN_TEMPDB VARCHAR(3)='OFF',-- 		
 @DEBUG CHAR(1)='N',			-- Y=WILL NOT PERFORM THE MAINTENANCE, WILL GIVE ONLY THE COMMENTS AND COMMANDS THAT IS PREPARED
 @ScanOnly CHAR(1)='N',			-- Y= WILL ONLY TO A SCAN OF ALL INDEXEX AND REPORT TO THE TABLE TBL_DBA_INDEXREPORT
 @SAMPLING VARCHAR(10)='SAMPLED',	-- SCANNING MODES OF INDEX TO FIND THE FRAG LEVEL. POSSIBLE VALUES SAMPLED/LIMITED
 @Frag_Threshold_Percent smallint=10,	-- ONLY INDEXES ABOVE THIS THRESHOLD WILL BE CONSIDERED FOR MAINTENANCE
 @PageCount BIGINT=25,			-- TO IGNORE SMALL INDEXES, ONLY INDEXES WITH >PAGECOUNT WILL BE CONSDERED FOR MAINTENANCE
 @DefragThreshold float=30.0, -- Less than this fragmenation the system will go for indexdefrag. grater than this
							 -- this value the system will go for index rebuild
@MaxDop CHAR(1)=NULL
)
AS
/*
Author: SUBHASH K V

Version			Date of Change			Comments
-----------------------------------------------------------
1.0				30/06/2010				First version for deployment in test environments - SUBHASH K V
1.1				01/09/2010				Added DBA report table for reporing purpose - SUBHASH K V
1.2				06/09/2010				Added XML and spare index check for ONLINE rebuild - SUBHASH K V
1.3				11/10/2010				QuoteName is added in alter index statement - SUBHASH K V
1.4				15/02/2011				Quotename is added for the partition query - SUBHASH K V
1.5				15/02/2011				Replaced the defrag decision value 30.0 with variable @DefragThreshold - SUBHASH K V
1.6				18/05/2011				MAXDOP added and Excluded offline indexes - NEEL
1.7             01/06/2011                              Added Is_disabled check - NEEL
1.8				01/06/2011				Changed system catalogs names to small letters - CS Collation fix. - MAHALINGAM
1.9				17/11/2011				Included the compatibility with Turkey collations
REFERENCE: http://blogs.msdn.com/b/joaol/archive/2008/01/28/script-to-rebuild-and-reorganize-database-indexes-sql-server-2005.aspx
*/

		DECLARE @TooSmallIDX INT
		DECLARE @DB_COUNT SMALLINT
		DECLARE @CURRENT_OBJ VARCHAR(128)
		DECLARE @DBNAME_NEXT sysname
		DECLARE @DBID_NEXT INT 
		DECLARE @DBNAME_NEXT_CUR SMALLINT
		DECLARE @INNER_CUR SMALLINT
		DECLARE @SQLCOMMAND NVARCHAR(4000)
		DECLARE @REBUILD_COMMAND VARCHAR(4000)
		DECLARE @REORG_COMMAND VARCHAR(4000)
		DECLARE @PARTITION_COUNT INT
		DECLARE @SQLString NVARCHAR(500)
		DECLARE @ParmDefinition NVARCHAR(500)
		DECLARE @ONLINE_CURRENT VARCHAR(3)

		DECLARE @CUR_DBNAME VARCHAR(128)
		DECLARE @CUR_obj_id INT
		DECLARE @CUR_OBJ_NAME VARCHAR(128)
		DECLARE @CUR_SCH_NAME VARCHAR(128)
		DECLARE @CUR_ind_id INT
		DECLARE @CUR_IND_NAME VARCHAR(128)
		DECLARE @CUR_partitionnum INT
		DECLARE @CUR_ALLOWPAGELOCK INT
		DECLARE @CUR_fragment FLOAT
		DECLARE @CUR_PAGE_COUNT INT
		DECLARE @CUR_Index_type TINYINT
		DECLARE @CUR_LOB_Status TINYINT
		DECLARE @SQL_EDITION NVARCHAR(128)
		DECLARE @Start_Time SMALLDATETIME
		DECLARE @End_Time	SMALLDATETIME
		DECLARE @Duration_MI Int
		DECLARE @LOB_STATUS SMALLINT
		DECLARE @FQTN VARCHAR(500)
		
		

		SET @DBNAME=LTRIM(RTRIM(UPPER(@DBNAME)))
		SET @ACTION=LTRIM(RTRIM(UPPER(@ACTION))) -- input validation required
		SET @ONLINE=LTRIM(RTRIM(UPPER(@ONLINE))) -- input validation required
		SET @DEBUG=LTRIM(RTRIM(UPPER(@DEBUG)))
		SET @SAMPLING=LTRIM(RTRIM(UPPER(@SAMPLING)))
		SET @ScanOnly=LTRIM(RTRIM(UPPER(@ScanOnly)))
		IF isnull(@Frag_Threshold_Percent,0)=0 SET @Frag_Threshold_Percent=0
		IF isnull(@PageCount,0)=0 SET @PageCount=0
		SET @TooSmallIDX=5000
		SET @ONLINE_CURRENT=@ONLINE
		SET @LOB_STATUS=0

		SELECT @CURRENT_OBJ=OBJECT_NAME(@@PROCID)
		SET NOCOUNT ON

CREATE TABLE #TEMPDBS(DBNAME VARCHAR(128))
IF isnull(@DBNAME,'*')='*'
 BEGIN
	INSERT INTO #TEMPDBS(DBNAME) 
	SELECT [NAME] FROM sys.databases
	WHERE [NAME] NOT IN ('master','msdb','tempdb','model','pubs','AdventureWorks','NorthWind')
	AND UPPER([NAME]) NOT IN(SELECT UPPER(EXCL_OBJ_VALUE) FROM TBL_DBA_EXCLUSION WHERE EXCL_OBJ_TYPE='DATABASE_NAME' AND EXCL_PROGRAM='INDEX_DEFRAG')
	AND STATE = 0 AND compatibility_level IN(90,100) AND is_read_only=0 AND is_in_standby=0
 END
ELSE
 BEGIN
	INSERT INTO #TEMPDBS(DBNAME) 
	SELECT [NAME] FROM sys.databases
	WHERE [NAME] NOT IN ('master','msdb','tempdb','model','pubs','AdventureWorks','NorthWind') 	
	AND UPPER([NAME])=@DBNAME
	AND STATE = 0 AND compatibility_level IN(90,100) AND is_read_only=0 AND is_in_standby=0
 END
--SELECT * FROM #TEMPDBS
	SELECT @DB_COUNT=COUNT(*) FROM #TEMPDBS
	IF (@DB_COUNT>0)
		IF (@DEBUG='Y') EXEC PRC_WRITE_ERROR @CURRENT_OBJ ,'PROCEDING WITH THE DBS'
	ELSE
		IF (@DEBUG='Y') EXEC PRC_WRITE_ERROR @CURRENT_OBJ ,'NO DATABASE TO SCAN'

INSERT INTO TBL_DBA_INDEXREPORT_ARCHIVE SELECT * FROM TBL_DBA_INDEXREPORT
TRUNCATE TABLE TBL_DBA_INDEXREPORT

CREATE TABLE #All_Indexes
			(DBName VARCHAR(128),
			 obj_id int NULL,
		     Obj_Name VARCHAR(128),
			 sch_id int NULL,
			 Sch_Name VARCHAR(128),
			 ind_id  int NULL,
			 Ind_Name VARCHAR(128),
			 partitionnum int NULL,
			 fragment float NULL,
			 Page_Cnt int NULL,
			 Maint_Status INT Default 0,
			 AllowPageLock INT Default -1,
			 Index_type TINYINT Default 0,
			 LOB_Status TINYINT DEFAULT 0,
			 Is_Disabled bit default 1
			) 

DECLARE CUR_DBLIST CURSOR
FOR SELECT DBNAME FROM #TEMPDBS  ORDER BY DBNAME ASC
OPEN CUR_DBLIST
FETCH NEXT FROM CUR_DBLIST INTO @DBNAME_NEXT 
SELECT @DBNAME_NEXT_CUR = @@FETCH_STATUS
WHILE(@DBNAME_NEXT_CUR=0)
	BEGIN
	SET @DBID_NEXT=DB_ID(@DBNAME_NEXT)
	IF(@DEBUG='Y')	PRINT '-------------------PROCESSING DATABASE ='+@DBNAME_NEXT+'-------------------'
		
	TRUNCATE TABLE #All_Indexes	
	SET @SQLCOMMAND='INSERT INTO #All_Indexes
		(DBName,
		 obj_id,
		 ind_id,	     
	     partitionnum,
		 fragment,
		 Page_Cnt)	
	SELECT DB_NAME('+CONVERT(VARCHAR,@DBID_NEXT)+') AS DatabaseName,
    object_id,
    index_id,
	partition_number,
    avg_fragmentation_in_percent AS frag,page_count
	FROM '+QuoteName(@DBNAME_NEXT)+'.sys.dm_db_index_physical_stats ('+CONVERT(VARCHAR,@DBID_NEXT)+', NULL, NULL , NULL, '''+CONVERT(VARCHAR,@SAMPLING)+''')
	WHERE avg_fragmentation_in_percent >=0 AND index_id > 0 AND page_count>=0 AND Alloc_unit_type_desc <> ''LOB_DATA'''
	EXEC sp_executesql @SQLCOMMAND
	--PRINT @SQLCOMMAND
	--collation change v1.8 changing SYS.INDEXES TO  sys.indexes
	SET @SQLCOMMAND='UPDATE AI SET AI.Ind_Name=SI.Name,AI.AllowPageLock=SI.Allow_Page_Locks,AI.Index_type=SI.type,AI.Is_Disabled=SI.is_disabled from #All_Indexes AI INNER JOIN '+QuoteName(@DBNAME_NEXT)+'.sys.indexes SI ON AI.obj_id=SI.Object_id AND AI.ind_id=SI.Index_Id WHERE SI.Index_Id>0 and AI.DBName='''+@DBNAME_NEXT+''''
	EXEC sp_executesql @SQLCOMMAND
	--collation change v1.8 changing SYS.OBJECTS TO  sys.objects 
	SET @SQLCOMMAND='UPDATE AI SET AI.Obj_Name=SO.Name, AI.sch_id=SO.schema_Id from #All_Indexes AI INNER JOIN '+QuoteName(@DBNAME_NEXT)+'.sys.objects SO ON AI.obj_id=SO.Object_id where AI.DBName='''+@DBNAME_NEXT+''''
	EXEC sp_executesql @SQLCOMMAND
	--collation change v1.8 changing SYS.SCHEMAS TO  sys.schemas
	SET @SQLCOMMAND='UPDATE AI SET AI.Sch_Name=SC.Name from #All_Indexes AI INNER JOIN '+QuoteName(@DBNAME_NEXT)+'.sys.schemas SC ON AI.sch_id=SC.Schema_id where AI.DBName='''+@DBNAME_NEXT+''''
	EXEC sp_executesql @SQLCOMMAND
	
	SET @SQLCOMMAND='UPDATE #All_Indexes SET LOB_Status=1 WHERE obj_id IN (select object_id  from '+QUOTENAME(@DBNAME_NEXT)+'.sys.columns where system_type_id in (select system_type_id from '+QUOTENAME(@DBNAME_NEXT)+'.sys.types where name in(''image'',''text'',''ntext'',''geometry'',''geography'',''xml''))OR max_length=-1)'
	--print @SQLCOMMAND
	EXEC sp_executesql @SQLCOMMAND

	
	--select * from #All_Indexes where IND_NAME='idx1'
	
	INSERT INTO TBL_DBA_INDEXREPORT (DB_NAME,DB_ID,TABLE_NAME,TABLE_ID,INDEX_NAME,INDEX_ID,
	SCHEMA_NAME,SCHEMA_ID,PARTITION_NUMBER,FRAGMENT_PER,INDEX_SIZE_MB,DEFRAG_METHOD,PAGE_LOCK,DEFRAG_DATE)
	SELECT DBName,@DBID_NEXT,Obj_Name ,obj_id ,Ind_Name ,ind_id  ,Sch_Name ,sch_id ,partitionnum ,
	fragment ,Page_Cnt,'NONE',AllowPageLock,GETDATE() from #All_Indexes

			IF (@ScanOnly='Y') GOTO NEXT_DB
			DECLARE CUR_PROCESS_ONE_DB CURSOR FOR 
			SELECT DBName,
				   obj_id,
				   Obj_Name,
				   Sch_Name,
				   ind_id,
				   Ind_Name,
				   partitionnum,
				   AllowPageLock,			   
				   fragment,Page_Cnt,Index_type,LOB_Status
			FROM   #All_Indexes
			WHERE Maint_Status=0 AND DBName=@DBNAME_NEXT AND fragment >= @Frag_Threshold_Percent AND Page_Cnt>=@PageCount and Is_Disabled = 0
			OPEN CUR_PROCESS_ONE_DB
			FETCH NEXT FROM CUR_PROCESS_ONE_DB INTO @CUR_DBNAME,@CUR_obj_id,@CUR_OBJ_NAME,@CUR_SCH_NAME,@CUR_ind_id,
													@CUR_IND_NAME,@CUR_partitionnum,@CUR_ALLOWPAGELOCK,@CUR_fragment,@CUR_PAGE_COUNT,@CUR_Index_type,@CUR_LOB_Status
	
			SELECT @INNER_CUR = @@FETCH_STATUS
			WHILE(@INNER_CUR=0)
			BEGIN	
			
					IF (@CUR_ind_id=1 AND  @CUR_LOB_Status=1) SET @ONLINE_CURRENT='OFF'
					
					IF(@CUR_Index_type=3 OR @CUR_Index_type=4 OR @LOB_STATUS=1) SET @ONLINE_CURRENT='OFF' --checking XML and SPATIAL indexes which cannot be ONLINE indexed
					
					SET @REBUILD_COMMAND=' REBUILD WITH ' + '(SORT_IN_TEMPDB ='+@SORT_IN_TEMPDB+', ONLINE = ' + @ONLINE_CURRENT + ' '
					SET @REORG_COMMAND=' REORGANIZE '


					SET @SQLString = N'SELECT @PARTITIONCOUNT_OUT = COUNT(*)
									   FROM '+QUOTENAME(@CUR_DBNAME)+'.sys.partitions WHERE object_id = @OBJECTID AND index_id=@INDEXID'
					SET @ParmDefinition = N'@PARTITIONCOUNT_OUT INT OUTPUT,@OBJECTID INT,@INDEXID INT'                        
					EXECUTE sp_executesql @SQLString, @ParmDefinition, @OBJECTID = @CUR_obj_id, @INDEXID= @CUR_ind_id, @PARTITIONCOUNT_OUT=@PARTITION_COUNT OUTPUT
					IF (@PARTITION_COUNT>1)
					BEGIN
					SET @REBUILD_COMMAND=' REBUILD PARTITION=  '+CONVERT (CHAR, @CUR_partitionnum)+' WITH (SORT_IN_TEMPDB = '+@SORT_IN_TEMPDB+' ' -- ONLINE REINDEXING IS NOT POSSIBLE WITH PARITIONS
					SET @REORG_COMMAND=' REORGANIZE PARTITION=  '+CONVERT (CHAR, @CUR_partitionnum)
					END
					
					--V 1.6 change 
					IF (@MaxDop IS NOT NULL) 
					BEGIN
					SET @REBUILD_COMMAND=@REBUILD_COMMAND+', MAXDOP ='+@MaxDop
					END
					SET @REBUILD_COMMAND=@REBUILD_COMMAND+')'
					--
						
					SET @REBUILD_COMMAND='ALTER INDEX ' + QUOTENAME(@CUR_IND_NAME) + ' ON ' + QUOTENAME(@CUR_DBNAME) + '.' + QUOTENAME(@CUR_SCH_NAME) + '.' + QUOTENAME(@CUR_OBJ_NAME)+ '' + @REBUILD_COMMAND
					SET @REORG_COMMAND='ALTER INDEX ' + QUOTENAME(@CUR_IND_NAME) + ' ON ' + QUOTENAME(@CUR_DBNAME) + '.' + QUOTENAME(@CUR_SCH_NAME) + '.' + QUOTENAME(@CUR_OBJ_NAME)+ '' + @REORG_COMMAND

					IF (@ACTION='REBUILD')
						 BEGIN
						 SET @SQLCOMMAND=@REBUILD_COMMAND
						 END
					ELSE IF (@ACTION='REORGANIZE')
						 BEGIN
						 SET @SQLCOMMAND=@REORG_COMMAND
						 END
					ELSE
						 BEGIN
							IF(@CUR_fragment<@DefragThreshold) SET @SQLCOMMAND=@REORG_COMMAND
							ELSE SET @SQLCOMMAND=@REBUILD_COMMAND
						 END
						 
					IF (@CUR_ALLOWPAGELOCK<>1 OR @CUR_PAGE_COUNT<=@TooSmallIDX) --IF PAGELOCK=0 THEN WE CAN'T DO REORGANIZE, ALSO IF THE INDEX SIZE IS LESSTHAN 5000 PAGES its easy to rebuild it
						 SET @SQLCOMMAND=@REBUILD_COMMAND
					
					IF(@DEBUG='Y') PRINT @SQLCOMMAND

					
					IF(@DEBUG='N') 
					Begin
						SELECT @Start_Time=GETDATE()
						
						UPDATE TBL_DBA_INDEXREPORT SET CURRENT_STATUS='EXECUTING..',
						SCRIPT_USED=@SQLCOMMAND,DEFRAG_DATE=GETDATE()
						where DB_ID=@DBID_NEXT and TABLE_ID=@CUR_obj_id and INDEX_ID=@CUR_ind_id and 
						SCHEMA_NAME=@CUR_SCH_NAME and PARTITION_NUMBER=@CUR_partitionnum
						SET @FQTN=@CUR_DBNAME+'.'+@CUR_SCH_NAME+'.'+@CUR_OBJ_NAME
						--PRINT @FQTN
						
						IF NOT EXISTS(SELECT * FROM TBL_DBA_EXCLUSION WHERE UPPER(EXCL_PROGRAM)='INDEX_DEFRAG' AND UPPER(EXCL_OBJ_TYPE)='TABLE_NAME' AND UPPER(EXCL_OBJ_VALUE)=UPPER(@FQTN)	)					
						BEGIN
							PRINT @SQLCOMMAND
							EXEC (@SQLCOMMAND) -- Execute the command 
							SELECT @End_Time=GETDATE()
							SELECT @Duration_MI=DATEDIFF(MI,@Start_Time,@End_Time)
						END					
						ELSE SET @SQLCOMMAND='THIS TABLE IS EXCLUDED IN TBL_DBA_EXCLUSION TABLE'
						
						UPDATE TBL_DBA_INDEXREPORT SET TIME_TAKNE_TO_DEFRAG_MI=@Duration_MI,
						CURRENT_STATUS='COMPLETED',SCRIPT_USED=@SQLCOMMAND
						where DB_ID=@DBID_NEXT and TABLE_ID=@CUR_obj_id and INDEX_ID=@CUR_ind_id and 
						SCHEMA_NAME=@CUR_SCH_NAME and PARTITION_NUMBER=@CUR_partitionnum
					End	
					SET @ONLINE_CURRENT=@ONLINE
					SET @LOB_STATUS=0
					FETCH NEXT FROM CUR_PROCESS_ONE_DB INTO @CUR_DBNAME,@CUR_obj_id,@CUR_OBJ_NAME,@CUR_SCH_NAME,@CUR_ind_id,
															@CUR_IND_NAME,@CUR_partitionnum,@CUR_ALLOWPAGELOCK,@CUR_fragment,@CUR_PAGE_COUNT,@CUR_Index_type,@CUR_LOB_Status
					SELECT @INNER_CUR = @@FETCH_STATUS
					END			
			CLOSE CUR_PROCESS_ONE_DB
			DEALLOCATE CUR_PROCESS_ONE_DB
	NEXT_DB:
	FETCH NEXT FROM CUR_DBLIST INTO @DBNAME_NEXT 
	SELECT @DBNAME_NEXT_CUR = @@FETCH_STATUS
END
CLOSE CUR_DBLIST
DEALLOCATE CUR_DBLIST

--IF(@DEBUG='Y') SELECT * FROM #All_Indexes_DBAReferences
DROP TABLE #All_Indexes
DROP TABLE #TEMPDBS
--DROP TABLE #All_Indexes_DBAReferences
--END OF PROCEUDRE [PRC_DBA_INDEX_DEFRAG_90]


