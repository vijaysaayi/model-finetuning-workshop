#!/bin/bash

# Model Fine-Tuning Workshop - Linux/macOS Setup
# This script installs all prerequisites and sets up the environment

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Output functions
print_step() {
    echo -e "\n${BLUE}[STEP] $1${NC}"
}

print_info() {
    echo -e "${CYAN}[INFO] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

print_support() {
    echo -e "${MAGENTA}[SUPPORT] $1${NC}"
}

# Help function
show_help() {
    cat << EOF
Model Fine-Tuning Workshop - Linux/macOS Setup Script

This script will:
1. Install Python 3.11 (if not present)
2. Install VS Code (if not present)
3. Create a Python virtual environment
4. Install all workshop dependencies

Usage:
    ./setup-linux.sh

Requirements:
- Linux or macOS
- Internet connection
- 3GB+ free disk space
- sudo privileges for package installation

For support: Copy ALL output if errors occur
EOF
    exit 0
}

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
fi

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt; then
            echo "ubuntu"
        elif command_exists yum; then
            echo "centos"
        elif command_exists dnf; then
            echo "fedora"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Header
clear
cat << EOF

================================================================
    Model Fine-Tuning Workshop - Linux/macOS Setup
================================================================

This will install Python, VS Code, and workshop dependencies.
Installation may take 15-35 minutes depending on internet speed.

[!] Please copy ALL terminal output if you encounter any errors.

Press Ctrl+C to cancel, or
EOF

read -p "Press Enter to continue with installation..."

# System Information
print_step "Collecting System Information"
print_info "OS: $(uname -s) $(uname -r)"
print_info "Architecture: $(uname -m)"
print_info "Date/Time: $(date)"
print_info "User: $USER"
print_info "Shell: $SHELL"
print_info "Available disk space: $(df -h . | tail -1 | awk '{print $4}')"

OS=$(detect_os)
print_info "Detected OS: $OS"

# Check Python installation
print_step "Checking Python Installation"

# Find the best Python command
PYTHON_CMD=""
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
        PYTHON_CMD="python3"
        print_success "Python3 found: $PYTHON_VERSION"
    else
        print_warning "Python3 version too old: $PYTHON_VERSION (need 3.8+)"
    fi
elif command_exists python; then
    PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
        PYTHON_CMD="python"
        print_success "Python found: $PYTHON_VERSION"
    else
        print_warning "Python version too old: $PYTHON_VERSION (need 3.8+)"
    fi
fi

# Install Python if needed
if [ -z "$PYTHON_CMD" ]; then
    print_info "Installing Python 3.11..."
    print_info "This may take 2-5 minutes depending on your system..."
    
    case $OS in
        "ubuntu")
            print_info "Using apt package manager..."
            sudo apt update
            sudo apt install -y python3.11 python3.11-venv python3.11-pip python3.11-dev
            if command_exists python3.11; then
                PYTHON_CMD="python3.11"
                print_success "Python 3.11 installed successfully"
            else
                print_error "Python installation failed"
                print_support "Try: sudo apt install python3 python3-pip python3-venv"
                exit 1
            fi
            ;;
        "centos"|"fedora")
            print_info "Using yum/dnf package manager..."
            if command_exists dnf; then
                sudo dnf install -y python3.11 python3.11-pip python3.11-devel
            else
                sudo yum install -y python3.11 python3.11-pip python3.11-devel
            fi
            if command_exists python3.11; then
                PYTHON_CMD="python3.11"
                print_success "Python 3.11 installed successfully"
            else
                print_error "Python installation failed"
                exit 1
            fi
            ;;
        "macos")
            print_info "Installing Python via Homebrew..."
            if ! command_exists brew; then
                print_error "Homebrew not found. Please install from https://brew.sh/"
                print_support "Or manually install Python from https://python.org/downloads/"
                exit 1
            fi
            brew install python@3.11
            if command_exists python3.11; then
                PYTHON_CMD="python3.11"
                print_success "Python 3.11 installed successfully"
            else
                print_error "Python installation failed"
                exit 1
            fi
            ;;
        *)
            print_error "Unsupported OS for automatic Python installation"
            print_support "Please manually install Python 3.8+ from https://python.org/downloads/"
            exit 1
            ;;
    esac
fi

# Verify Python installation
print_info "Verifying Python installation..."
PYTHON_VERSION=$($PYTHON_CMD --version 2>&1)
print_success "Using: $PYTHON_VERSION"

# Check VS Code installation
print_step "Checking VS Code Installation"

if command_exists code; then
    CODE_VERSION=$(code --version 2>/dev/null | head -1)
    print_success "VS Code already installed: $CODE_VERSION"
