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

# Check if emulator is running
if adb devices | grep -q "emulator"; then
    print_message "Emulator is running. Stopping it first..." "$YELLOW"
    
    # Get the emulator device ID
    EMULATOR_ID=$(adb devices | grep emulator | head -n 1 | awk '{print $1}')
    
    # Stop the emulator
    print_message "Stopping emulator: $EMULATOR_ID" "$YELLOW"
    adb -s $EMULATOR_ID emu kill
    
    # Wait for the emulator to stop
    MAX_WAIT=30  # Maximum wait time in seconds
    WAITED=0
    
    while adb devices | grep -q "emulator"; do
        sleep 2
        WAITED=$((WAITED + 2))
        if [ $WAITED -ge $MAX_WAIT ]; then
            print_message "Timeout waiting for emulator to stop. Please try manually stopping it with ./stop_emulator.sh" "$RED"
            exit 1
        fi
        print_message "Waiting for emulator to stop... ($WAITED seconds)" "$YELLOW"
    done
    
    print_message "Emulator stopped successfully" "$GREEN"
else
    print_message "No emulator is currently running" "$YELLOW"
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

# Start the emulator with the -wipe-data flag to reset it
print_message "Starting emulator with clean data..." "$YELLOW"
nohup $ANDROID_HOME/emulator/emulator -avd "$AVD_NAME" -wipe-data > emulator.log 2>&1 &
EMULATOR_PID=$!

# Save the PID to a file for later use
echo $EMULATOR_PID > .emulator.pid
print_message "Emulator started with PID: $EMULATOR_PID" "$GREEN"
print_message "Logs are being saved to emulator.log" "$GREEN"

# Wait for emulator to start
print_message "Waiting for emulator to start..." "$YELLOW"
MAX_WAIT=120  # Maximum wait time in seconds
WAITED=0

while ! adb devices | grep -q "emulator"; do
    sleep 2
    WAITED=$((WAITED + 2))
    if [ $WAITED -ge $MAX_WAIT ]; then
        print_message "Timeout waiting for emulator to start. Check emulator.log for details." "$RED"
        print_message "The emulator may still be starting in the background." "$YELLOW"
        exit 1
    fi
    print_message "Waiting for emulator to start... ($WAITED seconds)" "$YELLOW"
done

# Wait for boot to complete
print_message "Emulator started. Waiting for boot to complete..." "$YELLOW"
WAITED=0

while ! adb shell getprop sys.boot_completed | grep -q "1"; do
    sleep 2
    WAITED=$((WAITED + 2))
    if [ $WAITED -ge $MAX_WAIT ]; then
        print_message "Timeout waiting for boot to complete. The emulator may not be fully functional." "$RED"
        exit 1
    fi
    print_message "Waiting for boot to complete... ($WAITED seconds)" "$YELLOW"
done

print_message "Emulator reset completed successfully!" "$GREEN" 