/*
Percentage of used/available database space


This metric measures the ratio between used database space and total available space, taking into account the following database file metrics:

    current used space
    current size
    maximum size
    free space for each drive where database files are located

The actual available space per drive is calculated first, followed by the sum of the total used space from drives and the total available space from drives. These values are then used to calculate the global percentage.

The metric helps you to maintain control over the database storage area, and monitor database growth in combination with general space management on a database file’s host. If available space decreases or increases because something else in your environment, such as another database, starts or stops taking up space, you may want to analyze this further. You are also alerted when the percentage increases signficantly.

This metric measures the ratio between used database space and total available space, taking into account the database file's current used space, current size, maximum size, and free space for each drive where database files are located. The actual available space per drive is calculated first, followed by the sum of the total used space from drives and the total available space from drives. These values are then used to calculate the global percentage. The metric helps you to help you maintain control over the database storage area, and monitor database growth in combination with general space management on a database file's host. If available space decreases or increases because something else in your environment, such as another database, starts or stops taking up space, you may want to analyze this further. You are also alerted when the percentage increases signficantly.
*/

DECLARE @DriveSpaceFree TABLE (Drive CHAR(1),FreeMB INT);
 
INSERT   INTO @DriveSpaceFree
         EXEC xp_fixeddrives
 
SELECT
   (SUM(SpaceUsedInFiles) / SUM(TotalAvailableSpaceForFiles)) * 100 AS PctFilled
FROM
   (SELECT
      Drive
     ,SUM(FileSpaceUsed) AS SpaceUsedInFiles
     ,CASE WHEN MIN(FileMaxSize) = -1 -- unlimited growth => space available is limited by free space on drive
                OR (MIN(FileMaxSize) <> -1 -- limited growth, but less space on drive than growth space left in files => space available is limited by free space on drive
                    AND MAX(FreeOnDrive) < SUM(FileMaxSize - CurrentFileSize)) THEN SUM(CurrentFileSize) + MAX(FreeOnDrive)
           ELSE SUM(FileMaxSize)
      END AS TotalAvailableSpaceForFiles
    FROM
      (SELECT
         FILEPROPERTY(df.name,'SpaceUsed') / 128. AS FileSpaceUsed
        ,df.size / 128. AS CurrentFileSize
        ,CASE WHEN df.max_size > 0 THEN df.max_size / 128.
              WHEN df.max_size < 0 THEN -1 -- unlimited growth
              ELSE df.size / 128. -- max_size=0 => no growth is allowed => FileMaxSize = CurrentFileSize
         END AS FileMaxSize
        ,dsf.Drive
        ,dsf.FreeMB AS FreeOnDrive
       FROM
         sys.database_files df
         JOIN @DriveSpaceFree dsf
            ON LEFT(df.physical_name,1) = dsf.Drive
       WHERE
         df.type = 0 /* rows data */) AS InfoPerFile
    GROUP BY
      Drive) AS InfoPerDrive