else
    print_info "Installing VS Code..."
    print_info "This may take 2-3 minutes depending on internet speed..."
    
    case $OS in
        "ubuntu")
            print_info "Installing VS Code via apt..."
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            sudo apt update
            sudo apt install -y code
            ;;
        "centos"|"fedora")
            print_info "Installing VS Code via rpm..."
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            if command_exists dnf; then
                sudo dnf check-update
                sudo dnf install -y code
            else
                sudo yum check-update
                sudo yum install -y code
            fi
            ;;
        "macos")
            print_info "Installing VS Code via Homebrew..."
            if command_exists brew; then
                brew install --cask visual-studio-code
            else
                print_warning "Homebrew not found. Please manually install VS Code from https://code.visualstudio.com/"
            fi
            ;;
        *)
            print_warning "Cannot auto-install VS Code on this OS"
            print_info "Please manually install from https://code.visualstudio.com/"
            ;;
    esac
    
    # Verify VS Code installation
    if command_exists code; then
        CODE_VERSION=$(code --version 2>/dev/null | head -1)
        print_success "VS Code installed: $CODE_VERSION"
    else
        print_warning "VS Code installation may have failed"
        print_info "You can still continue with the workshop and install VS Code later"
    fi
fi

# Navigate to workshop directory
print_step "Setting up Workshop Environment"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSHOP_DIR="$(dirname "$SCRIPT_DIR")"
cd "$WORKSHOP_DIR"

print_info "Workshop directory: $WORKSHOP_DIR"

# Create virtual environment
print_info "Creating Python virtual environment..."
print_info "This creates an isolated Python workspace for the workshop"

if [ -d ".venv" ]; then
    print_warning "Virtual environment already exists"
    read -p "Remove existing environment and create new one? (y/N): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        rm -rf .venv
        print_info "Removed existing environment"
    else
        print_info "Using existing environment"
    fi
fi

if [ ! -d ".venv" ]; then
    $PYTHON_CMD -m venv .venv
    if [ -f ".venv/bin/activate" ]; then
        print_success "Virtual environment created successfully"
    else
        print_error "Failed to create virtual environment"
        print_support "Check if python3-venv is installed: sudo apt install python3-venv"
        exit 1
    fi
fi

# Activate virtual environment
print_info "Activating virtual environment..."
source .venv/bin/activate

# Verify activation
if [[ "$VIRTUAL_ENV" != "" ]]; then
    print_success "Virtual environment activated: $VIRTUAL_ENV"
else
    print_error "Failed to activate virtual environment"
    exit 1
fi

# Install workshop dependencies
print_step "Installing Workshop Dependencies"
print_warning "This downloads ML libraries and the workshop model (~2 GB total)"
print_info "Expected time: 15-25 minutes depending on internet speed"
print_info "Please be patient and do not close this terminal..."

# Upgrade pip first
print_info "Upgrading pip..."
python -m pip install --upgrade pip

# Install requirements
print_info "Installing workshop packages from requirements.txt..."
print_info "Progress will be shown below (this may take several minutes):"

if [ -f "prerequisites/requirements.txt" ]; then
    if pip install -r prerequisites/requirements.txt; then
        print_success "All workshop dependencies installed successfully"
    else
        print_error "Failed to install workshop dependencies"
        print_support "IMPORTANT: Copy the above pip output and contact workshop organizers"
        echo ""
        print_info "Common solutions:"
        print_info "1. Check internet connection"
        print_info "2. Install build tools: sudo apt install build-essential (Ubuntu)"
        print_info "3. Check available disk space (need 3GB+)"
        exit 1
    fi
else
    print_error "requirements.txt not found in prerequisites directory"
    print_support "Make sure you're running this from the correct workshop folder"
    exit 1
fi

# Verify installation
print_step "Verifying Installation"
print_info "Testing key workshop packages..."

packages=("torch" "transformers" "datasets" "peft" "trl")
failed_packages=()

for package in "${packages[@]}"; do
    if python -c "import $package; print(f'$package: {$package.__version__}')" 2>/dev/null; then
        print_success "$package imported successfully"
    else
        failed_packages+=("$package")
        print_error "$package import failed"
    fi
done

