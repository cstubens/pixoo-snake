#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Set default environment variables if not set
if [ -z "$ANDROID_HOME" ]; then
    export ANDROID_HOME=$HOME/Library/Android/sdk
    print_message "Setting default ANDROID_HOME: $ANDROID_HOME" "$YELLOW"
fi

# Set Java home to Temurin 17
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"
print_message "Setting JAVA_HOME: $JAVA_HOME" "$YELLOW"

# Verify environment variables are accessible
if [ ! -d "$ANDROID_HOME" ]; then
    print_message "Error: ANDROID_HOME directory not found at: $ANDROID_HOME" "$RED"
    print_message "Please set the correct path to your Android SDK" "$YELLOW"
    exit 1
fi

if [ ! -d "$JAVA_HOME" ]; then
    print_message "Error: JAVA_HOME directory not found at: $JAVA_HOME" "$RED"
    print_message "Please install Java 17 using: brew install --cask temurin@17" "$YELLOW"
    exit 1
fi

# Check if emulator is already running
if adb devices | grep -q "emulator"; then
    print_message "Emulator is already running" "$GREEN"
    exit 0
fi

# List available AVDs
print_message "Checking available Android Virtual Devices..." "$YELLOW"
AVDS=$($ANDROID_HOME/emulator/emulator -list-avds)

if [ -z "$AVDS" ]; then
    print_message "Error: No Android Virtual Devices found" "$RED"
    print_message "Please create an AVD using Android Studio or the AVD Manager" "$YELLOW"
    exit 1
fi

# Get the first AVD (you can modify this to select a specific one)
AVD_NAME=$(echo "$AVDS" | head -n 1)
print_message "Using AVD: $AVD_NAME" "$GREEN"

# Start the emulator in the background
print_message "Starting emulator in the background..." "$YELLOW"
nohup $ANDROID_HOME/emulator/emulator -avd "$AVD_NAME" > emulator.log 2>&1 &
EMULATOR_PID=$!

# Save the PID to a file for later use
echo $EMULATOR_PID > .emulator.pid
print_message "Emulator started with PID: $EMULATOR_PID" "$GREEN"
print_message "Logs are being saved to emulator.log" "$GREEN"

# Wait for emulator to start
print_message "Waiting for emulator to start..." "$YELLOW"
MAX_WAIT=60  # Maximum wait time in seconds
WAITED=0

while ! adb devices | grep -q "emulator"; do
    sleep 2
    WAITED=$((WAITED + 2))
    if [ $WAITED -ge $MAX_WAIT ]; then
        print_message "Timeout waiting for emulator to start. Check emulator.log for details." "$RED"
        print_message "The emulator is still running in the background." "$YELLOW"
        exit 1
    fi
    print_message "Waiting for emulator... ($WAITED seconds)" "$YELLOW"
done

print_message "Emulator is now running in the background!" "$GREEN"
print_message "To stop the emulator, use: ./stop_emulator.sh" "$GREEN" 