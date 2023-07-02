@echo off

REM Set the output file path
set OutputFile=C:\Shares.txt

REM Clear the output file
echo. > %OutputFile%

REM Get the list of shares
smbcacls -U administrator%password -L //NAS-IP-Address | findstr /B /C:"Share:" > shares.tmp

REM Export NTFS shares to the output file
for /f "tokens=2 delims= " %%a in (shares.tmp) do (
    smbcacls -U administrator%password -E //NAS-IP-Address/%%a | findstr /v /c:"ACL:"
    echo. >> %OutputFile%
)

REM Clean up temporary file
del shares.tmp

echo Shares exported successfully to %OutputFile%
