ECHO OFF
CHOICE /T 20 /d N /M "Backup AdventureWorks Database"
IF %ERRORLEVEL% == 1 SET Backup=Y
IF %ERRORLEVEL% == 2 SET Backup=N
IF "%Backup%" == "N" GOTO GOTO EndOfFile
ECHO ON
NET START MSSQL$SQL2005
"C:\Program Files\Microsoft SQL Server\90\Tools\Binn\sqlcmd.exe" -S %computername%\SQL2005 -d master -i "\\VBOXSVR\DropBox\SQL Server Scripts\Administration\Backup-Restore\AdventureWorks\AdventureWorks_Backup.sql"
TIMEOUT 10
:EndOfFile
EXIT