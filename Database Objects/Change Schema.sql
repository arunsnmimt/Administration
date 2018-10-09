   SELECT 'ALTER SCHEMA dbo TRANSFER ' + s.Name + '.' + o.Name 
    FROM sys.Objects o 
    INNER JOIN sys.Schemas s on o.schema_id = s.schema_id 
    WHERE s.Name = 'TMC'
    And (o.Type = 'U' Or o.Type = 'P' Or o.Type = 'V')