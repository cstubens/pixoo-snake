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

# Check if emulator is already running
if adb devices | grep -q "emulator"; then
    print_message "Emulator is already running" "$GREEN"
else
    print_message "Starting emulator..." "$YELLOW"
    $ANDROID_HOME/emulator/emulator -avd "$AVD_NAME" &
    EMULATOR_PID=$!
    
    # Wait for emulator to start
    print_message "Waiting for emulator to start..." "$YELLOW"
    while ! adb devices | grep -q "emulator"; do
        sleep 2
        print_message "Waiting for emulator..." "$YELLOW"
    done
    
    # Wait for boot to complete
    print_message "Waiting for emulator to complete boot..." "$YELLOW"
    while ! adb shell getprop sys.boot_completed | grep -q "1"; do
        sleep 2
        print_message "Waiting for boot to complete..." "$YELLOW"
    done
fi

# Build and install the app
print_message "Building and installing app..." "$YELLOW"
./gradlew installDebug

if [ $? -eq 0 ]; then
    print_message "App installed successfully!" "$GREEN"
    print_message "You can now find the app on your emulator" "$GREEN"
else
    print_message "Error: Failed to install app" "$RED"
    exit 1
fi 