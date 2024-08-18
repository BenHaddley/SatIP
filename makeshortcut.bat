@echo off
setlocal

:: Define variables
set "scriptDir=%~dp0"  :: Directory where the batch script is located
set "targetFile=%scriptDir%SatIpRun.bat"
set "desktopPath=%USERPROFILE%\Desktop"
set "shortcutName=SatIP.lnk"  :: Updated shortcut name
set "shortcutPath=%desktopPath%\%shortcutName%"

:: Define icon path
set "iconFile=%scriptDir%kiwiimage.ico"

:: Check if the shortcut already exists
if exist "%shortcutPath%" (
    echo Shortcut already exists on the desktop.
    exit /b
)

:: Create the shortcut
powershell -NoProfile -Command ^
    $WshShell = New-Object -ComObject WScript.Shell; ^
    $Shortcut = $WshShell.CreateShortcut('%shortcutPath%'); ^
    $Shortcut.TargetPath = '%targetFile%'; ^
    $Shortcut.WorkingDirectory = '%scriptDir%'; ^
    $Shortcut.Arguments = ''; ^
    $Shortcut.IconLocation = '%iconFile%, 0'; ^
    $Shortcut.Save()

echo Shortcut created on the desktop.

endlocal
