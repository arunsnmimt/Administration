/*
Performance-related database settings

If you manage a server where you are not in complete control of the creation of databases, or you’re unfamiliar with what settings to change, you may miss things out or set them incorrectly. This metric could pick up on issues that affect performance in obscure ways, and saves you having to search for them when a system suddenly stops performing as you would expect.

The settings here are not a complete list and the values attributed to them are not necessarily how you may choose to have them. They are provided as examples of how to test for settings and how to attribute a severity to the setting. A higher value indicates a setting that you are more interested in, ensuring it meets your own best practice.

*/

DECLARE @Result INT;
DECLARE @High INT; -- For settings you feel need to be right
DECLARE @Med INT; -- For settings you want to know about but arent critical
DECLARE @Low INT; -- For settings that you want flagged but are low importance
 
SELECT @High = 70,
    @Med = 40,
    @Low = 10;
 
SELECT @Result = SUM(CASE WHEN [d].[compatibility_level] != [d2].[compatibility_level]
                          THEN @Med
                          ELSE 0
                     END
                   + CASE WHEN [d].[collation_name] != [d2].[collation_name]
                          THEN @Med
                          ELSE 0
                     END
                   + CASE WHEN [d].[user_access] != 0
                          THEN @Low
                          ELSE 0
                     END
                   + CASE WHEN [d].[is_auto_close_on] = 1
                          THEN @High
                          ELSE 0
                     END
                   + CASE WHEN [d].[is_auto_shrink_on] = 1
                          THEN @High
                          ELSE 0
                     END
                   + CASE WHEN [d].[state] != 0
                          THEN @Low
                          ELSE 0
                     END
                   + CASE WHEN [d].[is_auto_create_stats_on] != 1
                          THEN @Med
                          ELSE 0
                     END
                   + CASE WHEN [d].[is_auto_update_stats_on] != 1
                          THEN @Med
                          ELSE 0
                     END
                   + CASE WHEN [d].[is_ansi_nulls_on] = 1
                          THEN @High
                          ELSE 0
                     END
                   + CASE WHEN [d].[is_ansi_padding_on] = 1
                          THEN @High
                          ELSE 0
                     END
                   + CASE WHEN [d].[is_ansi_warnings_on] = 1
                          THEN @High
                          ELSE 0
                     END
                   + CASE WHEN [d].[is_arithabort_on] = 1
                          THEN @High
                          ELSE 0
                     END)
  FROM [sys].[databases] AS d
  CROSS JOIN [sys].[databases] AS d2
  WHERE [d2].[name] = 'master'
    AND ([d].[database_id] = DB_ID()
    AND [d].[state_desc] = 'Online');
 
SELECT @Result;