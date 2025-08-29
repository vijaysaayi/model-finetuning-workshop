# Training a Custom AI Assistant for Axiomcart

Welcome to the Model Fine-Tuning Hands-on!

In this hands-on workshop, you'll learn how to fine-tune a language model to create a custom AI assistant for customer support using the Qwen2-0.5B model and LoRA (Low-Rank Adaptation) technique.

## 🎯 What You'll Learn how to

- Load and use a pre-trained language model
- Prepare training data for fine-tuning
- Implement LoRA for efficient fine-tuning
- Compare base model vs fine-tuned model performance

## 🛠️ Setup Instructions

Run the following script to install all tools needed for the workshop.

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

- ✅ Install Python (if not already installed).
- ✅ Install VS Code (if not already installed).
- ✅ Install required VS Code extensions (Python, Jupyter)
- ✅ Create a virtual environment (`.venv`)
- ✅ Install all Python dependencies.
- ✅ Downloads `Qwen2 0.5B` SLM which we will be using.
- ✅ Verify the installation

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

## 📚 Additional Resources

- [Hugging Face Transformers Documentation](https://huggingface.co/docs/transformers)
- [PEFT (Parameter-Efficient Fine-Tuning) Library](https://huggingface.co/docs/peft)
- [TRL (Transformer Reinforcement Learning) Documentation](https://huggingface.co/docs/trl)
- [LoRA Paper: "LoRA: Low-Rank Adaptation of Large Language Models"](https://arxiv.org/abs/2106.09685)
