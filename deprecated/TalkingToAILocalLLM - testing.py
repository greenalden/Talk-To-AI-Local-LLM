import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, LlamaConfig, StoppingCriteria, StoppingCriteriaList
from TTS.api import TTS
import vosk
import json
import time
import sys
import sounddevice as sd
import os
import simpleaudio as sa
import random
current_dir = os.path.dirname(__file__)
resetCacheLoops=0 # manages cache loops, do not touch
wakeWordString="" # manages what string has the wake word held in it, do not touch this variable.

numberOfCacheLoops=10 # loops before cache reset on wake word


WAKE_WORD = "icon"  # Change this to your desired name for the AI, this is also the wake word

# Load Vosk model (make sure the path to the model is correct)
modelVosk = vosk.Model(current_dir + "\\vosk-model-en-us-0.22")

def text_to_speech(text, output_file="output.wav", model_name="tts_models/en/vctk/vits", use_gpu=True, speaker_id=None, speed=1.0):
    try:
        tts = TTS(model_name=model_name, progress_bar=True, gpu=use_gpu)
        print(f"Using model: {model_name}")
        print(f"Text: {text}")
        print(f"Talking Speed: {speed}")
        tts.tts_to_file(text=text, speaker=speaker_id, file_path=output_file, speed=speed)
        print(f"Speech saved to {output_file}")
    except Exception as e:
        print(f"Error: {e}")

# Load the tokenizer
tokenizer = AutoTokenizer.from_pretrained(current_dir + "\\gemma-2-2b-it")
if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

# Load the model
#config = LlamaConfig.from_pretrained(current_dir + "\\Llama-3.1-8B-Instruct")
model = AutoModelForCausalLM.from_pretrained(
    current_dir + "\\gemma-2-2b-it",
    #config=config,
    torch_dtype=torch.float32,
    load_in_4bit=True,
    device_map="auto"
)

conversation_history = []

class StopOnTokens(StoppingCriteria):
    def __init__(self, stop_token_ids):
        self.stop_token_ids = stop_token_ids

    def __call__(self, input_ids, scores, **kwargs):
        for stop_id in self.stop_token_ids:
            if input_ids[0][-1] == stop_id:
                return True
        return False

def generate_response(prompt):
    global conversation_history
    conversation_history.append({"role": "human", "content": prompt})
    full_prompt = "Below is a conversation between a human and an AI assistant. The assistant gives helpful, detailed, and polite responses. The name of the AI assistant is " + WAKE_WORD + ".\n\n"
    for turn in conversation_history:
        if turn["role"] == "human":
            full_prompt += f"Human: {turn['content']}\n"
        else:
            full_prompt += f"Assistant: {turn['content']}\n"
    full_prompt += "Assistant:"
    inputs = tokenizer(full_prompt, return_tensors="pt", padding=True, truncation=True, max_length=512)
    inputs = {k: v.to(model.device) for k, v in inputs.items()}
    stop_token_ids = [tokenizer.encode("\nHuman:", add_special_tokens=False)[-1]]
    stopping_criteria = StoppingCriteriaList([StopOnTokens(stop_token_ids)])
    with torch.no_grad():
        outputs = model.generate(
            input_ids=inputs['input_ids'],
            attention_mask=inputs['attention_mask'],
            max_new_tokens=500,
            do_sample=True,
            temperature=0.7,
            top_p=0.9,
            pad_token_id=tokenizer.pad_token_id,
            eos_token_id=tokenizer.eos_token_id,
            bos_token_id=tokenizer.bos_token_id,
            stopping_criteria=stopping_criteria,
        )
    response = tokenizer.decode(outputs[0, inputs['input_ids'].shape[-1]:], skip_special_tokens=True)
    response = response.strip()
    if response.endswith("Human:"):
        response = response.removesuffix("Human:")
    conversation_history.append({"role": "assistant", "content": response})
    return response

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
        
    audioPlay_wake=(current_dir + "\\wake_responses\\" + str(random.randint(1, 4))+".wav")
    wave_obj_wake = sa.WaveObject.from_wave_file(audioPlay_wake)
    play_obj_wake = wave_obj_wake.play()
    play_obj_wake.wait_done()
    return wake_word_detected  # Return if the wake word was detected




import queue
import threading

def listen_for_wake_word2(device_index=None):
    recognizer = vosk.KaldiRecognizer(modelVosk, 16000)
    audio_queue = queue.Queue()
    wake_word_detected = threading.Event()  # Flag to signal detection

    def audio_callback(indata, frames, time, status):
        if status:
            print(f"Audio input error: {status}", file=sys.stderr)
        audio_queue.put(bytes(indata))  # Push audio to queue

    def process_audio():
        while not wake_word_detected.is_set():
            audio_data = audio_queue.get()
            if recognizer.AcceptWaveform(audio_data):
                result = json.loads(recognizer.Result())
                print(f"Recognition result: {result}")  # Debugging output
                if "text" in result and WAKE_WORD in result["text"].lower():
                    print(f"Wake word detected: {result['text']}")
                    wake_word_detected.set()  # Stop listening
            else:
                partial_result = json.loads(recognizer.PartialResult())
                if "partial" in partial_result and WAKE_WORD in partial_result["partial"].lower():
                    print(f"Wake word detected (partial): {partial_result['partial']}")
                    wake_word_detected.set()  # Stop immediately

    stream = sd.InputStream(
        samplerate=16000, blocksize=4000,  # Smaller chunks = lower latency
        device=device_index, channels=1, callback=audio_callback, dtype="int16"
    )

    print("Listening for wake word...")

    with stream:
        threading.Thread(target=process_audio, daemon=True).start()
        while not wake_word_detected.is_set():
            time.sleep(0.01)  # Prevent high CPU usage




    audioPlay_wake=(current_dir + "\\wake_responses\\" + str(random.randint(1, 4))+".wav")
    wave_obj_wake = sa.WaveObject.from_wave_file(audioPlay_wake)
    play_obj_wake = wave_obj_wake.play()
    play_obj_wake.wait_done()


    return True  # Wake word detected






def listen_and_transcribe(device_index=None, extension_timeout=3):
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


#    print("transcribed_text:" + transcribed_text)
#   (transcribed_text=="the")
    if (not transcribed_text) or (transcribed_text=="the"):
        print("No transcription available or timeout.")
        #return None
        print("NO WORDS FOUND")
        return(listen_and_transcribe(device_index=1))
        #TRY TO CALL ITSELF
    
    print("Final transcription result: "+ (str(wakeWordString)[10:])[:-2] + ". " + (transcribed_text.strip()))
    print()



    
    #return ((str(wakeWordString)[10:])[:-2] + ". " + transcribed_text.strip())
    return (transcribed_text.strip())






def main():
    mic_device_index = 1  # Replace with your desired mic index
    while True:
        if listen_for_wake_word2(device_index=mic_device_index):
            text_to_speech(generate_response(listen_and_transcribe(device_index=mic_device_index)).replace("*", ""), output_file="vits_output.wav", use_gpu=True, speaker_id="p230", speed=1.2)
            wave_obj = sa.WaveObject.from_wave_file("vits_output.wav")
            play_obj = wave_obj.play()
            play_obj.wait_done()

if __name__ == "__main__":
    main()