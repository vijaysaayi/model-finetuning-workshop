# Training a Custom AI Assistant for Axiomcart

Welcome to the Model Fine-Tuning Hands-on!

In this hands-on workshop, you'll learn how to fine-tune a language model to create a custom AI assistant for customer support using the Qwen2-0.5B model and LoRA (Low-Rank Adaptation) technique.

## 🎯 What You'll Learn how to

- Load and use a pre-trained language model
- Prepare training data for fine-tuning
- Implement LoRA for efficient fine-tuning
- Compare base model vs fine-tuned model performance

## 🛠️ Setup Instructions

### Automated Setup (One-Click Installation)

The workshop includes automated setup scripts that handle everything for you:

**For Windows**:

```powershell
.\prerequisites\setup.ps1
```

**For Linux/macOS**:

```bash
chmod +x prerequisites/setup.sh
./prerequisites/setup.sh
```

These scripts will automatically:

- ✅ Install Python 3.11+ (if not already installed)
- ✅ Install VS Code (if not already installed) 
- ✅ Install required VS Code extensions (Python, Jupyter)
- ✅ Create a virtual environment (`.venv`)
- ✅ Install all Python dependencies including `hf_transfer` for faster downloads
- ✅ Verify the installation

> **🚀 Performance Boost**: The setup includes `hf_transfer` which provides **2-5x faster model downloads** from Hugging Face Hub using Rust-based acceleration!

### Getting Started

1. **Download/Clone this repository**
2. **Open PowerShell/Terminal** in the project folder
3. **Run the setup script** for your platform (commands above)
4. **Open VS Code** and navigate to `workshop/model-finetuning-handson.ipynb`
5. **Select the Python interpreter** from `.venv` when prompted
6. **Start the workshop!** 🎉

That's it! The automated setup handles all the complexity for you.

## 🚀 Running the Workshop

1. **Open** `workshop/model-finetuning-handson.ipynb` in VS Code
2. **Run cells sequentially**:
   - Click the "Run" button (▶️) next to each cell
   - Or use `Shift+Enter` to run the current cell and move to the next
   - Or use `Ctrl+Enter` to run the current cell without moving

3. **Monitor progress**:
   - Watch the output of each cell
   - The training process (Step 8) will take several minutes
   - Progress will be displayed in the cell output

## 📖 Workshop Content Overview

The workshop is structured into 11 main steps:

1. **Import Required Libraries** - Set up the necessary Python packages
2. **Load Base Model and Tokenizer** - Initialize the Qwen2-0.5B model
3. **Test Base Model Performance** - Evaluate pre-training performance
4. **Prepare Training Data** - Create Axiomcart-specific FAQ dataset
5. **Set Up Fine-Tuning Configuration** - Configure LoRA parameters
6. **Configure Training Arguments** - Set training hyperparameters
7. **Initialize the Trainer** - Set up the SFTTrainer
8. **Start Training** - Execute the fine-tuning process
9. **Save the Fine-Tuned Model** - Persist the trained model
10. **Test the Fine-Tuned Model** - Evaluate post-training performance
11. **Test with Additional Questions** - Comprehensive testing

## 🔧 Troubleshooting

### If Setup Script Fails

#### Issue: PowerShell execution policy error (Windows)

**Solution**:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then run the setup script again.

#### Issue: Permission denied (Linux/macOS)

**Solution**:

```bash
chmod +x prerequisites/setup.sh
sudo ./prerequisites/setup.sh
```

#### Issue: General setup failure

**Solutions to try**:

- Check internet connection (required for downloads)
- Run as Administrator (Windows) or with sudo (Linux/macOS)
- Ensure you have at least 3GB of free disk space
- Restart your computer and try again
- Check Windows Defender or antivirus isn't blocking the installation

> **💡 Tip**: If you encounter issues, please share the complete error output for faster troubleshooting assistance.

## 📊 Expected Results

After completing the workshop, you should observe:

- **Base Model**: Generic responses that may not be specific to Axiomcart
- **Fine-Tuned Model**: Responses that are:
  - More specific to Axiomcart's policies and procedures
  - Consistent with the company's tone and style
  - More helpful for customer service scenarios

## 🎓 Learning Outcomes

By the end of this workshop, you will have:

- ✅ Successfully fine-tuned a language model using LoRA
- ✅ Understanding of the fine-tuning process and its parameters
- ✅ Experience with modern ML tools (Transformers, PEFT, TRL)
- ✅ A working custom AI assistant for customer support
- ✅ Knowledge of how to evaluate model performance before and after fine-tuning

## 📚 Additional Resources

- [Hugging Face Transformers Documentation](https://huggingface.co/docs/transformers)
- [PEFT (Parameter-Efficient Fine-Tuning) Library](https://huggingface.co/docs/peft)
- [TRL (Transformer Reinforcement Learning) Documentation](https://huggingface.co/docs/trl)
- [LoRA Paper: "LoRA: Low-Rank Adaptation of Large Language Models"](https://arxiv.org/abs/2106.09685)
