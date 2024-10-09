#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user for input
prompt_user() {
    local prompt=$1
    local variable=$2
    read -p "$prompt" $variable
}

# Function to check system requirements
check_system_requirements() {
    print_color $BLUE "Checking system requirements..."
    if [[ $(uname -m) != "arm64" ]]; then
        print_color $RED "This script is designed for Mac M1 (ARM64) machines. Your system may not be compatible."
        exit 1
    fi
}

# Check for Xcode Command Line Tools
check_xcode_cli() {
    if ! xcode-select -p &>/dev/null; then
        print_color $YELLOW "Xcode Command Line Tools not found. Installing..."
        xcode-select --install
        print_color $GREEN "Please complete the Xcode Command Line Tools installation and run this script again."
        exit 0
    else
        print_color $GREEN "Xcode Command Line Tools are installed."
    fi
}

# Check for Homebrew
check_homebrew() {
    if ! command_exists brew; then
        print_color $YELLOW "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_color $GREEN "Homebrew installed successfully."
    else
        print_color $GREEN "Homebrew is already installed."
    fi
}

# Check for Python
check_python() {
    if ! command_exists python3; then
        print_color $YELLOW "Python 3 not found. Installing..."
        brew install python
        print_color $GREEN "Python 3 installed successfully."
    else
        print_color $GREEN "Python 3 is already installed."
    fi
}

# Install Ollama
install_ollama() {
    if ! command_exists ollama; then
        print_color $YELLOW "Installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        if [ $? -ne 0 ]; then
            print_color $RED "Failed to install Ollama. Please check your internet connection and try again."
            exit 1
        fi
        print_color $GREEN "Ollama installed successfully."
    else
        current_version=$(ollama --version | awk '{print $2}')
        print_color $GREEN "Ollama is already installed (version $current_version)."
        prompt_user "Would you like to check for updates? (y/n): " update_choice
        if [[ $update_choice == "y" || $update_choice == "Y" ]]; then
            print_color $YELLOW "Checking for updates..."
            ollama pull ollama/ollama
        fi
    fi
}

# Function to list available models
list_models() {
    print_color $YELLOW "Fetching available models..."
    models=$(curl -s https://ollama.com/library | grep -oP '(?<=href="/library/)[^"]+' | sort -u)
    print_color $GREEN "Available models:"
    echo "$models" | column
}

# Function to pull a model
pull_model() {
    local model=$1
    print_color $YELLOW "Pulling model: $model"
    ollama pull $model
    if [ $? -ne 0 ]; then
        print_color $RED "Failed to pull model $model. Please check the model name and try again."
    else
        print_color $GREEN "Successfully pulled model: $model"
    fi
}

# Function to manage models
manage_models() {
    while true; do
        print_color $BLUE "\nModel Management:"
        echo "1. List available models"
        echo "2. Pull a model"
        echo "3. List installed models"
        echo "4. Remove a model"
        echo "5. Return to main menu"
        prompt_user "Enter your choice: " model_choice

        case $model_choice in
            1) list_models ;;
            2) prompt_user "Enter the name of the model you'd like to pull: " model_name
               pull_model $model_name ;;
            3) print_color $GREEN "Installed models:"
               ollama list ;;
            4) prompt_user "Enter the name of the model you'd like to remove: " model_name
               ollama rm $model_name ;;
            5) break ;;
            *) print_color $RED "Invalid choice. Please try again." ;;
        esac
    done
}

# Function to display system information
display_system_info() {
    print_color $BLUE "\nSystem Information:"
    echo "OS: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "Chip: $(sysctl -n machdep.cpu.brand_string)"
    echo "Memory: $(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 )) GB"
    echo "Disk Space: $(df -h / | awk 'NR==2 {print $4}') available"
    echo "Python version: $(python3 --version)"
    if command_exists ollama; then
        echo "Ollama version: $(ollama --version)"
    else
        echo "Ollama: Not installed"
    fi
}

# Main menu
main_menu() {
    while true; do
        print_color $BLUE "\nOllama Setup and Management"
        echo "1. Install/Update Ollama"
        echo "2. Manage Models"
        echo "3. Display System Information"
        echo "4. Exit"
        prompt_user "Enter your choice: " main_choice

        case $main_choice in
            1) install_ollama ;;
            2) manage_models ;;
            3) display_system_info ;;
            4) print_color $GREEN "Thank you for using the Ollama Setup Script. Goodbye!"
               exit 0 ;;
            *) print_color $RED "Invalid choice. Please try again." ;;
        esac
    done
}

# Main script
print_color $GREEN "Welcome to the Improved Ollama Setup Script for Mac M1!"

check_system_requirements
check_xcode_cli
check_homebrew
check_python

main_menu

print_color $GREEN "Ollama setup is complete!"
print_color $YELLOW "Here are some things you can do next:"
echo "1. Run 'ollama run model_name' to start an interactive session with a model."
echo "2. Use the Python API to interact with Ollama in your scripts."
echo "3. Explore more models by visiting https://ollama.com/library"
echo "4. Check out the Ollama documentation for advanced usage: https://github.com/ollama/ollama"

print_color $GREEN "Happy experimenting with Ollama!"
