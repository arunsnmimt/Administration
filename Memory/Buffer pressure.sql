/*
Buffer pressure


Trying to determine if you have pressure in your buffer allocations can be difficult. Buffer cache hit ratio is an almost useless metric, so you need a mechanism to let you know if there’s a problem in that area. You can use the memory dump from DBCC MEMORYSTATUS() and then compare the Target Committed to the Current Committed allocations. When the target is below the current committed, you’re looking at a buffer issue. This query simply compares the two with subtraction so that you’ll know when you’re looking at negative numbers you’ve hit a buffer problem.
*/


DECLARE @MemStat TABLE
  (
   ValueName SYSNAME,
   Val BIGINT
  );
INSERT INTO @MemStat
    EXEC ('DBCC memorystatus() WITH tableresults');
WITH  Measures
        AS (SELECT TOP 2 CurrentValue,
                ROW_NUMBER() OVER (ORDER BY OrderColumn) AS RowOrder
              FROM (SELECT CASE WHEN (ms.ValueName = 'Target Committed')
                                THEN ms.Val
                                WHEN (ms.ValueName = 'Current Committed')
                                THEN ms.Val
                           END AS 'CurrentValue',
                        0 AS 'OrderColumn'
                      FROM @MemStat AS ms
                   ) AS MemStatus
              WHERE CurrentValue IS NOT NULL
           )
  SELECT TargetMem.CurrentValue - CurrentMem.CurrentValue
    FROM Measures AS TargetMem
    JOIN
      Measures AS CurrentMem
    ON
      TargetMem.RowOrder + 1 = CurrentMem.RowOrder;