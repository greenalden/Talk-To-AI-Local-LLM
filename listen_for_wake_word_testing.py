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
    global extension_timeout
    global wakeWordString
    recognizer = vosk.KaldiRecognizer(modelVosk, 16000)
    
    transcribed_text = ""
    last_full_result = ""  # Store the last full result to compare against partials
    last_partial_result = ""  # Store the last partial result to track changes
    last_change_time = time.time()  # Track the time of the last detected speech

    def audio_callback(indata, frames, time_info, status):
        nonlocal transcribed_text, last_partial_result, last_full_result, last_change_time
        
        if status:
            print(f"Audio input error: {status}", file=sys.stderr)

        if recognizer.AcceptWaveform(indata.tobytes()):  # If a full result is available
            result = json.loads(recognizer.Result())
            if 'text' in result and result['text']:
                # Append the full result to the transcribed text
                if result['text'] != last_full_result:
                    transcribed_text += result['text'] + " "  # Append only new full result
                    last_full_result = result['text']  # Update the last full result
                    last_partial_result = ""  # Clear the last partial result after full result
                    print(f"Full transcription result: {result['text']}")
                    transcribed_text=result['text']
                last_change_time = time.time()  # Reset the last change time
        else:  # If it's a partial result
            partial_result = json.loads(recognizer.PartialResult())
            if 'partial' in partial_result:
                # Append only the new part of the partial result
                new_partial_text = partial_result['partial'][len(last_partial_result):]
                if new_partial_text:  # Ensure new partial text exists
                    transcribed_text += new_partial_text  # Append only new partial text
                    #print(f"Partial result: {transcribed_text.strip()}")
                    last_partial_result = partial_result['partial']  # Update the last partial result
                    last_change_time = time.time()  # Reset the last change time

    stream = sd.InputStream(samplerate=16000, blocksize=16000, device=device_index, 
                            channels=1, callback=audio_callback, dtype='int16')

    print("Recording your speech...")

    with stream:
        while True:
            current_time = time.time()
            
            # If no new partial results or full transcriptions are detected for `extension_timeout`, stop recording
            if current_time - last_change_time > extension_timeout:
                print("No new input detected. Stopping recording.")
                break

    if not transcribed_text:
        print("No transcription available or timeout.")
        #return None
    
    print("Final transcription result: "+ (str(wakeWordString)[10:])[:-2] + ". " + (transcribed_text.strip()))
    print()
    return ((str(wakeWordString)[10:])[:-2] + ". " + transcribed_text.strip())




#Find a way to call a second version of the trascription while it proccesses the other one to avoid downtime
#There will need to be a way to avoid overlapping.


mic_device_index=1
while True:
    print(listen_for_wake_word2(device_index=mic_device_index))