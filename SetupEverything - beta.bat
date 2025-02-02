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



REM Download and install Vosk model
echo Downloading Vosk model...
curl -L -O https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip
echo Unzipping Vosk model...
tar -xvzf vosk-model-en-us-0.22.zip
del vosk-model-en-us-0.22.zip




echo Before continuing make sure Visual Studio finished installing
pause



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



pip install numpy
pip install pandas
pip install --upgrade pip setuptools wheel
pip install build
pip cache purge
pip install matplotlib==3.9.2
pip install setuptools==75.1.0
pip install transformers==4.45.1
pip install vosk==0.3.45
pip install sounddevice==0.5.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install accelerate==0.33.0
pip install bitsandbytes==0.43.3
pip install simpleaudio==1.0.4
pip install --upgrade pip setuptools wheel
pip install build
pip cache purge
pip install TTS==0.22.0 "transformers==4.45.1" "setuptools==75.1.0" "jieba==0.42.1" "encodec==0.1.1" "gruut_lang_de==2.0.1" "gruut_lang_en==2.0.1" "gruut_lang_es==2.0.1" "gruut_lang_fr==2.0.2" "contourpy==1.3.0" "spacy==3.7.6"
conda install -c anaconda git -y
git lfs install
git clone https://huggingface.co/google/gemma-2-2b-it





:: End of script
echo Done.
echo Please restart your computer before using Run.bat
echo You will need an internet connection for the first time using Run.bat
pause