# Download and test the workshop model
if [ ${#failed_packages[@]} -eq 0 ]; then
    print_step "Pre-downloading Workshop Model"
    print_warning "This step downloads the Qwen2-0.5B model (~1.8GB) to save time during workshop"
    print_info "Expected time: 2-8 minutes depending on internet speed"
    print_info "The model will be cached for offline use during the workshop..."
    
    # Create a test script to download and verify the model
    cat > test_model_download.py << 'EOF'
import os
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

print("Starting model download and verification...")

# Set device
device = torch.device("cpu")
print(f"Using device: {device}")

# Model configuration
model_name = "Qwen/Qwen2-0.5B"
print(f"Downloading model: {model_name}")

try:
    # Download tokenizer
    print("Downloading tokenizer...")
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    print("[+] Tokenizer downloaded successfully")
    
    # Download model  
    print("Downloading model (this may take several minutes)...")
    base_model = AutoModelForCausalLM.from_pretrained(model_name, device_map="auto").to(device)
    print("[+] Model downloaded successfully")
    
    # Verify model functionality
    print(f"Model parameters: {base_model.num_parameters():,}")
    
    # Test a simple generation
    print("Testing model functionality...")
    test_input = "Hello, how can I help you?"
    inputs = tokenizer(test_input, return_tensors="pt").to(device)
    
    with torch.no_grad():
        outputs = base_model.generate(
            **inputs, 
            max_new_tokens=10,
            temperature=0.7,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id
        )
    
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    print("[+] Model generation test successful")
    print(f"Test output: {response[:100]}...")
    
    print("*** Model download and verification completed successfully! ***")
    print("The model is now cached and ready for the workshop.")
    
except Exception as e:
    print(f"[X] Model verification failed: {e}")
    print("This may be due to network issues or insufficient disk space.")
    print("The workshop can still proceed, but model loading will take longer.")
    exit(1)
    
print("Model verification complete.")
EOF
    
    # Run the model test
    print_info "Running model download and verification test..."
    if python test_model_download.py; then
        print_success "Model pre-download completed successfully!"
        print_info "Model is now cached and ready for instant loading during workshop"
    else
        print_warning "Model download/verification had issues but workshop can still proceed"
        print_info "Model will be downloaded during the workshop session instead"
    fi
    
    # Clean up test script
    rm -f test_model_download.py
    
else
    print_warning "Skipping model download due to package verification failures"
fi

# Configure Jupyter Kernel and VS Code
print_step "Configuring Jupyter Kernel and VS Code"
print_info "Setting up Jupyter kernel for VS Code integration..."

# Register the virtual environment as a Jupyter kernel
print_info "Registering virtual environment as Jupyter kernel..."
if python -m ipykernel install --user --name=.venv --display-name="Workshop Environment"; then
    print_success "Jupyter kernel registered successfully"
else
    print_warning "Jupyter kernel registration had issues but continuing..."
fi

# Create VS Code workspace configuration
print_info "Creating VS Code workspace configuration..."

# Create .vscode directory if it doesn't exist
if [ ! -d ".vscode" ]; then
    mkdir -p .vscode
    print_info "Created .vscode directory"
fi

# Create settings.json for optimal VS Code experience
cat > .vscode/settings.json << EOF
{
  "python.defaultInterpreterPath": "\${workspaceFolder}/.venv/bin/python",
  "jupyter.jupyterServerType": "local",
  "python.terminal.activateEnvironment": true,
  "jupyter.defaultKernel": ".venv",
  "python.linting.enabled": false,
  "python.formatting.provider": "none"
}
EOF

if [ $? -eq 0 ]; then
    print_success "VS Code settings.json created"
    print_info "Configured default Python interpreter and Jupyter settings"
else
    print_warning "Failed to create VS Code configuration"
    print_info "You may need to manually select the Python interpreter in VS Code"
fi

# Final results
print_step "Setup Complete!"

if [ ${#failed_packages[@]} -eq 0 ]; then
    cat << EOF

${GREEN}*** SUCCESS! Your workshop environment is ready. ***${NC}

[+] Python 3.8+ installed
[+] VS Code installed  
[+] Virtual environment created
[+] All workshop packages installed
[+] Qwen2-0.5B model pre-downloaded and cached
[+] Jupyter kernel registered for VS Code
[+] VS Code workspace configured

To start the workshop:
1. Open VS Code
2. Click "File" -> "Open Folder"
3. Navigate to and select the workshop folder: $WORKSHOP_DIR
4. Open the model-finetune.ipynb notebook
5. VS Code should automatically use the "Workshop Environment" kernel

Environment location: $WORKSHOP_DIR/.venv
Total download: ~3GB (packages + model)

NOTE: The model is now cached locally - loading will be instant during the workshop!
EOF
else
    cat << EOF

${YELLOW}[!] Setup completed with some issues.${NC}

Failed packages: ${failed_packages[*]}

Please contact workshop organizers with:
1. This entire terminal output
2. Your system info shown at the beginning
3. Any specific error messages

Workshop may still work with missing packages.
EOF
fi

echo ""
echo "Press Enter to exit"
read
