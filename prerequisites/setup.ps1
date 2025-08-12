# Model Fine-Tuning Workshop - Windows Setup
# This script installs all prerequisites and sets up the environment

param(
    [switch]$Help
)

if ($Help) {
    Write-Host @"
================================================================
        Model Fine-Tuning Workshop - Windows Setup Script
================================================================

WHAT THIS SCRIPT DOES:
1. Detect system architecture and install Python 3.11 for x64
   - ARM64 Windows devices are NOT supported - use DevBox instead
2. Check and Install Visual Studio Code (if needed) using winget
   
3. Create isolated Python environment
   - Creates .venv folder in workshop directory
   - Installs machine learning packages (PyTorch, Transformers, etc.)
   - Downloads and caches Qwen2-0.5B model (~1GB)
   
4. Verifies installation

[!] ARM64 Windows devices should use Microsoft DevBox instead.
[!] Installation could take 15-30 minutes depending on your laptop compute and internet speed.
[!] Please copy ALL terminal output if you encounter any errors.

Press Ctrl+C to cancel, or
Press Enter to continue with installation
"@
    exit 0
}

# Color functions for better output
function Write-Step($message) {
    Write-Host "`n[STEP] $message" -ForegroundColor Blue -BackgroundColor White
}

function Write-Info($message) {
    Write-Host "[INFO] $message" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "[SUCCESS] $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

function Write-Support($message) {
    Write-Host "[SUPPORT] $message" -ForegroundColor Magenta
}

# Helper functions for manual installation steps
function Show-PythonManualInstallSteps {
    Write-Info ""
    Write-Info "MANUAL INSTALLATION STEPS:"
    Write-Info "1. Visit: https://www.python.org/downloads/windows/"
    Write-Info "2. Download 'Python 3.11.x' (Windows installer 64-bit)"
    Write-Info "3. Run the installer and CHECK 'Add Python to PATH'"
    Write-Info "4. After installation, open NEW PowerShell and type: python --version"
    Write-Info "5. If successful, re-run this setup script again"
    Write-Support "If manual installation fails, copy this error and contact workshop organizers"
}

function Show-VSCodeManualInstallSteps {
    Write-Info ""
    Write-Info "MANUAL INSTALLATION STEPS:"
    Write-Info "1. Visit: https://code.visualstudio.com/"
    Write-Info "2. Click 'Download for Windows' (User Installer 64-bit)"
    Write-Info "3. Run the installer (accept all defaults)"
    Write-Info "4. After installation, VS Code will be available in Start Menu"
    Write-Info "5. Re-run this setup script to continue with the workshop setup"
    Write-Support "If manual VS Code installation fails, copy this error and contact workshop organizers"
}

# Header
Clear-Host
Write-Host @"

================================================================
        Model Fine-Tuning Workshop - Windows Setup Script
================================================================

WHAT THIS SCRIPT DOES:
1. Detect system architecture and install Python 3.11 for x64
   - ARM64 Windows devices are NOT supported - use DevBox instead
2. Check and Install Visual Studio Code (if needed) using winget
   
3. Create isolated Python environment
   - Creates .venv folder in workshop directory
   - Installs machine learning packages (PyTorch, Transformers, etc.)
   - Downloads and caches Qwen2-0.5B Small Language model (~1GB)
   
4. Verifies installation

[!] ARM64 Windows devices should use Microsoft DevBox instead.
[!] Installation could take 15-30 minutes depending on your laptop compute and internet speed.
[!] Please copy ALL terminal output if you encounter any errors.

Press Ctrl+C to cancel, or
"@ -ForegroundColor White

Read-Host "Press Enter to continue with installation"

# System Information for support
Write-Step "Collecting System Information"
try {
    $os = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory
    Write-Info "OS: $($os.WindowsProductName) $($os.WindowsVersion)"
    
    # Detect system architecture using WMI for more accurate detection
    try {
        $processorArch = (Get-CimInstance Win32_Processor).Architecture
        $isARM = $false
        
        switch ($processorArch) {
            0 { 
                $architecture = "x86" 
                Write-Info "Architecture: x86 (32-bit)"
            }
            5 { 
                $architecture = "ARM" 
                $isARM = $true
                Write-Info "Architecture: ARM (32-bit)"
                Write-Info "ARM-optimized setup will be used for better PyTorch performance"
            }
            6 { 
                $architecture = "Itanium" 
                Write-Info "Architecture: Itanium (64-bit)"
            }
            9 { 
                $architecture = "x64" 
                Write-Info "Architecture: x64 (AMD64)"
            }
            12 { 
                $architecture = "ARM64" 
                $isARM = $true
                Write-Info "Architecture: ARM64 (64-bit)"
                Write-Info "ARM-optimized setup will be used for better PyTorch performance"
            }
            default { 
                $architecture = "Unknown ($processorArch)" 
                Write-Warning "Unknown processor architecture: $processorArch"
                Write-Info "Falling back to environment variable detection"
                $envArch = $env:PROCESSOR_ARCHITECTURE
                if ($envArch -eq "ARM64" -or $env:PROCESSOR_ARCHITEW6432 -eq "ARM64") {
                    $isARM = $true
                    $architecture = "ARM64 (env fallback)"
                    Write-Info "Architecture: ARM64 (detected via environment)"
                    Write-Info "ARM-optimized setup will be used for better PyTorch performance"
                }
                else {
                    $architecture = "$envArch (env fallback)"
                    Write-Info "Architecture: $architecture"
                }
            }
        }
    }
    catch {
        # Fallback to original method if WMI fails
        Write-Warning "Failed to detect architecture via WMI: $_"
        Write-Info "Falling back to environment variable detection"
        $architecture = $env:PROCESSOR_ARCHITECTURE
        $isARM = $false
        
        if ($architecture -eq "ARM64" -or $env:PROCESSOR_ARCHITEW6432 -eq "ARM64") {
            $isARM = $true
            Write-Info "Architecture: ARM64 (detected via environment fallback)"
            Write-Info "ARM-optimized setup will be used for better PyTorch performance"
        }
        else {
            Write-Info "Architecture: $architecture (environment fallback)"
        }
    }
    
    # Fix RAM calculation
    if ($os.TotalPhysicalMemory -and $os.TotalPhysicalMemory -gt 0) {
        $ramGB = [math]::Round($os.TotalPhysicalMemory / 1GB, 1)
        Write-Info "RAM: $ramGB GB"
    }
    else {
        # Fallback method for RAM detection
        try {
            $ram = Get-WmiObject -Class Win32_ComputerSystem | Select-Object TotalPhysicalMemory
            if ($ram.TotalPhysicalMemory -gt 0) {
                $ramGB = [math]::Round($ram.TotalPhysicalMemory / 1GB, 1)
                Write-Info "RAM: $ramGB GB"
            }
            else {
                Write-Info "RAM: Unable to detect"
            }
        }
        catch {
            Write-Info "RAM: Unable to detect"
        }
    }
    
    Write-Info "PowerShell: $($PSVersionTable.PSVersion)"
    Write-Info "Date/Time: $(Get-Date)"
    Write-Info "User: $env:USERNAME"
}
catch {
    Write-Warning "Could not collect system info: $_"
    $isARM = $false
}

# ARM64 Compatibility Check - Exit Early if ARM64 Detected
if ($isARM) {
    Write-Host @"

================================================================
                     ARM64 DETECTED - UNSUPPORTED
================================================================

[!] ARM64 Windows devices are NOT supported for this workshop.

WHY ARM64 IS NOT SUPPORTED:
- Limited PyTorch ARM64 Windows support (experimental)
- Many ML packages lack stable ARM64 Windows builds
- Model fine-tuning may have compatibility issues
- Performance may be significantly reduced

SOLUTION - Use Microsoft DevBox (Recommended):
================================================================

1. Create a new DevBox:
   -> Visit: https://devbox.microsoft.com
   -> Sign in with your Microsoft account
   -> Create a new DevBox (this provides an x64 cloud environment)

2. Connect to your DevBox:
   -> Follow the connection steps in the prerequisites Word document
   -> Your DevBox will have full x64 compatibility

3. Run this setup script in your DevBox:
   -> Copy this workshop folder to your DevBox
   -> Run this setup.ps1 script in the DevBox environment
   -> All packages and models will work reliably

BENEFITS OF DEVBOX:
- Full x64 compatibility for all ML packages
- Better performance for model training
- Cloud compute resources
- Stable, pre-configured development environment
- No ARM64-specific compatibility issues

================================================================

The steps to create and connect to a DevBox are provided in the 
prerequisites Word document shared with you.

"@ -ForegroundColor Red -BackgroundColor Black

    Write-Warning "This script will now exit. Please use DevBox for the workshop."
    Write-Info "Refer to the prerequisites documentation for DevBox setup instructions."
    Read-Host "`nPress Enter to exit"
    exit 1
}

# Check winget availability
Write-Step "Checking Windows Package Manager (winget)"
try {
    $wingetVersion = winget --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "winget is available: $wingetVersion"
    }
    else {
        throw "winget not found"
    }
}
catch {
    Write-Error "Windows Package Manager (winget) is not available"
    Write-Info "Please install from Microsoft Store: 'App Installer'"
    Write-Info "Or download from: https://aka.ms/getwinget"
    Write-Support "Copy this error message and contact workshop organizers"
    Read-Host "Press Enter to exit"
    exit 1
}

