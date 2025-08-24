#!/usr/bin/env python3
import os
import subprocess
from datetime import datetime
from faster_whisper import WhisperModel

def process_audio(output_file, log_file, log_function):
    """
    Process audio file: transcribe, log, and cleanup.
    
    Args:
        output_file (str): Path to the audio file to process
        log_file (str): Path to the log file for storing transcriptions
        log_function (callable): Function to call for debug logging
    """
    # Only continue if file exists (means ffmpeg actually wrote something)
    if os.path.exists(output_file):
        log_function("MP3 Exists, starting transcription")
        
        try:
            model = WhisperModel(
                "base",
                device="cpu",
                compute_type="int8"
            )
            segments, info = model.transcribe(
                output_file,
                beam_size=3,
                without_timestamps=True,
                language="en"
            )
        except Exception as e:
            log_function(f"Error during transcription: {str(e)}")
            return

        text = ""
        for seg in segments:
            text += seg.text + "\n"
            print(f"[{seg.start:.2f} - {seg.end:.2f}] {seg.text}")
        log_function("Text: " + text.rstrip())

        # Append to logs with timestamp
        with open(log_file, "a") as f:
            f.write(f"\n--- {datetime.now().isoformat()} ---\n{text}\n")
        log_function("Finished writing to log")

        # Remove audio file
        os.remove(output_file)
        log_function("Removed audio file")

        # Copy to clipboard
        subprocess.run(["pbcopy"], input=text, text=True)
        log_function("Finished copying to clipboard")

    else:
        log_function("No recording found. Skipping transcription.")
