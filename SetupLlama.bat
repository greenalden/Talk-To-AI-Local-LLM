@echo off
echo Before running this script please make a hugging face account and request access to Llama-3.1-8B-Instruct from here https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct.
echo When you have gotten an email saying you have access to the model, create a token here https://huggingface.co/settings/tokens.
echo create a new token, leaving it as Fine-grained, checking the box that says Read access to contents of all public gated repos you can access.
echo after that you complete that save the token value, you will need it later.
echo If it ever asks you to Add token as git credential? Y/n just hit enter.
pause


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





:: Define the directory for Anaconda/Miniconda installation
set ANACONDA_DIR=%~dp0anaconda

:: Define the Miniconda installer URL and filename
set MINICONDA_INSTALLER=miniconda_installer.exe
set MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe

:: Check if Anaconda is already installed
if not exist "%ANACONDA_DIR%" (
    echo Anaconda not found. Installing Miniconda...

    :: Check if curl is available, else use PowerShell to download
    curl --version >nul 2>&1
    if errorlevel 1 (
        echo curl not found. Using PowerShell to download Miniconda...
        powershell -Command "Invoke-WebRequest -Uri %MINICONDA_URL% -OutFile %MINICONDA_INSTALLER%"
    ) else (
        curl -o "%MINICONDA_INSTALLER%" "%MINICONDA_URL%"
    )

    :: Install Miniconda
    start /wait "" "%MINICONDA_INSTALLER%" /InstallationType=JustMe /RegisterPython=0 /S /D=%ANACONDA_DIR%
    del "%MINICONDA_INSTALLER%"  :: Delete installer after installation
) else (
    echo Anaconda already installed.
)

:: Set the path to conda
set "PATH=%ANACONDA_DIR%\Scripts;%ANACONDA_DIR%\condabin;%PATH%"

:: Check if 'conda' is recognized
where conda >nul 2>&1
if errorlevel 1 (
    echo Running 'conda init'...
    call conda init
    echo Please restart your Command Prompt and run this script again.
    exit /b
)

:: Force install the specified Python version in the base environment
echo Installing Python 3.11.9 in the base environment...
call conda install python=3.11.9 -y


python -m pip install --upgrade pip

pip install --upgrade huggingface_hub
huggingface-cli login

git lfs install
git clone https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct

echo Done
pause