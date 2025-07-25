# Training a Custom AI Assistant for Axiomcart

Welcome to the Model Fine-Tuning Workshop! In this hands-on workshop, you'll learn how to fine-tune a language model to create a custom AI assistant for customer support using the Qwen2-0.5B model and LoRA (Low-Rank Adaptation) technique.

## 🎯 What You'll Learn

- How to load and use a pre-trained language model
- How to prepare training data for fine-tuning
- How to implement LoRA for efficient fine-tuning
- How to compare base model vs fine-tuned model performance
- Best practices for CPU-based model training

## 🛠️ Setup Instructions

### Step 1: Install Python

1. **Download Python 3.8 or higher** from [python.org](https://www.python.org/downloads/)
   - Choose the latest stable version (Python 3.11+ recommended)
   - During installation on Windows, make sure to check "Add Python to PATH"

2. **Verify Python installation**:

   ```bash
   python --version
   # or
   python3 --version
   ```

3. **Upgrade pip** (Python package manager):

   ```bash
   python -m pip install --upgrade pip
   ```

### Step 2: Install Visual Studio Code

1. **Download VS Code** from [code.visualstudio.com](https://code.visualstudio.com/)
2. **Install VS Code** following the installation wizard for your operating system

### Step 3: Install Required VS Code Extensions

Open VS Code and install these essential extensions:

1. **Python Extension**:
   - Open VS Code
   - Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac) to open Extensions
   - Search for "Python" by Microsoft
   - Click "Install"

2. **Jupyter Extension**:
   - Search for "Jupyter" by Microsoft
   - Click "Install"
   - This extension enables Jupyter notebook support in VS Code

### Step 4: Clone or Download the Workshop Repository

```bash
# Option 1: Clone with Git
git clone https://github.com/vijaysaayi/model-finetuning-workshop.git
cd model-finetuning-workshop

# Option 2: Download ZIP
# Download the ZIP file from GitHub and extract it
```

### Step 5: Set Up Python Environment

1. **Open the project in VS Code**:

   ```bash
   code model-finetuning-workshop
   ```

2. **Create a virtual environment** (recommended):

   ```bash
   python -m venv venv
   
   # Activate on Windows
   venv\Scripts\activate
   
   # Activate on macOS/Linux
   source venv/bin/activate
   ```

3. **Install required packages**:

   **Recommended**: Use the provided `requirements.txt` file:

   ```bash
   pip install -r requirements.txt
   ```

### Step 6: Configure VS Code for Jupyter

1. **Open the notebook**: Click on `model-finetune.ipynb` in VS Code
2. **Select Python interpreter**:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Python: Select Interpreter"
   - Choose the Python interpreter from your virtual environment
3. **Select Jupyter kernel**:
   - When you open the notebook, VS Code will prompt you to select a kernel
   - Choose the Python interpreter from your virtual environment

## 🚀 Running the Workshop

1. **Open** `model-finetune.ipynb` in VS Code
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

### Common Issues and Solutions

#### Issue: Slow training

**Solution**:

- Reduce `num_train_epochs` for faster training
- Reduce dataset size for testing
- Ensure no other heavy applications are running

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
