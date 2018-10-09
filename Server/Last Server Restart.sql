SELECT
      create_date AS SQL_Last_Started
FROM
      sys.databases
WHERE
      name = 'tempdb'