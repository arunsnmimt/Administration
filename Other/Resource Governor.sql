--BEGIN TRAN;
-- Create 3 workload groups based on the nature of their workload.
-- One handles ad hoc requests, the second handles reports, and the
-- third handles admin requests. These groups all use the default 
-- settings for workload groups.
-- These workloads are divided into groups that cover ad hoc queries,
-- reports, and administration jobs. 
CREATE WORKLOAD GROUP GroupSolarWinds;
CREATE WORKLOAD GROUP GroupProAchieve;
CREATE WORKLOAD GROUP GroupReports;
CREATE WORKLOAD GROUP GroupDataPumps;


GO
--COMMIT TRAN;
-- Create a classification function.
-- Note that any request that does not get classified goes into 
-- the 'default' group.
/*
CREATE FUNCTION dbo.rgclassifier_v1() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name sysname
      IF (SUSER_NAME() = 'sw_orion')
          SET @grp_name = 'GroupSolarWinds'
    RETURN @grp_name
END;
GO
*/

CREATE FUNCTION dbo.rgclassifier_v3() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name sysname
      IF (SUSER_NAME() = 'sw_orion')
          SET @grp_name = 'GroupSolarWinds'
      IF (SUSER_NAME() = 'CompassSystemUser')
          SET @grp_name = 'GroupProAchieve'
      IF (APP_NAME() LIKE '%REPORT SERVER%')
          SET @grp_name = 'GroupReports'          
          -- Courses On Line Job      
      IF (APP_NAME() LIKE 'SQLAgent - TSQL JobStep (Job 0xAC5B4689978A2641A19BC2E1DE73CE8B :%')
          SET @grp_name = 'GroupDataPumps'                
    RETURN @grp_name
END

GO

-- Register the classifier function with Resource Governor
--ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION= dbo.rgclassifier_v1);
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION= dbo.rgclassifier_v3);
GO
-- Start Resource Governor
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

BEGIN TRAN;
-- Create a new resource pool and set a maximum CPU limit.
CREATE RESOURCE POOL PoolSolarWinds
WITH (MAX_CPU_PERCENT = 50);
-- Configure the workload group so it uses the new resource pool. 
-- The following statement moves 'GroupAdhoc' from the 'default' pool --- to 'PoolAdhoc'
ALTER WORKLOAD GROUP GroupSolarWinds
USING PoolSolarWinds;
COMMIT TRAN;
GO

BEGIN TRAN;
-- Create a new resource pool and set a maximum CPU limit.
CREATE RESOURCE POOL PoolDataPumps
WITH (MAX_CPU_PERCENT = 50);
-- Configure the workload group so it uses the new resource pool. 
-- The following statement moves 'GroupAdhoc' from the 'default' pool --- to 'PoolAdhoc'
ALTER WORKLOAD GROUP GroupDataPumps
USING PoolDataPumps;
COMMIT TRAN;
GO


-- Apply the changes to the Resource Governor in-memory configuration.
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO


SELECT    Session_Id, Status
 FROM    sys.dm_exec_sessions AS S
       INNER JOIN sys.dm_resource_governor_workload_groups AS G
           ON S.group_id = G.group_id
 WHERE     G.name = 'Default';