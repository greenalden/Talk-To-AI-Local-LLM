@echo off
echo Before running this script please make a hugging face account and request access to Llama-3.1-8B-Instruct from here https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct.
echo When you have gotten an email saying you have access to the model, create a token here https://huggingface.co/settings/tokens.
echo create a new token, leaving it as Fine-grained, checking the box that says Read access to contents of all public gated repos you can access.
echo after that you complete that save the token value, you will need it later.
echo If it ever asks you to Add token as git credential? Y/n just hit enter.
pause

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

REM Define download URL and installer filename
set "DOWNLOAD_URL=https://github.com/espeak-ng/espeak-ng/releases/download/1.51/espeak-ng-X64.msi"
set "INSTALLER=espeak-ng-X64.msi"

REM Download the installer using PowerShell (silent)
echo Downloading eSpeak-NG...
powershell -Command "Invoke-WebRequest -Uri %DOWNLOAD_URL% -OutFile %INSTALLER%"

REM Install eSpeak-NG (default installation location)
echo Installing eSpeak-NG...
msiexec /i %INSTALLER% /norestart

REM Clean up by deleting the installer
echo Cleaning up...
del %INSTALLER%



echo Installing Git...

:: Set download URL for Git installer (update URL if necessary)
set "GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe"

:: Set the path to download the installer
set "GIT_INSTALLER=%TEMP%\git_installer.exe"

:: Download Git installer
echo Downloading Git...
bitsadmin /transfer "Git Download" %GIT_URL% %GIT_INSTALLER%

:: Install Git silently (without user interaction)
echo Installing Git...
start /wait "" %GIT_INSTALLER% /VERYSILENT /NORESTART

:: Clean up the installer after installation
del /f /q %GIT_INSTALLER%

:: Check if Git was installed successfully
git --version
if %errorlevel% equ 0 (
    echo Git installed successfully!
) else (
    echo Git installation failed.
)


echo Installing Git again to avoid errors...
timeout /t 5

:: Set download URL for Git installer (update URL if necessary)
set "GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe"

:: Set the path to download the installer
set "GIT_INSTALLER=%TEMP%\git_installer.exe"

:: Download Git installer
echo Downloading Git...
bitsadmin /transfer "Git Download" %GIT_URL% %GIT_INSTALLER%

:: Install Git silently (without user interaction)
echo Installing Git...
start /wait "" %GIT_INSTALLER% /VERYSILENT /NORESTART

:: Clean up the installer after installation
del /f /q %GIT_INSTALLER%

:: Check if Git was installed successfully
git --version
if %errorlevel% equ 0 (
    echo Git installed successfully!
) else (
    echo Git installation failed.
)


REM Download Python 3.11.9 installer
curl https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe --output python_installer.exe

REM Run the Python installer silently
python_installer.exe /quiet InstallAllUsers=1 PrependPath=1

REM Verify Python installation
python --version

REM Clean up by deleting the installer
del python_installer.exe

@echo Python 3.11.9 installation complete!

echo Please restart your computer then run Setup2.bat
echo Make sure you have the key saved from huggingface, you will need it after the restart
pause