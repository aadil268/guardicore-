@echo off
echo Running CMD script via Cloudbase-Init... >> C:\Cloudbase-Init-Log2.txt
mkdir C:\Demo1 2>nul
echo CMD Script executed successfully on %date% %time% > C:\Demo1\status.txt

#Run Custom PowerShell Script
powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\cloudinit.ps1"

REM Disable Cloudbase-Init service
sc config cloudbase-init start= disabled