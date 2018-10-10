
DECLARE @command varchar(1000) 
SELECT @command = 'USE ? ALTER AUTHORIZATION ON DATABASE::[?] TO [sa]' 
EXEC sp_MSforeachdb @command 