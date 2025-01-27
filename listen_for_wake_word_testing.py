import vosk
import os
import json
import sounddevice as sd
import time
import sys
current_dir = os.path.dirname(__file__)
WAKE_WORD = "icon"
extension_timeout=3
resetCacheLoops=0 # manages cache loops, do not touch
wakeWordString="" # manages what string has the wake word held in it, do not touch this variable.

numberOfCacheLoops=10 # loops before cache reset on wake word
modelVosk = vosk.Model(current_dir + "\\vosk-model-en-us-0.22")


def listen_for_wake_word(device_index=None):
    recognizer = vosk.KaldiRecognizer(modelVosk, 16000)
    
    wake_word_detected = False  # Flag to indicate if wake word was detected

    def audio_callback(indata, frames, time, status):
        global wakeWordString
        global resetCacheLoops
        global numberOfCacheLoops
        nonlocal wake_word_detected  # Reference the flag in the outer scope
        if status:
            print(f"Audio input error: {status}", file=sys.stderr)
        if recognizer.AcceptWaveform(indata.tobytes()):
            result = json.loads(recognizer.Result())
            wakeWordString = result
            #print(wakeWordString)
            print(f"Recognition result: {wakeWordString}")  # Debugging Vosk's processing
            if 'text' in result and WAKE_WORD in result['text'].lower():
                print(f"Wake word detected: {result['text']}")
                wake_word_detected = True
                return  # Stop processing further once detected
            if resetCacheLoops>=numberOfCacheLoops:
                print("Cache Reset")
                recognizer.Reset()
                resetCacheLoops=0
            resetCacheLoops+=1

    stream = sd.InputStream(samplerate=16000, blocksize=32000, device=device_index, 
                            channels=1, callback=audio_callback, dtype='int16')

    print("Listening for the wake word...")

    start_time = time.time()
    
    with stream:
        while not wake_word_detected:
            pass
        

    return wake_word_detected  # Return if the wake word was detected




def listen_for_wake_word2(device_index=None):
    recognizer = vosk.KaldiRecognizer(modelVosk, 16000)
    
    wake_word_detected = False  # Flag to indicate if wake word was detected

    def audio_callback(indata, frames, time, status):
        global wakeWordString
        global resetCacheLoops
        global numberOfCacheLoops
        nonlocal wake_word_detected  # Reference the flag in the outer scope
        if status:
            print(f"Audio input error: {status}", file=sys.stderr)
        if recognizer.AcceptWaveform(indata.tobytes()):
            result = json.loads(recognizer.Result())
            wakeWordString = result
            #print(wakeWordString)
            print(f"Recognition result: {wakeWordString}")  # Debugging Vosk's processing
            if 'text' in result and WAKE_WORD in result['text'].lower():
                print(f"Wake word detected: {result['text']}")
                wake_word_detected = True
                return  # Stop processing further once detected
            if resetCacheLoops>=numberOfCacheLoops:
                print("Cache Reset")
                recognizer.Reset()
                resetCacheLoops=0
            resetCacheLoops+=1

    stream = sd.InputStream(samplerate=16000, blocksize=64000, device=device_index, 
                            channels=1, callback=audio_callback, dtype='int16')

    print("Listening for the wake word...")

    start_time = time.time()
    
    with stream:
        while not wake_word_detected:
            pass
        

    return wake_word_detected  # Return if the wake word was detected




#Find a way to call a second version of the trascription while it proccesses the other one to avoid downtime
#There will need to be a way to avoid overlapping.
#May need asycio to alternate tasks later


mic_device_index=1
while True:
    print(listen_for_wake_word2(device_index=mic_device_index))