/*
Database growth steps available

This metric measures the number of available autogrowth steps for a database, so you can see when they are reduced or increased because something else (e.g. another database) starts or stops taking up space, when storage is added, etc.


This metric calculates the number of autogrowth steps available for a database at a given time. It does this from a database file level, taking into account:

    database file’s current size
    database file’s max size
    growth info (is growth allowed, is growth unlimited, is growth flat or percentage based, growth step size in MB or percent)
    free space for each drive where database files are located

The final number of available steps is the sum of available steps for each database data file.
*/


DECLARE @DriveSpaceFree TABLE (
   Drive CHAR(1)
  ,FreeMB INT);
 
INSERT INTO @DriveSpaceFree
   EXEC xp_fixeddrives
 
SELECT
   SUM(FileGrowthStepsAvailable) AS SumSteps
FROM
   (SELECT
      CASE WHEN IsGrowthAllowed = 0 THEN 0 -- no growth is allowed => no steps available
           WHEN FileMaxSize = -1 -- unlimited growth => space available is limited by free space on drive
                OR (FileMaxSize <> -1 -- limited growth, but less space on drive than growth space left in files => space available is limited by free space on drive
                    AND FreeOnDrive < (FileMaxSize - CurrentFileSize))
           THEN CASE IsPercentGrowth
                  WHEN 0 THEN CAST(FreeOnDrive / FileGrowthStepMB AS INT)
                  ELSE CAST(LOG((FreeOnDrive / CurrentFileSize) + 1) / LOG(1 + (FileGrowthStepPct / 100.)) AS INT)
                END
           ELSE -- limited growth, space available is limited by max file size
                CASE IsPercentGrowth
                  WHEN 0 THEN CAST((FileMaxSize - CurrentFileSize) / FileGrowthStepMB AS INT)
                  ELSE CAST(LOG(FileMaxSize / CurrentFileSize) / LOG(1 + (FileGrowthStepPct / 100.)) AS INT)
                END
      END AS FileGrowthStepsAvailable
    FROM
      (SELECT
        df.size / 128. AS CurrentFileSize
        ,CASE WHEN df.max_size > 0 THEN df.max_size / 128.
              WHEN df.max_size < 0 THEN -1 -- unlimited growth
              ELSE df.size / 128. -- max_size=0 => no growth is allowed => FileMaxSize = CurrentFileSize
         END AS FileMaxSize
        ,CASE WHEN df.max_size = 0 THEN 0
              ELSE 1
         END AS IsGrowthAllowed
        ,dsf.FreeMB AS FreeOnDrive
        ,df.growth / 128. AS FileGrowthStepMB
        ,df.growth AS FileGrowthStepPct
        ,df.is_percent_growth AS IsPercentGrowth
       FROM
         sys.database_files df
         JOIN @DriveSpaceFree dsf
            ON LEFT(df.physical_name,1) = dsf.Drive
       WHERE
         df.type = 0 /* rows data */) AS InforPerFile) AS t