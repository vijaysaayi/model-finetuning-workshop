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

## 📚 Additional Resources

- [Hugging Face Transformers Documentation](https://huggingface.co/docs/transformers)
- [PEFT (Parameter-Efficient Fine-Tuning) Library](https://huggingface.co/docs/peft)
- [TRL (Transformer Reinforcement Learning) Documentation](https://huggingface.co/docs/trl)
- [LoRA Paper: "LoRA: Low-Rank Adaptation of Large Language Models"](https://arxiv.org/abs/2106.09685)
