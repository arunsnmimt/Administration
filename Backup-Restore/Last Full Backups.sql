/* List full backups over x days */

--	SELECT BSET.database_name, MAX(BSET.backup_finish_date) AS last_db_backup_date 
--	FROM   msdb.dbo.backupmediafamily AS FAM
--	   INNER JOIN msdb.dbo.backupset BSET ON FAM.media_set_id = BSET.media_set_id
--	   INNER JOIN master.sys.databases db ON BSET.database_name = db.name
--	WHERE  BSET.type = 'D'
--	AND db.[state] = 0  
--	AND BSET.database_name NOT IN ('JCB_Live_Link_UAT1_CENTRAL','JCB_Live_Link_UAT1_ELMAH','JCB_Live_Link_UAT1_LOGGING','JCB_Live_Link_UAT1_SATELLITE1',
--'JCB_Live_Link_UAT2_CENTRAL','JCB_Live_Link_UAT2_ELMAH','JCB_Live_Link_UAT2_LOGGING','JCB_Live_Link_UAT2_SATELLITE1','domtest1','MAN_FLEET_MANAGEMENT_UAT','TMC_NFT_UAT','TMC_REPORTS_NFT_UAT','TMC_Reports_tesco_com_uat2','TMC_tesco_com_uat2','Amber_JCB_China_Empty_Template_Satellite1','AMBER_LOGGING','Geonames_SQLCluster05','JCB_Live_Link_CENTRAL_CHINA','MAN_FLEET_MANAGEMENT_ARC','Export_TMC_Reports_MARITIME','TMC_TESCO_MAP')
--	GROUP BY
--	   BSET.database_name
--	HAVING  MAX(BSET.backup_finish_date) <= GETDATE() - 1   --
----	HAVING  MAX(BSET.backup_finish_date) <= DATEADD(DAY,-1, CAST(CONVERT(VARCHAR, GETDATE(),101) AS Datetime))
--	ORDER BY 
--	   BSET.database_name
	   




	SELECT db.name, MAX(BSET.backup_finish_date) AS last_db_backup_date 
	FROM    master.sys.databases db
	  LEFT OUTER JOIN  (SELECT * FROM msdb.dbo.backupset WHERE type = 'D')  BSET ON db.name = BSET.database_name 
	  LEFT OUTER JOIN msdb.dbo.backupmediafamily AS FAM ON FAM.media_set_id = BSET.media_set_id
--	WHERE  BSET.type = 'D'
	WHERE db.[state] = 0  
	AND db.name NOT IN ('JCB_Live_Link_UAT1_CENTRAL','JCB_Live_Link_UAT1_ELMAH','JCB_Live_Link_UAT1_LOGGING','JCB_Live_Link_UAT1_SATELLITE1',
'JCB_Live_Link_UAT2_CENTRAL','JCB_Live_Link_UAT2_ELMAH','JCB_Live_Link_UAT2_LOGGING','JCB_Live_Link_UAT2_SATELLITE1','domtest1','MAN_FLEET_MANAGEMENT_UAT','TMC_NFT_UAT','TMC_REPORTS_NFT_UAT','TMC_Reports_tesco_com_uat2','TMC_tesco_com_uat2','Amber_JCB_China_Empty_Template_Satellite1','AMBER_LOGGING','Geonames_SQLCluster05','JCB_Live_Link_CENTRAL_CHINA','MAN_FLEET_MANAGEMENT_ARC','Export_TMC_Reports_MARITIME','TMC_TESCO_MAP','tempdb')
	GROUP BY
	   db.name
	HAVING  MAX(BSET.backup_finish_date) <= GETDATE() - 1   OR  MAX(BSET.backup_finish_date) IS NULL
--	HAVING  MAX(BSET.backup_finish_date) <= DATEADD(DAY,-1, CAST(CONVERT(VARCHAR, GETDATE(),101) AS Datetime))
	ORDER BY 
	   db.name