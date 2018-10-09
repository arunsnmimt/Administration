 
SELECT  name,  'ALTER DATABASE [' + name + '] SET ONLINE; DROP DATABASE [' + name + ']'
FROM    sys.databases
WHERE state_desc = 'OFFLINE' 
AND name LIKE 'TMC%'
ORDER BY name


--ALTER DATABASE [TMC_Test_Offine] SET ONLINE; DROP DATABASE [TMC_Test_Offine]