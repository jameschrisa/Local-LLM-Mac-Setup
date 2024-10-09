#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check for Xcode Command Line Tools
check_xcode_cli() {
    if ! command_exists xcode-select; then
        print_color $YELLOW "Xcode Command Line Tools not found. Installing..."
        xcode-select --install
        print_color $GREEN "Please complete the Xcode Command Line Tools installation and run this script again."
        exit 0
    fi
}

# Check for Homebrew
check_homebrew() {
    if ! command_exists brew; then
        print_color $YELLOW "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Check for Python
check_python() {
    if ! command_exists python3; then
        print_color $YELLOW "Python 3 not found. Installing..."
        brew install python
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
    else
        print_color $GREEN "Ollama is already installed."
    fi
}

# Function to list available models
list_models() {
    print_color $YELLOW "Fetching available models..."
    models=$(curl -s https://ollama.com/library | grep -oP '(?<=href="/library/)[^"]+' | sort -u)
    print_color $GREEN "Available models:"
    echo "$models"
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

# Main script
print_color $GREEN "Welcome to the Ollama Setup Script for Mac M1!"

check_xcode_cli
check_homebrew
check_python
install_ollama

print_color $GREEN "Ollama has been successfully installed!"

# Prompt user to list models
prompt_user "Would you like to see a list of available models? (y/n): " list_models_choice
if [[ $list_models_choice == "y" || $list_models_choice == "Y" ]]; then
    list_models
fi

# Prompt user to pull a model
prompt_user "Would you like to pull a model now? (y/n): " pull_model_choice
if [[ $pull_model_choice == "y" || $pull_model_choice == "Y" ]]; then
    prompt_user "Enter the name of the model you'd like to pull: " model_name
    pull_model $model_name
fi

# Final instructions
print_color $GREEN "Ollama setup is complete!"
print_color $YELLOW "Here are some things you can do next:"
echo "1. Run 'ollama run model_name' to start an interactive session with a model."
echo "2. Use the Python API to interact with Ollama in your scripts."
echo "3. Explore more models by visiting https://ollama.com/library"
echo "4. Check out the Ollama documentation for advanced usage: https://github.com/ollama/ollama"

print_color $GREEN "Happy experimenting with Ollama!"