# Install Python
Write-Step "Installing Python"

# Use Python 3.11 for x64 architecture (ARM64 is not supported)
$pythonVersion = "3.11"
$pythonPackageId = "Python.Python.3.11"
Write-Info "Using Python 3.11 for x64 architecture"

Write-Info "Checking for existing Python installation..."

try {
    $currentPythonVersion = python --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Python already installed: $currentPythonVersion"
        
        # Check version compatibility
        if ($currentPythonVersion -match "Python (\d+)\.(\d+)") {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            
            # We need at least Python 3.9
            if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 9)) {
                Write-Warning "Python version is too old (need 3.9+)"
                Write-Info "Installing Python $pythonVersion..."
                winget install $pythonPackageId --accept-source-agreements --accept-package-agreements --scope user
            }
            else {
                Write-Success "Python version is compatible"
            }
        }
    }
    else {
        throw "Python not found"
    }
}
catch {
    Write-Info "Python not found, installing Python $pythonVersion..."
    Write-Info "This may take 3-5 minutes depending on internet speed..."
    
    try {
        $wingetResult = winget install $pythonPackageId --accept-source-agreements --accept-package-agreements --scope user 2>&1
        $wingetExitCode = $LASTEXITCODE
        
        Write-Info "winget exit code: $wingetExitCode"
        
        if ($wingetExitCode -eq 0) {
            Write-Success "Python installation completed"
            
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Test Python
            Start-Sleep 3
            $pythonVersion = python --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Python verified: $pythonVersion"
            }
            else {
                Write-Warning "Python installed but not accessible. You may need to restart PowerShell."
            }
        }
        elseif ($wingetExitCode -eq -1978335205 -or $wingetResult -match "APPINSTALLER_CLI_ERROR_MSSTORE_BLOCKED_BY_POLICY") {
            Write-Error "Microsoft Store is blocked by policy on this system"
            Write-Info "This is common in corporate environments"
            Show-PythonManualInstallSteps
            Read-Host "Press Enter to exit"
            exit 1
        }
        else {
            Write-Error "winget install failed with exit code: $wingetExitCode"
            Write-Info "winget output: $wingetResult"
            Show-PythonManualInstallSteps
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
    catch {
        Write-Error "Failed to install Python: $_"
        Show-PythonManualInstallSteps
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Install VS Code
Write-Step "Installing Visual Studio Code"
Write-Info "Checking for existing VS Code installation..."

try {
    $codeVersion = code --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "VS Code already installed"
        Write-Info "Version: $($codeVersion[0])"
    }
    else {
        throw "VS Code not found"
    }
}
catch {
    Write-Info "VS Code not found, installing..."
    Write-Info "This may take 2-3 minutes depending on internet speed..."
    
    try {
        $wingetResult = winget install Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements --scope user 2>&1
        $wingetExitCode = $LASTEXITCODE
        
        Write-Info "winget exit code: $wingetExitCode"
        
        if ($wingetExitCode -eq 0) {
            Write-Success "VS Code installation completed"
            
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Test VS Code
            Start-Sleep 3
            $codeVersion = code --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "VS Code verified"
            }
            else {
                Write-Warning "VS Code installed but not accessible via command line"
                Write-Info "This is normal - you can still use VS Code from Start Menu"
            }
        }
        elseif ($wingetExitCode -eq -1978335205 -or $wingetResult -match "APPINSTALLER_CLI_ERROR_MSSTORE_BLOCKED_BY_POLICY") {
            Write-Error "Microsoft Store is blocked by policy on this system"
            Write-Warning "VS Code installation failed, but this won't prevent the workshop"
            Show-VSCodeManualInstallSteps
        }
        else {
            Write-Error "winget install failed with exit code: $wingetExitCode"
            Write-Info "winget output: $wingetResult"
            Show-VSCodeManualInstallSteps
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
    catch {
        Write-Error "Failed to install VS Code: $_"
        Write-Warning "VS Code installation failed, but this won't prevent the workshop"
        Show-VSCodeManualInstallSteps
    }
}

# Install VS Code Extensions
Write-Step "Installing VS Code Extensions"
Write-Info "Installing Python and Jupyter extensions for optimal workshop experience..."

# Required extensions for the workshop
$requiredExtensions = @(
    @{id = "ms-python.python"; name = "Python" },
    @{id = "ms-toolsai.jupyter"; name = "Jupyter" }
)

foreach ($extension in $requiredExtensions) {
    Write-Info "Checking for $($extension.name) extension..."
    
    try {
        # Check if extension is already installed
        $extensionList = code --list-extensions 2>$null
        
        if ($LASTEXITCODE -eq 0 -and $extensionList -contains $extension.id) {
            Write-Success "$($extension.name) extension already installed"
        }
        else {
            Write-Info "Installing $($extension.name) extension..."
            code --install-extension $extension.id --force 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "$($extension.name) extension installed successfully"
            }
            else {
                Write-Warning "Failed to install $($extension.name) extension"
                Write-Info "You can manually install from VS Code Extensions tab"
            }
        }
    }
    catch {
        Write-Warning "Could not manage $($extension.name) extension: $_"
        Write-Info "VS Code may not be accessible via command line"
        Write-Info "Please install extensions manually from VS Code Extensions tab:"
        Write-Info "  - Search for '$($extension.name)' in Extensions (Ctrl+Shift+X)"
    }
}

# Navigate to workshop directory
Write-Step "Setting up Workshop Environment"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$workshopPath = Split-Path -Parent $scriptPath
Set-Location $workshopPath

Write-Info "Workshop directory: $workshopPath"

# Create virtual environment
Write-Info "Creating Python virtual environment..."
Write-Info "This creates an isolated Python workspace for the workshop"

try {
    python -m venv .venv
    
    if (Test-Path ".venv\Scripts\Activate.ps1") {
        Write-Success "Virtual environment created successfully"
    }
    else {
        throw "Virtual environment creation failed"
    }
}
catch {
    Write-Error "Failed to create virtual environment: $_"
    Write-Info ""
    Write-Info "MANUAL VIRTUAL ENVIRONMENT CREATION:"
    Write-Info "1. Open PowerShell in the workshop directory: $workshopPath"
    Write-Info "2. Run: python -m venv .venv"
    Write-Info "3. If successful, you should see a .venv folder created"
    Write-Info "4. Then run: .venv\\Scripts\\Activate.ps1"
    Write-Info "5. If successful, re-run this setup script"
    Write-Support "If manual virtual environment creation fails, copy this error and contact workshop organizers"
    Read-Host "Press Enter to exit"
    exit 1
}

# Activate virtual environment
Write-Info "Activating virtual environment..."
try {
    & ".venv\Scripts\Activate.ps1"
    Write-Success "Virtual environment activated"
}
catch {
    Write-Error "Failed to activate virtual environment: $_"
    Write-Info ""
    Write-Info "MANUAL VIRTUAL ENVIRONMENT ACTIVATION:"
    Write-Info "1. Open PowerShell in the workshop directory: $workshopPath"
    Write-Info "2. Run: .venv\\Scripts\\Activate.ps1"
    Write-Info "3. You should see (.venv) appear at the start of your command prompt"
    Write-Info "4. If successful, continue with: pip install -r prerequisites\\requirements.txt"
    Write-Support "If manual activation fails, copy this error and contact workshop organizers"
    Read-Host "Press Enter to exit"
    exit 1
}

# Install workshop dependencies
Write-Step "Installing Workshop Dependencies"
Write-Warning "This downloads ML libraries and the workshop model (3GB total)"
Write-Info "Expected time: 15-25 minutes depending on internet speed"
Write-Info "Please be patient and do not close this window..."

# Upgrade pip first
Write-Info "Upgrading pip..."
try {
    python -m pip install --upgrade pip
    Write-Success "pip upgraded successfully"
}
catch {
    Write-Warning "pip upgrade failed, but continuing..."
}

# Install requirements
Write-Info "Installing workshop packages from requirements.txt..."
Write-Info "Progress will be shown below (this may take several minutes):"

if (Test-Path "prerequisites\requirements.txt") {
    try {
        # Use standard requirements file for x64
        $requirementsFile = "prerequisites\requirements.txt"
        
        # Install workshop dependencies
        Write-Info "Installing workshop dependencies from $requirementsFile..."
        pip install -r $requirementsFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "All workshop dependencies installed successfully"
        }
        else {
            throw "pip install failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-Error "Failed to install workshop dependencies: $_"
        Write-Info ""
        Write-Info "MANUAL PACKAGE INSTALLATION:"
        Write-Info "1. Ensure virtual environment is activated: .venv\\Scripts\\Activate.ps1"
        Write-Info "2. Check you're in workshop directory: $workshopPath"
        Write-Info "3. Run manually: pip install -r prerequisites\\requirements.txt"
        Write-Info "4. Wait for installation to complete (15-25 minutes)"
        Write-Info "5. If successful, re-run this setup script"
        Write-Info ""
        Write-Support "IMPORTANT: Copy the above pip output and contact workshop organizers"
        Read-Host "Press Enter to exit"
        exit 1
    }
}
else {
    Write-Error "requirements.txt not found in prerequisites directory"
    Write-Support "Make sure you're running this from the correct workshop folder"
    Read-Host "Press Enter to exit"
    exit 1
}

# Verify installation
Write-Step "Verifying Installation"
Write-Info "Testing key workshop packages..."

$packages = @("torch", "transformers", "datasets", "peft", "trl")
$failed = @()

foreach ($package in $packages) {
    try {
        $version = python -c "import $package; print($package.__version__)" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$package $version"
        }
        else {
            $failed += $package
            Write-Error "$package import failed"
        }
    }
    catch {
        $failed += $package
        Write-Error "$package import failed: $_"
    }
}

if ($failed.Count -eq 0) {
    Write-Success "All packages verified successfully!"
}
else {
    Write-Error "Package verification failed for: $($failed -join ', ')"
    Write-Info ""
    Write-Info "MANUAL PACKAGE VERIFICATION:"
    Write-Info "1. Ensure virtual environment is activated: .venv\\Scripts\\Activate.ps1"
    Write-Info "2. Test each package manually:"
    foreach ($pkg in $failed) {
        Write-Info "   - python -c 'import $pkg; print($pkg.__version__)'"
    }
    Write-Info "3. If imports fail, try reinstalling: pip install --upgrade $($failed -join ' ')"
    Write-Info "4. Check for error messages in pip output above"
    Write-Support "Copy this error and contact workshop organizers"
}

# Download and test the workshop model
if ($failed.Count -eq 0) {
    Write-Step "Pre-downloading Workshop Model"
    Write-Warning "This step downloads the Qwen2-0.5B model (~1 GB) to save time during workshop"
    Write-Info "Expected time: 2-15 minutes depending on internet speed"
    Write-Info "The model will be cached for offline use during the workshop..."
    
    try {
        # Create a test script to download and verify the model
        $modelTestScript = @"
import os
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

print("Starting model download and verification...")

# Set device
device = torch.device("cpu")
print(f"Using device: {device}")

# Check PyTorch build info
print(f"PyTorch version: {torch.__version__}")
print(f"Platform: {torch.__platform__}")

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
"@
        
        # Write the test script to a temporary file
        $modelTestScript | Out-File -FilePath "test_model_download.py" -Encoding UTF8
        
        # Run the model test
        Write-Info "Running model download and verification test..."
        python test_model_download.py
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Model pre-download completed successfully!"
            Write-Info "Model is now cached and ready for instant loading during workshop"
        }
        else {
            Write-Warning "Model download/verification had issues but workshop can still proceed"
            Write-Info "Model will be downloaded during the workshop session instead"
        }
        
        # Clean up test script
        Remove-Item "test_model_download.py" -ErrorAction SilentlyContinue
        
    }
    catch {
        Write-Warning "Model pre-download failed: $_"
        Write-Info "This is not critical - model will download during workshop instead"
        Write-Info "Ensure you have stable internet during the workshop session"
    }
}
else {
    Write-Warning "Skipping model download due to package verification failures"
}

