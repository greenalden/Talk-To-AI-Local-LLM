@echo off
echo Installing Visual Studio with specified workloads...

:: Set download URL for the Visual Studio Installer (Community edition)
set "VS_URL=https://aka.ms/vs/17/release/vs_community.exe"

:: Set the path to download the installer
set "VS_INSTALLER=%TEMP%\vs_installer.exe"

:: Download the Visual Studio installer using bitsadmin
echo Downloading Visual Studio Installer...
bitsadmin /transfer "VS Download" %VS_URL% %VS_INSTALLER%

:: Install Visual Studio with the desired workloads silently
echo Installing Visual Studio with .NET Desktop, Python, and C++ Desktop workloads...
start /wait "" %VS_INSTALLER% ^
    --add Microsoft.VisualStudio.Workload.ManagedDesktop ^
    --add Microsoft.VisualStudio.Workload.Python ^
    --add Microsoft.VisualStudio.Workload.NativeDesktop ^
    --includeRecommended ^
    --passive ^
    --norestart

:: Clean up the installer after installation
del /f /q %VS_INSTALLER%

:: Visual Studio installation is assumed successful if installer runs correctly
echo Visual Studio installation has been initiated. Verify through Visual Studio Installer.

pause
