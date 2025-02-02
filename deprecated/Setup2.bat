@echo off




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


pip install --upgrade huggingface_hub
huggingface-cli login

git lfs install
git clone https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct


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
timeout /t 5
pip install TTS==0.22.0 "transformers==4.45.1" "setuptools==75.1.0" "jieba==0.42.1" "encodec==0.1.1" "gruut_lang_de==2.0.1" "gruut_lang_en==2.0.1" "gruut_lang_es==2.0.1" "gruut_lang_fr==2.0.2" "contourpy==1.3.0" "spacy==3.7.6"






:: End of script
echo Done.
echo If everything ran without problems go ahead and try the Run.bat file.
echo If you found an error right at the end try running the SetupPython.bat, this sometimes will fix it.
echo If you had problems installing the applications at the start run the Setup_Instructions_old.bat and try this file again.
echo If all aplications installed but the AI models are missing try the SetupAIModels.bat, make sure to delete the old folders first if those started installing.
echo For any other questions feel free to reach out on GitHub
pause