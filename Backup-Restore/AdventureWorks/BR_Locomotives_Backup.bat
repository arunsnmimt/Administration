ECHO OFF
CHOICE /T 20 /d N /M "Backup BR_Locomotives Database"
IF %ERRORLEVEL% == 1 SET Backup=Y
IF %ERRORLEVEL% == 2 SET Backup=N
IF "%Backup%" == "N" GOTO GOTO EndOfFile
ECHO ON
IF "%COMPUTERNAME%" == "VBOXWIN7" GOTO VBOXWIN7
NET START MSSQL$SQL2012
"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe" -S %computername%\SQL2012 -d master -i "\\VBOXSVR\DropBox\SQL Server Scripts\Administration\Backup-Restore\AdventureWorks\BR_Locomotives_Backup.sql"
GOTO Wait10
:VBOXWIN7
NET START MSSQLSERVER
"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe" -S %computername% -d master -i "\\VBOXSVR\DropBox\SQL Server Scripts\Administration\Backup-Restore\AdventureWorks\BR_Locomotives_Backup.sql"
:Wait10
TIMEOUT 10
:EndOfFile
EXIT