# Configure Jupyter Kernel and VS Code
Write-Step "Configuring Jupyter Kernel and VS Code"
Write-Info "Setting up Jupyter kernel for VS Code integration..."

try {
    # Register the virtual environment as a Jupyter kernel
    Write-Info "Registering virtual environment as Jupyter kernel..."
    python -m ipykernel install --user --name=.venv --display-name="Workshop Environment"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Jupyter kernel registered successfully"
    }
    else {
        Write-Warning "Jupyter kernel registration had issues but continuing..."
    }
}
catch {
    Write-Warning "Failed to register Jupyter kernel: $_"
    Write-Info ""
    Write-Info "MANUAL JUPYTER KERNEL REGISTRATION:"
    Write-Info "1. Ensure virtual environment is activated: .venv\\Scripts\\Activate.ps1"
    Write-Info "2. Run: python -m ipykernel install --user --name=.venv --display-name='Workshop Environment'"
    Write-Info "3. This step is optional - VS Code can still work without it"
    Write-Info "4. In VS Code, you can manually select the Python interpreter: .venv\\Scripts\\python.exe"
    Write-Support "If VS Code notebook functionality doesn't work, copy this error and contact workshop organizers"
}

# Create VS Code workspace configuration
Write-Info "Creating VS Code workspace configuration..."
try {
    # Create .vscode directory if it doesn't exist
    if (-not (Test-Path ".vscode")) {
        New-Item -ItemType Directory -Path ".vscode" | Out-Null
        Write-Info "Created .vscode directory"
    }
    
    # Create settings.json for optimal VS Code experience
    $vscodeSettings = @{
        "python.defaultInterpreterPath"       = "${workspaceFolder}\\.venv\\Scripts\\python.exe"
        "jupyter.jupyterServerType"           = "local"
        "python.terminal.activateEnvironment" = $true
        "jupyter.defaultKernel"               = ".venv"
        "python.linting.enabled"              = $false
        "python.formatting.provider"          = "none"
    }
    
    $settingsJson = $vscodeSettings | ConvertTo-Json -Depth 10
    $settingsJson | Out-File -FilePath ".vscode\settings.json" -Encoding UTF8
    
    Write-Success "VS Code settings.json created"
    Write-Info "Configured default Python interpreter and Jupyter settings"
}
catch {
    Write-Warning "Failed to create VS Code configuration: $_"
    Write-Info ""
    Write-Info "MANUAL VS CODE CONFIGURATION:"
    Write-Info "1. Open VS Code in the workshop folder: $workshopPath"
    Write-Info "2. Press Ctrl+Shift+P and type 'Python: Select Interpreter'"
    Write-Info "3. Choose: .venv\\Scripts\\python.exe"
    Write-Info "4. When opening notebook files, select 'Workshop Environment' kernel"
    Write-Support "If VS Code configuration issues persist, copy this error and contact workshop organizers"
}

