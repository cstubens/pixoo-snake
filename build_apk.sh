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

# Create build directory if it doesn't exist
BUILD_DIR="build"
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
fi

# Clean previous build
print_message "Cleaning previous build..." "$YELLOW"
./gradlew clean

# Build the APK
print_message "Building APK..." "$YELLOW"
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    # Copy the APK to the build directory
    APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
    if [ -f "$APK_PATH" ]; then
        cp "$APK_PATH" "$BUILD_DIR/pixoo-tetris.apk"
        print_message "APK built successfully!" "$GREEN"
        print_message "APK location: $BUILD_DIR/pixoo-tetris.apk" "$GREEN"
        print_message "You can install this APK on your device by:" "$GREEN"
        print_message "1. Transfer the APK to your device" "$GREEN"
        print_message "2. Open the APK file on your device" "$GREEN"
        print_message "3. Allow installation from unknown sources if prompted" "$GREEN"
    else
        print_message "Error: APK file not found at $APK_PATH" "$RED"
        exit 1
    fi
else
    print_message "Error: Failed to build APK" "$RED"
    exit 1
fi 