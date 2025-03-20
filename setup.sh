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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Homebrew if not present
install_homebrew() {
    if ! command_exists brew; then
        print_message "Installing Homebrew..." "$YELLOW"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print_message "Homebrew is already installed" "$GREEN"
    fi
}

# Function to install Java 17
install_java() {
    if ! command_exists java || ! java -version 2>&1 | grep -q "version \"17"; then
        print_message "Installing Java 17..." "$YELLOW"
        brew install --cask temurin@17
    else
        print_message "Java 17 is already installed" "$GREEN"
    fi
}

# Function to install Android Studio
install_android_studio() {
    if [ ! -d "/Applications/Android Studio.app" ]; then
        print_message "Installing Android Studio..." "$YELLOW"
        brew install --cask android-studio
    else
        print_message "Android Studio is already installed" "$GREEN"
    fi
}

# Function to install Android SDK
install_android_sdk() {
    if [ ! -d "$HOME/Library/Android/sdk" ]; then
        print_message "Android SDK not found. Please install it through Android Studio:" "$YELLOW"
        print_message "1. Open Android Studio" "$YELLOW"
        print_message "2. Go to Tools -> SDK Manager" "$YELLOW"
        print_message "3. Install Android SDK Platform 34" "$YELLOW"
        print_message "4. Install Android SDK Build-Tools" "$YELLOW"
        print_message "5. Install Android SDK Platform-Tools" "$YELLOW"
        print_message "6. Install Android Emulator" "$YELLOW"
        print_message "7. Install Android SDK Tools" "$YELLOW"
    else
        print_message "Android SDK is already installed" "$GREEN"
    fi
}

# Function to create Android Virtual Device
create_avd() {
    if ! $HOME/Library/Android/sdk/emulator/emulator -list-avds | grep -q "Medium_Phone_API_35"; then
        print_message "Creating Android Virtual Device..." "$YELLOW"
        print_message "Please create an AVD through Android Studio:" "$YELLOW"
        print_message "1. Open Android Studio" "$YELLOW"
        print_message "2. Go to Tools -> Device Manager" "$YELLOW"
        print_message "3. Click 'Create Device'" "$YELLOW"
        print_message "4. Select 'Phone' -> 'Medium Phone'" "$YELLOW"
        print_message "5. Select 'API 35' (Android 14.0)" "$YELLOW"
        print_message "6. Name it 'Medium_Phone_API_35'" "$YELLOW"
        print_message "7. Click 'Finish'" "$YELLOW"
    else
        print_message "Android Virtual Device is already created" "$GREEN"
    fi
}

# Main setup process
print_message "Starting setup process..." "$YELLOW"

# Install Homebrew
install_homebrew

# Install Java 17
install_java

# Install Android Studio
install_android_studio

# Install Android SDK
install_android_sdk

# Create Android Virtual Device
create_avd

# Set up environment variables
print_message "Setting up environment variables..." "$YELLOW"
if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
fi

# Add Android SDK environment variables if not present
if ! grep -q "ANDROID_HOME" "$HOME/.zshrc"; then
    echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> "$HOME/.zshrc"
    echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> "$HOME/.zshrc"
    echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> "$HOME/.zshrc"
    echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> "$HOME/.zshrc"
    echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> "$HOME/.zshrc"
fi

# Add Java environment variable if not present
if ! grep -q "JAVA_HOME" "$HOME/.zshrc"; then
    echo 'export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home' >> "$HOME/.zshrc"
fi

print_message "Setup complete! Please:" "$GREEN"
print_message "1. Restart your terminal to apply environment variables" "$GREEN"
print_message "2. Open Android Studio and complete the initial setup" "$GREEN"
print_message "3. Run './run.sh' to build and run the app" "$GREEN" 