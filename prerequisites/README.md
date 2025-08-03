# ⚙️ Prerequisites Setup

This folder contains simplified setup scripts for the Model Fine-Tuning Workshop.

## 🚀 Quick Start

### Windows Users
1. **Right-click** on `setup-windows.ps1`
2. Select **"Run with PowerShell"**
3. **Wait patiently** - installation can take 15-25 minutes depending on internet speed
4. **Copy any error messages** if something fails

### Linux/macOS Users
1. **Open terminal** in this folder
2. Run: `./setup-linux.sh`
3. **Wait patiently** - installation can take 15-25 minutes depending on internet speed
4. **Copy any error messages** if something fails

## 📋 What Gets Installed

### Prerequisites (auto-installed):
- **Python 3.11** - Programming language for the workshop
- **VS Code** - Code editor (recommended)
- **Git** - Version control (usually already installed)

### Python Environment:
- **Virtual Environment** - Isolated Python workspace
- **PyTorch** - Deep learning framework (~800MB download)
- **Transformers** - Hugging Face model library (~200MB)
- **Workshop Dependencies** - All required packages from requirements.txt

### Model Pre-Download:
- **Qwen2-0.5B Model** - Pre-downloaded and cached (~1.8GB)
- **Model Verification** - Tests that the model loads and works correctly
- **Instant Workshop Start** - No waiting for model downloads during session

**Total Download:** 3GB (packages + model)
**Installation Time:** 15-25 minutes (varies by internet speed)

💡 **The Qwen2-0.5B model is now pre-downloaded during setup, so you won't experience delays during the workshop!**

## ⚠️ Important Notes

### For Workshop Support:
- 📝 **Copy the ENTIRE terminal output** if you encounter errors
- 📧 **Send the copied text** to workshop organizers
- 🔍 **Include your operating system** (Windows 10/11, macOS version, Ubuntu version, etc.)

### Common Issues:
- **Slow downloads** - Normal during peak times, please be patient
- **Antivirus blocking** - Temporarily disable if needed
- **Corporate networks** - May require proxy settings
- **Disk space** - Ensure 3GB+ free space available

### If Scripts Fail:
1. ✅ Check internet connection
2. ✅ Ensure 3GB+ free disk space
3. ✅ Try running as Administrator (Windows) or with sudo (Linux)
4. ✅ Copy ALL terminal output and send to organizers

## 🆘 Getting Help

**During the workshop, if you face issues:**

1. **Copy this command output:**
   ```bash
   # Windows PowerShell:
   Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory
   python --version
   code --version
   
   # Linux/macOS:
   uname -a
   python3 --version
   code --version
   ```

2. **Copy the error message** from the terminal
3. **Raise your hand** or contact workshop organizers
4. **Include your OS details** and the copied error

---

**The workshop requires a working Python environment with specific packages. These scripts ensure everyone has the same setup for a smooth experience! 🎯**
