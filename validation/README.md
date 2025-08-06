# Model Fine-tuning Validation Scripts

This folder contains Python scripts extracted from the Jupyter notebook for validating the model fine-tuning process.

## Files

### 🚀 `model_finetuning_validation.py`
The main validation script that replicates the complete notebook workflow:
- Loads Qwen2-0.5B base model
- Tests base model performance
- Fine-tunes with LoRA (10 epochs - reduced from 40)
- Compares base vs fine-tuned model performance
- Saves the trained model

### ⚡ `quick_test.py`
A streamlined version for rapid testing:
- Uses minimal training data (3 examples)
- Trains for only 3 epochs
- Quick validation of the fine-tuning pipeline
- Perfect for debugging and initial testing

### 📋 `requirements.txt`
All required Python packages for running the validation scripts.

## Usage

### Option 1: Full Validation (Recommended)
```powershell
# Install requirements
pip install -r requirements.txt

# Run the complete validation
python model_finetuning_validation.py
```

### Option 2: Quick Test
```powershell
# For rapid testing and debugging
python quick_test.py
```

## Key Changes from Notebook

1. **Reduced Epochs**: 
   - Main script: 10 epochs (vs 40 in notebook)
   - Quick test: 3 epochs
   
2. **Consolidated Code**: All cells combined into executable scripts

3. **Enhanced Logging**: Better progress tracking and status messages

4. **Error Handling**: Improved robustness for standalone execution

## Expected Output

The scripts will:
1. Download and load the Qwen2-0.5B model (~1GB)
2. Test base model responses (often generic/incorrect)
3. Fine-tune with Axiomcart-specific data
4. Test fine-tuned model responses (should be brand-appropriate)
5. Save trained models to `validation_output/` or `quick_test_output/`

## Hardware Requirements

- **CPU**: Any modern CPU (GPU not required)
- **RAM**: At least 4GB available
- **Storage**: ~2GB for model and outputs
- **Time**: 
  - Full validation: ~10-20 minutes
  - Quick test: ~2-5 minutes

## Troubleshooting

If you encounter issues:
1. Ensure all requirements are installed: `pip install -r requirements.txt`
2. Check available disk space (need ~2GB)
3. For memory issues, reduce batch size in the script
4. For download issues, check internet connection

## Next Steps

After successful validation:
- Compare base vs fine-tuned responses
- Experiment with different LoRA parameters
- Try different epoch numbers
- Explore Azure AI Foundry for production deployment
