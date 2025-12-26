#!/bin/bash
# Wait for Emulator to be fully ready
adb wait-for-device
adb install 47.apk
adb shell getprop sys.boot_completed

# Debug: List all installed packages and grep for anything clock-related
echo "=== Installed packages containing 'clock' or 'deskclock' ==="
adb shell pm list packages

# Launch the app after emulator is ready
adb shell screenrecord --time-limit 180 /sdcard/recording.mp4 &
RECORD_PID=$!
echo "Recording started with PID: $RECORD_PID"

# Define the cleanup function properly
cleanup() {
  echo "Stopping recording..."
  # Use the PID we captured earlier
  kill -INT $RECORD_PID || true
  sleep 2
  echo "Pulling video..."
  adb pull /sdcard/recording.mp4 . || echo "Video not found"
}

# Set the trap to run the function on exit
trap cleanup EXIT

# Run your tests
maestro test sourcefiles/flows/suites/regression.yaml