# Ollama Setup Script for Mac M1

## Overview

This Bash script provides a comprehensive solution for setting up and managing Ollama on Mac M1 (ARM64) machines. It offers an interactive interface to install Ollama, manage models, run tests, and even get started with Python integration.

## Features

- **System Compatibility Check**: Ensures the script is run on a Mac M1 (ARM64) machine.
- **Dependency Management**: Checks and installs necessary dependencies (Xcode CLI, Homebrew, Python).
- **Ollama Installation and Update**: Installs Ollama if not present, and offers to update if already installed.
- **Model Management**:
  - List available models
  - Pull new models
  - List installed models
  - Remove models
  - Benchmark models
- **System Information Display**: Shows relevant system information, including OS version, CPU, memory, and installed software versions.
- **Ollama Test**: Runs a simple test query on an installed model.
- **Python Script Generation**: Creates a basic Python script to interact with Ollama.

## Prerequisites

- Mac M1 (ARM64) machine
- Internet connection
- Admin privileges (for installation of some components)

## Installation

1. Download the script:
   ```
   curl -O https://raw.githubusercontent.com/yourusername/ollama-setup/main/advanced_setup_ollama.sh
   ```
   (Replace with the actual URL where you host the script)

2. Make the script executable:
   ```
   chmod +x advanced_setup_ollama.sh
   ```

## Usage

Run the script with:

```
./advanced_setup_ollama.sh
```

Follow the on-screen prompts to navigate through different options:

1. Install/Update Ollama
2. Manage Models
3. Display System Information
4. Run Ollama Test
5. Create Python Script
6. Exit

## Model Management

The script provides a submenu for model management:

1. List available models
2. Pull a model
3. List installed models
4. Remove a model
5. Benchmark models
6. Return to main menu

## Python Integration

The script can generate a simple Python script (`ollama_test.py`) that demonstrates how to interact with Ollama using Python. You can run this script with:

```
python3 ollama_test.py
```

## Troubleshooting

- If you encounter any permission issues, ensure you have the necessary admin rights.
- For any installation failures, check your internet connection and try running the script again.
- If a specific model fails to pull, verify the model name and your system resources.

## Contributing

Contributions to improve the script are welcome! Please fork the repository, make your changes, and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Ollama team for their excellent language model platform
- All contributors and users of this script

## Disclaimer

This script is provided as-is, without any warranties. Always review scripts before running them on your system.
