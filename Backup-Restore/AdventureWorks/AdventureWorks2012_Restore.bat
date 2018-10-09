ECHO OFF
CHOICE /T 20 /d N /M "Restore AdventureWorks Database"
IF %ERRORLEVEL% == 1 SET Restore=Y
IF %ERRORLEVEL% == 2 SET Restore=N
IF "%Restore%" == "N" GOTO GOTO EndOfFile
ECHO ON
NET START MSSQL$SQL2012
"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe" -S %computername%\SQL2012 -d master -i "\\VBOXSVR\DropBox\SQL Server Scripts\Administration\Backup-Restore\AdventureWorks\AdventureWorks_Restore.sql"
TIMEOUT 10
:EndOfFile
EXIT