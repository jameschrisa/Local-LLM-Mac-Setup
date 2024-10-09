#!/bin/bash

set -euo pipefail  # Exit on error, undefined var, and pipe failures

# Script version
VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a setup_ollama.log
}

# Error handling function
handle_error() {
    log "${RED}Error on line $1${NC}"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    log "$message"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user for input with timeout
prompt_user() {
    local prompt=$1
    local variable=$2
    local timeout=${3:-60}  # Default timeout of 60 seconds
    read -t "$timeout" -p "$prompt" $variable || { print_color $RED "No input received within $timeout seconds. Exiting."; exit 1; }
}

# Function to check system requirements
check_system_requirements() {
    log "Checking system requirements..."
    if [[ $(uname -m) != "arm64" ]]; then
        print_color $RED "This script is designed for Mac M1 (ARM64) machines. Your system is not compatible."
        exit 1
    fi
    
    # Check for minimum macOS version (e.g., Big Sur 11.0)
    if [[ $(sw_vers -productVersion | cut -d. -f1) -lt 11 ]]; then
        print_color $RED "This script requires macOS Big Sur (11.0) or later. Please update your OS."
        exit 1
    }
    
    # Check for minimum free disk space (e.g., 10GB)
    local free_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/Gi//')
    if (( $(echo "$free_space < 10" | bc -l) )); then
        print_color $RED "Insufficient disk space. At least 10GB free space is required."
        exit 1
    fi
}

# ... [rest of the existing functions] ...

# Function to create a backup
create_backup() {
    log "Creating backup of Ollama configuration..."
    if [[ -d ~/.ollama ]]; then
        local backup_dir="ollama_backup_$(date +'%Y%m%d_%H%M%S')"
        cp -R ~/.ollama "$backup_dir"
        print_color $GREEN "Backup created: $backup_dir"
    else
        print_color $YELLOW "No existing Ollama configuration to backup."
    fi
}

# Function to restore from backup
restore_backup() {
    log "Restoring from backup..."
    local backups=(ollama_backup_*)
    if [[ ${#backups[@]} -eq 0 ]]; then
        print_color $RED "No backups found."
        return
    fi
    
    print_color $BLUE "Available backups:"
    for i in "${!backups[@]}"; do
        echo "$((i+1)). ${backups[$i]}"
    done
    
    prompt_user "Select a backup to restore (or 'c' to cancel): " choice
    if [[ $choice == 'c' ]]; then
        return
    fi
    
    if [[ $choice =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#backups[@]} )); then
        local selected_backup=${backups[$((choice-1))]}
        rm -rf ~/.ollama
        cp -R "$selected_backup" ~/.ollama
        print_color $GREEN "Restored from backup: $selected_backup"
    else
        print_color $RED "Invalid selection."
    fi
}

# Function to check for script updates
check_for_updates() {
    log "Checking for script updates..."
    # This is a placeholder. In a real-world scenario, you'd check against a remote version
    local latest_version="1.0.0"
    if [[ $VERSION != $latest_version ]]; then
        print_color $YELLOW "A new version of the script is available. Please update."
    else
        print_color $GREEN "Script is up to date."
    fi
}

# Main menu
main_menu() {
    while true; do
        print_color $BLUE "\nOllama Setup and Management (v$VERSION)"
        echo "1. Install/Update Ollama"
        echo "2. Manage Models"
        echo "3. Display System Information"
        echo "4. Run Ollama Test"
        echo "5. Create Python Script"
        echo "6. Create Backup"
        echo "7. Restore from Backup"
        echo "8. Check for Script Updates"
        echo "9. Exit"
        prompt_user "Enter your choice: " main_choice 30  # 30-second timeout

        case $main_choice in
            1) install_ollama ;;
            2) manage_models ;;
            3) display_system_information ;;
            4) run_ollama_test ;;
            5) create_python_script ;;
            6) create_backup ;;
            7) restore_backup ;;
            8) check_for_updates ;;
            9) print_color $GREEN "Thank you for using the Ollama Setup Script. Goodbye!"
               exit 0 ;;
            *) print_color $RED "Invalid choice. Please try again." ;;
        esac
    done
}

# Main script
log "Starting Ollama Setup Script v$VERSION"
print_color $GREEN "Welcome to the Reliability-Enhanced Ollama Setup Script for Mac M1!"

check_system_requirements
check_xcode_cli
check_homebrew
check_python
install_ollama

main_menu

log "Ollama setup completed successfully."
print_color $GREEN "Ollama setup is complete!"
print_color $YELLOW "Here are some things you can do next:"
echo "1. Run 'ollama run model_name' to start an interactive session with a model."
echo "2. Use the Python API to interact with Ollama in your scripts."
echo "3. Explore more models by visiting https://ollama.com/library"
echo "4. Check out the Ollama documentation for advanced usage: https://github.com/ollama/ollama"

print_color $GREEN "Happy experimenting with Ollama!"
