REM Download and install Vosk model
echo Downloading Vosk model...
curl -L -O https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip
echo Unzipping Vosk model...
tar -xvzf vosk-model-en-us-0.22.zip
del vosk-model-en-us-0.22.zip