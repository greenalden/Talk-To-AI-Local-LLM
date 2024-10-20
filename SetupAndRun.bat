@echo off
:: Define the directory for Anaconda/Miniconda installation
set ANACONDA_DIR=%~dp0anaconda

:: Define the Miniconda installer URL and filename
set MINICONDA_INSTALLER=miniconda_installer.exe
set MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe

:: Check if Anaconda is already installed
if not exist "%ANACONDA_DIR%" (
    echo "Anaconda not found. Installing Miniconda..."
    curl -o "%MINICONDA_INSTALLER%" "%MINICONDA_URL%"
    start /wait "" "%MINICONDA_INSTALLER%" /InstallationType=JustMe /RegisterPython=0 /S /D=%ANACONDA_DIR%
    del "%MINICONDA_INSTALLER%"  :: Delete installer after installation
) else (
    echo "Anaconda already installed."
)

:: Set the path to conda
set "PATH=%ANACONDA_DIR%\Scripts;%ANACONDA_DIR%\condabin;%PATH%"

:: Create or activate a conda environment (optional)
call conda create -n myenv python=3.10 -y
call conda activate myenv

:: Define the packages to install
set PACKAGES="numpy" "pandas" "matplotlib" "torch==2.2.2+cu121" "transformers==4.45.1" "TTS==0.22.0" "pydub==0.25.1" "vosk==0.3.45" "sounddevice==0.5.0"

:: Check if packages are already installed and install if necessary
for %%P in (%PACKAGES%) do (
    conda list | findstr "%%~P" >nul
    if errorlevel 1 (
        echo "Installing %%~P..."
        pip install %%~P
    ) else (
        echo "%%~P is already installed."
    )
)

:: Run the specified Python script
set PYTHON_SCRIPT=%~dp0TalkingToAILocalLLM.py
if exist "%PYTHON_SCRIPT%" (
    python "%PYTHON_SCRIPT%"
) else (
    echo "Python script not found."
)

:: End of script
echo "Done."
pause
