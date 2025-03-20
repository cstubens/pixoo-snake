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

# Set Java home to Temurin 17
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"
print_message "Setting JAVA_HOME: $JAVA_HOME" "$YELLOW"

print_message "Cleaning project..." "$YELLOW"

# Remove build directories
print_message "Removing build directories..." "$YELLOW"
rm -rf build/
rm -rf app/build/
rm -rf .gradle/

# Remove log files
print_message "Removing log files..." "$YELLOW"
rm -f emulator.log
rm -f *.log

# Clean gradle
print_message "Cleaning Gradle..." "$YELLOW"
if [ -f "./gradlew" ]; then
    ./gradlew clean
fi

# Remove Android Studio temporary files
print_message "Removing IDE temporary files..." "$YELLOW"
rm -rf .idea/
rm -rf *.iml
rm -rf app/*.iml

print_message "Clean complete!" "$GREEN" 