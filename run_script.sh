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
  
  # Send SIGINT (like pressing Ctrl+C) to stop recording gracefully
  kill -2 $RECORD_PID || true
  
  # CRITICAL: Wait for the emulator to finish writing the MP4 header
  # On GitHub Actions, 10 seconds is the "sweet spot" for slow CPUs
  sleep 10
  
  echo "Pulling video from emulator..."
  adb pull /sdcard/recording.mp4 . || echo "Failed to pull video"
  
  # Verify file size in logs (If it's > 0, it worked!)
  ls -lh recording.mp4 || echo "Video file is missing from runner disk"
}

# 3. Ensure cleanup runs even if Maestro fails
trap cleanup EXIT

# 4. Wait for the app to be fully ready before starting tests
echo "Waiting for app to settle..."
sleep 5

# 5. Run Maestro
maestro test sourcefiles/flows/suites/regression.yaml