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

# Check if emulator is running
if ! adb devices | grep -q "emulator"; then
    print_message "No emulator is currently running" "$YELLOW"
    
    # Clean up PID file if it exists
    if [ -f .emulator.pid ]; then
        rm .emulator.pid
        print_message "Removed stale PID file" "$YELLOW"
    fi
    
    exit 0
fi

# Try to get the PID from the file
if [ -f .emulator.pid ]; then
    EMULATOR_PID=$(cat .emulator.pid)
    print_message "Found emulator PID: $EMULATOR_PID" "$GREEN"
    
    # Check if the process exists
    if ps -p $EMULATOR_PID > /dev/null; then
        print_message "Stopping emulator with PID: $EMULATOR_PID" "$YELLOW"
        kill $EMULATOR_PID
        
        # Wait for the process to terminate
        MAX_WAIT=30  # Maximum wait time in seconds
        WAITED=0
        
        while ps -p $EMULATOR_PID > /dev/null; do
            sleep 1
            WAITED=$((WAITED + 1))
            if [ $WAITED -ge $MAX_WAIT ]; then
                print_message "Timeout waiting for emulator to stop. Forcing termination." "$RED"
                kill -9 $EMULATOR_PID
                break
            fi
            print_message "Waiting for emulator to stop... ($WAITED seconds)" "$YELLOW"
        done
        
        print_message "Emulator stopped successfully" "$GREEN"
    else
        print_message "No process found with PID: $EMULATOR_PID" "$YELLOW"
        print_message "Trying alternative method to stop the emulator" "$YELLOW"
    fi
    
    # Remove the PID file
    rm .emulator.pid
else
    print_message "No PID file found. Trying alternative method to stop the emulator" "$YELLOW"
fi

# Alternative method: Use adb to stop the emulator
print_message "Stopping emulator using adb..." "$YELLOW"
adb -s emulator-5554 emu kill

# Wait for the emulator to stop
MAX_WAIT=30  # Maximum wait time in seconds
WAITED=0

while adb devices | grep -q "emulator"; do
    sleep 1
    WAITED=$((WAITED + 1))
    if [ $WAITED -ge $MAX_WAIT ]; then
        print_message "Timeout waiting for emulator to stop via adb. Please check manually." "$RED"
        exit 1
    fi
    print_message "Waiting for emulator to stop... ($WAITED seconds)" "$YELLOW"
done

print_message "Emulator stopped successfully" "$GREEN" 