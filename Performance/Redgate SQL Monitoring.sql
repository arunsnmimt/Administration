--SELECT 
--CASE WHEN csk.[_Name]!='' THEN ck.[_Name] + '\' + csk.[_Name] ELSE ck.[_Name] END AS ClusterName,
--csk.Id AS ClusterKey
-- FROM [DATA].Cluster_Keys AS ck
--INNER JOIN [DATA].Cluster_SqlServer_Keys csk ON ck.Id=csk.ParentId
--WHERE csk._Name<>'*'

DECLARE @paramCluster INT = 9
DECLARE @pStart DATETIME = GETDATE() - 2
DECLARE @pEnd DATETIME = GETDATE() 

-- SELECT    ROW_NUMBER() OVER ( ORDER BY CollectionDate_DateTime DESC ) AS rownum,
--                        cs.CollectionDate_DateTime ,
--                        SUM(cs.Cluster_Machine_Process_CumulativeUserTime) AS Cluster_Machine_Process_CumulativeUserTime
--              FROM      data.Cluster_Machine_Process_UnstableSamples_View AS cs 
--             INNER JOIN [DATA].[Cluster_Keys] ck ON cs.Cluster_Name=ck.[_Name]
--  WHERE cs.Cluster_Name='sqlvs22'
--                  --       AND csk.Id = @paramCluster
--                        AND CollectionDate_DateTime BETWEEN @pStart AND @pEnd
--GROUP BY  CollectionDate_DateTime
--ORDER BY  cs.CollectionDate_DateTime 

--IF OBJECT_ID('tempdb..#CPUdata_1') > 0 
--        DROP TABLE #CPUdata_1

--    SELECT  CONVERT(CHAR(12), later.CollectionDate_DateTime, 106) AS CollectionDate ,
  SELECT      later.CollectionDate_DateTime AS CollectionDateTime ,
            CASE WHEN later.CollectionDate - earlier.CollectionDate = 0 THEN 0
                 ELSE ( later.Cluster_SqlServer_Process_CumulativeUserTime
                        - earlier.Cluster_SqlServer_Process_CumulativeUserTime )
                      / CAST(( later.CollectionDate - earlier.CollectionDate ) AS FLOAT)
            END AS CPU 

    FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY CollectionDate_DateTime DESC ) AS rownum ,
                        cs.CollectionDate_DateTime ,
                        cs.CollectionDate ,
                        cs.Cluster_SqlServer_Process_CumulativeUserTime
              FROM      data.Cluster_SqlServer_Process_UnstableSamples_View AS cs 
              INNER JOIN [DATA].[Cluster_Keys] ck ON cs.Cluster_Name=ck.[_Name]
  INNER JOIN [DATA].[Cluster_SqlServer_Keys] AS csk ON ck.Id=csk.ParentId
  WHERE cs.Cluster_SqlServer_Name=csk.[_Name]
                         AND csk.Id = @paramCluster
                        AND CollectionDate_DateTime BETWEEN @pStart AND @pEnd
            ) AS later
            INNER JOIN ( SELECT ROW_NUMBER() OVER ( ORDER BY CollectionDate_DateTime DESC ) AS rownum ,
                                cs.CollectionDate_DateTime ,
                                cs.CollectionDate ,
                                cs.Cluster_SqlServer_Process_CumulativeUserTime
                         FROM   data.Cluster_SqlServer_Process_UnstableSamples_View  AS cs 
              INNER JOIN [DATA].[Cluster_Keys] ck ON cs.Cluster_Name=ck.[_Name]
  INNER JOIN [DATA].[Cluster_SqlServer_Keys] AS csk ON ck.Id=csk.ParentId
  WHERE cs.Cluster_SqlServer_Name=csk.[_Name]
                         AND csk.Id = @paramCluster
                                AND CollectionDate_DateTime BETWEEN @pStart AND @pEnd
                       ) AS earlier ON later.rownum = earlier.rownum - 1


                       
                       
  SELECT      later.CollectionDate_DateTime AS CollectionDateTime ,
            CASE WHEN later.CollectionDate - earlier.CollectionDate = 0 THEN 0
                 ELSE ( later.Cluster_Machine_Process_CumulativeUserTime
                        - earlier.Cluster_Machine_Process_CumulativeUserTime )
                      / CAST(( later.CollectionDate - earlier.CollectionDate ) AS FLOAT)
            END AS CPU 

    FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY CollectionDate_DateTime DESC ) AS rownum ,
                        cs.CollectionDate_DateTime ,
                        cs.CollectionDate ,
                        SUM(cs.Cluster_Machine_Process_CumulativeUserTime) AS Cluster_Machine_Process_CumulativeUserTime
              FROM      data.Cluster_Machine_Process_UnstableSamples_View AS cs 
  --            INNER JOIN [DATA].[Cluster_Keys] ck ON cs.Cluster_Name=ck.[_Name]
  --INNER JOIN [DATA].[Cluster_SqlServer_Keys] AS csk ON ck.Id=csk.ParentId
  WHERE cs.Cluster_Name='sqlvs22'
--                         AND csk.Id = @paramCluster
                        AND CollectionDate_DateTime BETWEEN @pStart AND @pEnd
                        GROUP BY CollectionDate_DateTime, CS.CollectionDate
            ) AS later
            INNER JOIN ( SELECT ROW_NUMBER() OVER ( ORDER BY CollectionDate_DateTime DESC ) AS rownum ,
                                cs.CollectionDate_DateTime ,
                                cs.CollectionDate ,
                                SUM(cs.Cluster_Machine_Process_CumulativeUserTime) AS Cluster_Machine_Process_CumulativeUserTime
                         FROM    data.Cluster_Machine_Process_UnstableSamples_View  AS cs 
  --            INNER JOIN [DATA].[Cluster_Keys] ck ON cs.Cluster_Name=ck.[_Name]
  --INNER JOIN [DATA].[Cluster_SqlServer_Keys] AS csk ON ck.Id=csk.ParentId
  WHERE cs.Cluster_Name='sqlvs22'
--                         AND csk.Id = @paramCluster
                                AND CollectionDate_DateTime BETWEEN @pStart AND @pEnd
                          GROUP BY CollectionDate_DateTime, CS.CollectionDate
                       ) AS earlier ON later.rownum = earlier.rownum - 1                   
                       ORDER BY   CollectionDateTime DESC  