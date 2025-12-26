#!/bin/bash

# 1. Wait for Emulator and Setup
adb wait-for-device
adb install 47.apk

# 2. Start recording
# Ensure any old recording is deleted first
adb shell rm /sdcard/recording.mp4 || true
adb shell screenrecord --bit-rate 2000000 --time-limit 180 /sdcard/recording.mp4 &
RECORD_PID=$!
echo "Recording started with PID: $RECORD_PID"

# 3. Cleanup Function
cleanup() {
  echo "Test finished. Finalizing video..."
  kill -2 $RECORD_PID || true
  sleep 10 # Essential for MP4 header finalization
  
  echo "Pulling video..."
  adb pull /sdcard/recording.mp4 recording.mp4 || echo "Pull failed"
  
  if [ -f recording.mp4 ]; then
     echo "Video pulled successfully. Size:"
     ls -lh recording.mp4
  else
     echo "ERROR: recording.mp4 was not created."
  fi
}

trap cleanup EXIT

# 4. Run Maestro
echo "Starting Maestro tests..."
maestro test sourcefiles/flows/suites/regression.yaml