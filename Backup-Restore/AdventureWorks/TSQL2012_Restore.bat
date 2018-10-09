ECHO OFF
CHOICE /T 20 /d N /M "Restore TSQL2012 Database"
IF %ERRORLEVEL% == 1 SET Restore=Y
IF %ERRORLEVEL% == 2 SET Restore=N
IF "%Restore%" == "N" GOTO GOTO EndOfFile
ECHO ON
IF "%COMPUTERNAME%" == "VBOXWIN7" GOTO VBOXWIN7
NET START MSSQL$SQL2012
"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe" -S %computername%\SQL2012 -d master -i "\\VBOXSVR\DropBox\SQL Server Scripts\Administration\Backup-Restore\AdventureWorks\TSQL2012_Restore.sql"
GOTO Wait10
:VBOXWIN7
NET START MSSQLSERVER
"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe" -S %computername% -d master -i "\\VBOXSVR\DropBox\SQL Server Scripts\Administration\Backup-Restore\AdventureWorks\TSQL2012_Restore.sql"
:Wait10
TIMEOUT 10
:EndOfFile
EXIT