

-- Create a global temp table
CREATE TABLE ##SPACE( dletter VARCHAR(3), tspace BIGINT, fspace INT, percentfree NUMERIC(5,2))

-- Insert drive details
INSERT INTO ##SPACE (dletter, fspace) EXEC master.dbo.xp_fixeddrives

-- Declare variables
DECLARE   @oFSO   INT, @oDrive INT, @drsize VARCHAR(255), @ret   INT

-- invoke OACreate
EXEC @ret = master.dbo.sp_OACreate 'scripting.FileSystemObject', @oFSO OUT

DECLARE @dletter VARCHAR(3), @fspace INT, @tspace BIGINT

WHILE (SELECT COUNT(*) FROM  ##SPACE WHERE tspace IS NULL)>0

BEGIN
   SELECT TOP 1 @dletter = dletter  + ':\',@fspace = fspace FROM ##SPACE WHERE tspace IS NULL

   EXEC   @ret = master.dbo.sp_OAMethod @oFSO, 'GetDrive', @oDrive OUT, @dletter
   EXEC   @ret = master.dbo.sp_OAMethod @oDrive, 'TotalSize', @drsize OUT

   UPDATE   ##SPACE SET   tspace = CAST(@drsize AS BIGINT) WHERE   LOWER(dletter) + ':\'   = LOWER(@dletter)
   EXEC master.dbo.sp_OADestroy @oDrive
END

EXEC master.dbo.sp_OADestroy @oFSO

UPDATE   ##SPACE SET   percentfree = fspace/((tspace/1024.0)/1024.0)*100 

-- Select your data

SELECT [Drive] = dletter ,
         [Total SPACE GB]= CONVERT(NUMERIC(10,3), (tspace/1024.0)/1024.0/1024) ,
         [FREE SPACE GB]=CONVERT(NUMERIC(10,3),fspace/1024.0) ,
         [% FREE]= percentfree 
         FROM   ##SPACE

-- Drop temporary table

DROP TABLE ##SPACE

