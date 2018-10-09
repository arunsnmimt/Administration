--- Super Search ---- 
DECLARE @SearchTerm NVARCHAR(4000)
DECLARE @ColumnName sysname


SET @SearchTerm = N'DipsPath' -- Term to be searched for, wildcards okay
SET @ColumnName = N'' 

SET NOCOUNT ON

DECLARE @TabCols TABLE (
      id INT NOT NULL PRIMARY KEY IDENTITY
    , table_schema sysname NOT NULL
    , table_name sysname NOT NULL
    , column_name sysname NOT NULL
    , data_type sysname NOT NULL
)
INSERT INTO @TabCols (table_schema, table_name, column_name, data_type)
    SELECT t.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE
    FROM INFORMATION_SCHEMA.TABLES t
        JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_SCHEMA = c.TABLE_SCHEMA
            AND t.TABLE_NAME = c.TABLE_NAME
    WHERE 1 = 1
        AND t.TABLE_TYPE = 'base table'
        AND c.DATA_TYPE NOT IN ('image', 'sql_variant')
        AND c.COLUMN_NAME LIKE CASE WHEN LEN(@ColumnName) > 0 THEN @ColumnName ELSE '%' END
    ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION

DECLARE
      @table_schema sysname
    , @table_name sysname
    , @column_name sysname
    , @data_type sysname
    , @exists NVARCHAR(4000) 
    , @sql NVARCHAR(4000) 
    , @where NVARCHAR(4000) 
    , @run NVARCHAR(4000) 

WHILE EXISTS (SELECT NULL FROM @TabCols) BEGIN

    SELECT TOP 1
          @table_schema = table_schema
        , @table_name = table_name
        , @exists = 'select null from [' + table_schema + '].[' + table_name + '] where 1 = 0'
        , @sql = 'select ''' + '[' + table_schema + '].[' + table_name + ']' + ''' as TABLE_NAME, * from [' + table_schema + '].[' + table_name + '] where 1 = 0'
        , @where = ''
    FROM @TabCols
    ORDER BY id

    WHILE EXISTS (SELECT NULL FROM @TabCols WHERE table_schema = @table_schema AND table_name = @table_name) BEGIN

        SELECT TOP 1
              @column_name = column_name
            , @data_type = data_type
        FROM @TabCols
        WHERE table_schema = @table_schema
            AND table_name = @table_name
        ORDER BY id

       
        IF @data_type IN ('money', 'smallmoney') BEGIN
            IF ISNUMERIC(@SearchTerm) = 1 BEGIN
                SET @where = @where + ' or [' + @column_name + '] = cast(''' + @SearchTerm + ''' as ' + @data_type + ')' -- could also cast the column as varchar for wildcards
            END
        END
        
        ELSE IF @data_type = 'xml' BEGIN
            SET @where = @where + ' or cast([' + @column_name + '] as nvarchar(max)) like ''' + @SearchTerm + ''''
        END
       
        ELSE IF @data_type IN ('date', 'datetime', 'datetime2', 'datetimeoffset', 'smalldatetime', 'time') BEGIN
            SET @where = @where + ' or convert(nvarchar(50), [' + @column_name + '], 121) like ''' + @SearchTerm + ''''
        END
        
        ELSE BEGIN
            SET @where = @where + ' or [' + @column_name + '] like ''' + @SearchTerm + ''''
        END

        DELETE FROM @TabCols WHERE table_schema = @table_schema AND table_name = @table_name AND column_name = @column_name

    END

    SET @run = 'if exists(' + @exists + @where + ') begin ' + @sql + @where + ' print ''' + @table_name + ''' end'
    PRINT @run
    EXEC sp_executesql @run

END

SET NOCOUNT OFF