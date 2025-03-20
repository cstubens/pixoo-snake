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

# Function to check if adb is available
check_adb() {
    if ! command -v adb &> /dev/null; then
        print_message "Error: adb command not found. Please ensure Android SDK platform-tools are installed." "$RED"
        print_message "You can install them through Android Studio: Tools -> SDK Manager -> SDK Tools -> Android SDK Platform-Tools" "$YELLOW"
        exit 1
    fi
}

# Function to check if emulator is running
check_emulator() {
    if ! adb devices | grep -q "emulator"; then
        print_message "Error: No emulator is running. Please start an emulator first." "$RED"
        print_message "You can start one using: ./run.sh" "$YELLOW"
        exit 1
    fi
}

# Function to clear logs
clear_logs() {
    print_message "Clearing log buffer..." "$YELLOW"
    adb logcat -c
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a, --all        Show all logs (default)"
    echo "  -p, --pixoo      Show only Pixoo-related logs"
    echo "  -g, --game       Show only game-related logs"
    echo "  -c, --clear      Clear log buffer before showing logs"
    echo "  -h, --help       Show this help message"
}

# Parse command line arguments
FILTER=""
CLEAR=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            FILTER=""
            shift
            ;;
        -p|--pixoo)
            FILTER="PixooClient"
            shift
            ;;
        -g|--game)
            FILTER="GameControls"
            shift
            ;;
        -c|--clear)
            CLEAR=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_message "Unknown option: $1" "$RED"
            show_usage
            exit 1
            ;;
    esac
done

# Check prerequisites
check_adb
check_emulator

# Clear logs if requested
if [ "$CLEAR" = true ]; then
    clear_logs
fi

# Show appropriate message based on filter
if [ -z "$FILTER" ]; then
    print_message "Showing all logs..." "$GREEN"
    print_message "Press Ctrl+C to stop" "$YELLOW"
    adb logcat
else
    print_message "Showing logs filtered by: $FILTER" "$GREEN"
    print_message "Press Ctrl+C to stop" "$YELLOW"
    adb logcat | grep -E "$FILTER"
fi 