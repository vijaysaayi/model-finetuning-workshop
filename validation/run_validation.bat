@echo off
echo ===============================================
echo Model Fine-tuning Validation Runner
echo ===============================================
echo.

echo Checking if requirements are installed...
python -c "import torch, transformers, datasets, trl, peft" 2>nul
if errorlevel 1 (
    echo Installing required packages...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo Error installing requirements. Please check your Python environment.
        pause
        exit /b 1
    )
) else (
    echo Requirements already satisfied.
)

echo.
echo Choose validation type:
echo 1. Full Validation (10 epochs, ~15-20 minutes)
echo 2. Quick Test (3 epochs, ~3-5 minutes)
echo 3. Exit
echo.
set /p choice=Enter your choice (1-3): 

if "%choice%"=="1" (
    echo.
    echo Starting full validation...
    python model_finetuning_validation.py
) else if "%choice%"=="2" (
    echo.
    echo Starting quick test...
    python quick_test.py
) else if "%choice%"=="3" (
    echo Goodbye!
    exit /b 0
) else (
    echo Invalid choice. Please run the script again.
)

echo.
echo Validation completed!
pause
