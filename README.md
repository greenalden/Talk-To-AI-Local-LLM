The vision and purpose of this


  My vision was to make an AI voice assistant that you would ask questions to, just like Google and Alexa, but this has 2 advantages. First, you have control over the name of the AI, including the wake word. Secondly and more importantly it is entirely on machine after setup,
  this would mean that your data is private. Right now the wake word is "icon", so if you mention anything with "icon" it will wake up. Feel free to change the wake word in the Python file.

This is a work in progress for the setup, as of now this only works on Windows and uses just over 4gb of VRAM and 14gb RAM. Just run the "SetupEverything - beta.bat", restart your computer, then use the "Run.bat" and you should be set.
This is Nvidia only, the reason for this is that it requires CUDA. The audio input device is whatever microphone is set in Windows, the program has no control over it for the time being.

IMPORTANT NOTE: Some folder directory names will cause the setup script not to work correctly, please avoid having it in a folder with something like " (1)" in it, which can happen if there is a duplicate file name.

