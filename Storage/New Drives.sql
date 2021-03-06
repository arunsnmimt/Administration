--	USe Admin_DBA

	IF object_id('tempdb..#tbl_xp_fixeddrives') IS NULL
	BEGIN
		CREATE TABLE #tbl_xp_fixeddrives
		(Drive char(1) NOT NULL,
		Free_MB int NOT NULL,
		Free_GB DECIMAL (10,1) NULL
		)
	END
	ELSE
	BEGIN
		TRUNCATE TABLE #tbl_xp_fixeddrives
	END


	INSERT INTO #tbl_xp_fixeddrives(Drive, [Free_MB])
	EXEC master.sys.xp_fixeddrives


	UPDATE #tbl_xp_fixeddrives
	SET Free_GB = Free_MB / 1024.

	SELECT temp.Drive, temp.Free_MB, temp.Free_GB
	  FROM #tbl_xp_fixeddrives temp LEFT OUTER JOIN 		
			  (SELECT  *
				FROM [SUNNY].Admin_DBA.dbo.tbl_DiskAlerts
				  WHERE Server_Name = @@SERVERNAME) d 
	  ON temp.Drive = d.Drive
	    WHERE d.Drive IS NULL

	DROP TABLE #tbl_xp_fixeddrives