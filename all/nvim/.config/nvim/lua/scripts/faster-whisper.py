#!/usr/bin/env python3
import os
import signal
import subprocess
import argparse
from datetime import datetime
from audio_processor import process_audio

debug_log_file = os.path.join(os.path.expanduser("~"), ".chat_debug.log")

def log(msg):
    with open(debug_log_file, "a") as f:
        f.write(f"{datetime.now().isoformat()} - {msg}\n")


def handle_term(signum, frame):
    raise KeyboardInterrupt

# Parse command line arguments
parser = argparse.ArgumentParser(description="Record audio and process it by default")
parser.add_argument(
    "--ignore-process-audio", 
    action="store_true", 
    help="Skip audio processing (transcription, logging, and cleanup)"
)
args = parser.parse_args()

signal.signal(signal.SIGTERM, handle_term)

output_file = "output.mp3"
log_file = os.path.join(os.path.expanduser("~"), ".chat_logs")

if os.path.exists(output_file):
    os.remove(output_file)

proc = subprocess.Popen([
    "ffmpeg", "-f", "avfoundation", "-i", ":1",
    "-codec:a", "libmp3lame", "-qscale:a", "2",
    output_file
])

try:
    proc.wait()  # wait until ffmpeg finishes
except KeyboardInterrupt:
    print("\nStopping recording...")
    proc.send_signal(signal.SIGINT)  # tell ffmpeg to finalize
    proc.wait()
    if not args.ignore_process_audio:
        process_audio(output_file, log_file, log)
    else:
        log("Skipping audio processing (--ignore-process-audio specified)")


# if not args.ignore_process_audio:
#     process_audio(output_file, log_file, log)
# else:
#     log("Skipping audio processing (--ignore-process-audio specified)")
