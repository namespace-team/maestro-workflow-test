#!/bin/bash
# Wait for Emulator to be fully ready
adb wait-for-device
adb install 47.apk
adb shell getprop sys.boot_completed

# Debug: List all installed packages and grep for anything clock-related
echo "=== Installed packages containing 'clock' or 'deskclock' ==="
adb shell pm list packages

# Launch the app after emulator is ready
#!/bin/bash

# 1. Start recording with a lower bitrate (easier for CI to process)
# We save the recording to the emulator's /sdcard/
adb shell screenrecord --bit-rate 2000000 --time-limit 180 /sdcard/recording.mp4 &
RECORD_PID=$!
echo "Recording started with PID: $RECORD_PID"

# 2. The Cleanup Function
cleanup() {
  echo "Test finished. Finalizing video..."
  kill -2 $RECORD_PID || true
  sleep 10
  
  echo "Pulling video..."
  adb pull /sdcard/recording.mp4 raw_recording.mp4 || echo "Pull failed"
  
  # NEW: Fix the MP4 structure for web streaming (Slack)
  # This moves the metadata to the start of the file
  if [ -f raw_recording.mp4 ]; then
    echo "Optimizing video for Slack..."
    ffmpeg -i raw_recording.mp4 -c copy -movflags +faststart recording.mp4
    ls -lh recording.mp4
  fi
}

# 3. Ensure cleanup runs even if Maestro fails
trap cleanup EXIT

# 4. Wait for the app to be fully ready before starting tests
echo "Waiting for app to settle..."
sleep 5

# 5. Run Maestro
maestro test sourcefiles/flows/suites/regression.yaml