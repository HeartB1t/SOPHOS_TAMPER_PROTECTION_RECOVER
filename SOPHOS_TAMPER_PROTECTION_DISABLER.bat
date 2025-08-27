@echo off
mode con: cols=100 lines=30
title SOPHOS TAMPER PROTECTION DISABLER
color 9F

echo.
echo ╔════════════════════════════════════════════════════╗
echo ║    DISABLE SOPHOS TAMPER PROTECTION TOOL           ║
echo ╚════════════════════════════════════════════════════╝
echo.

::  Check for administrative privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] PLEASE RUN THIS SCRIPT AS ADMINISTRATOR.
    pause >nul
    exit /b
)

::  Check if Tamper Protection is enabled
reg query "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Sophos Endpoint Defense\TamperProtection\Config" /v SEDEnabled >nul 2>&1
IF %ERRORLEVEL% EQU 1 (
    echo [✓] Sophos is installed, but Tamper Protection is already disabled.
    goto skipTamper
) ELSE (
    echo [!] Sophos is installed and Tamper Protection is active.
    goto menu
)

:menu
cls
echo.
echo ╔══════════════════════════════════════════════╗
echo ║               ACTION MENU                    ║
echo ╠══════════════════════════════════════════════╣
echo ║ 1. I have renamed SophosED.sys via Recovery  ║
echo ║ 2. Display recovery instructions             ║
echo ║ 3. Watch Sophos removal tutorial video       ║
echo ╚══════════════════════════════════════════════╝
choice /c 123 /n /m "Select an option: "
if errorlevel 3 goto videoInstructions
if errorlevel 2 goto instructions
if errorlevel 1 goto disableTamper

:videoInstructions
start https://www.youtube.com/watch?v=RBumuKG9y4k
echo.
echo Press any key to return to the menu.
pause >nul
goto menu

:instructions
cls
echo ***************************************************************
echo ** Sophos Recovery Instructions (Offline)                    **
echo ***************************************************************
echo.
echo 1. Boot into Advanced Recovery Mode (WinRE).
echo 2. Navigate to Troubleshoot → Advanced Options → Command Prompt.
echo 3. Use 'diskpart' > 'list volume' to identify the Windows drive letter.
echo 4. Change directory: cd /d D:\Windows\System32\drivers
echo 5. Rename driver: ren SophosED.sys SophosED.sys.old
echo 6. Type 'exit' and continue to boot into Windows.
echo 7. Re-run this script as Administrator to proceed.
echo.
echo ***************************************************************
pause
goto menu

:skipTamper
echo.
echo Now you can uninstall Sophos from Control Panel.
pause
start appwiz.cpl
exit /b

:disableTamper
echo.
echo [*] Disabling Sophos Tamper Protection via registry...

:: Disable core services
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Sophos MCS Agent" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SAVService" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Sophos AutoUpdate Service" /v Start /t REG_DWORD /d 4 /f

:: Disable TamperProtection on all known services
for %%S in (
    hmpalert hmpalertsvc SAVAdminService SAVOnAccess SAVService
    sntp "Sophos AutoUpdate Service" "Sophos Clean Service" "Sophos Device Control Service"
    "Sophos ELAM" "Sophos Endpoint Defense" "Sophos Endpoint Defense Service"
    "Sophos File Scanner" "Sophos Health Service" "Sophos Live Query"
    "Sophos MCS Agent" "Sophos MCS Client" "Sophos Network Threat Protection"
    "Sophos Safestore Service" "Sophos System Protection Service"
    "Sophos Web Control Service" SophosBootDriver sophosntplwf
    swi_callout swi_filter swi_service swi_update swi_update_64
) do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Sophos Endpoint Defense\TamperProtection\Services\%%S" /v Protected /t REG_DWORD /d 0 /f >nul 2>&1
)

:: Disable main Tamper settings
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Sophos Endpoint Defense\TamperProtection\Config" /v SAVEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Sophos Endpoint Defense\TamperProtection\Config" /v SEDEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\WOW6432Node\Sophos\SAVService\TamperProtection" /v Enabled /t REG_DWORD /d 0 /f

echo.
echo [✓] Tamper Protection disabled. You may uninstall Sophos now.
pause
start appwiz.cpl
exit /b