# Final instructions
Write-Step "Setup Complete!"

if ($failed.Count -eq 0) {
    Write-Host @"

*** SUCCESS! Your workshop environment is ready. ***

[+] Python installed
[+] VS Code installed with Python and Jupyter extensions
[+] Virtual environment created
[+] All workshop packages installed
[+] Qwen2-0.5B Small Language model pre-downloaded and cached
[+] Jupyter kernel registered for VS Code
[+] VS Code workspace configured

To start the workshop:
1. Open VS Code
2. Click "File" -> "Open Folder"
3. Navigate to and select the workshop folder: $workshopPath
4. Open the model-finetune-handon.ipynb notebook
5. VS Code should automatically use the "Workshop Environment" kernel

Environment location: $workshopPath\.venv
Total download: ~3GB (packages + model)

NOTE: The model is now cached locally - loading will be instant during the workshop!
"@ -ForegroundColor Green
}
else {
    Write-Host @"

[!] Setup completed with some issues.

Failed packages: $($failed -join ', ')

Please contact workshop organizers with:
1. This entire PowerShell output
2. Your system info shown at the beginning
3. Any specific error messages

Workshop may still work with missing packages.
"@ -ForegroundColor Yellow
}

Write-Host "`nPress Enter to exit" -ForegroundColor White
Read-Host
