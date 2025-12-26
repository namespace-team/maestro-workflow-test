#!/bin/bash

# 1. Setup
adb wait-for-device
adb install 47.apk

# 2. Start recording with a FIXED time limit
# We set it to 180s (3 mins). This allows the OS to finalize the file naturally.
echo "Starting 3-minute background recording..."
adb shell screenrecord --bit-rate 2000000 --time-limit 180 /sdcard/recording.mp4 &
RECORD_PID=$!

# 3. Robust Cleanup Function
cleanup() {
  echo "Tests finished. Finalizing video..."
  
  # Send SIGINT (Ctrl+C equivalent) to stop recording
  kill -2 $RECORD_PID || true
  
  # CRITICAL: We wait for the process to actually disappear from the process list
  # This is much safer than a blind sleep.
  echo "Waiting for screenrecord process to exit..."
  timeout 15s bash -c "while adb shell pgrep screenrecord > /dev/null; do sleep 1; done"
  
  # Final safety pause for disk sync
  sleep 5
  
  echo "Pulling video..."
  adb pull /sdcard/recording.mp4 recording.mp4 || echo "Pull failed"
  
  if [ -f recording.mp4 ] && [ -s recording.mp4 ]; then
     echo "Success! Video pulled. Size:"
     ls -lh recording.mp4
  else
     echo "ERROR: Video is empty or missing."
  fi
}

trap cleanup EXIT

# 4. Run Maestro
echo "Starting Maestro tests..."
maestro test sourcefiles/flows/suites/regression.yaml