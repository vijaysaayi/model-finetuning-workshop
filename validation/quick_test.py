#!/usr/bin/env python3
"""
Quick Test Script for Model Fine-tuning Validation
=================================================

This is a streamlined version for quick testing with minimal epochs.
Use this for rapid validation and testing.

Usage:
    python quick_test.py
"""

import torch
import random
import warnings
import os
import sys
from datasets import Dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments
from trl import SFTTrainer
from peft import LoraConfig, get_peft_model

import torch
import random
import warnings
import os
import sys
from datasets import Dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments
from trl import SFTTrainer
from peft import LoraConfig, get_peft_model

# Quick test configuration
BASE_MODEL_NAME = "Qwen/Qwen2-0.5B"
OUTPUT_DIR = "./quick_test_output"
EPOCHS = 3  # Very minimal for quick testing

def safe_print(text):
    """Print text with fallback for encoding issues."""
    try:
        print(text)
    except UnicodeEncodeError:
        # Remove emojis and special characters for Windows compatibility
        import re
        clean_text = re.sub(r'[^\x00-\x7F]+', '', text)
        print(clean_text)

# Compatibility check for accelerate version
try:
    import accelerate
    accelerate_version = accelerate.__version__
    safe_print(f"🔧 Accelerate version: {accelerate_version}")
except ImportError:
    safe_print("⚠️  Accelerate not found")
    sys.exit(1)

# Remove emojis and special characters for Windows compatibility
import re
clean_text = re.sub(r'[^\x00-\x7F]+', '', text)
print(clean_text)

# Setup
os.environ["HF_HUB_ENABLE_HF_TRANSFER"] = "1"

# Device selection - force CPU in CI environments or when MPS memory issues occur
if os.getenv('CI') or os.getenv('CUDA_VISIBLE_DEVICES') == '':
    # In CI or when CUDA is disabled, force CPU-only mode
    device = torch.device("cpu")
    device_map = None
    safe_print("🔧 Using CPU-only mode (CI environment or CUDA disabled)")
else:
    # Local development - use auto device mapping
    device = torch.device("cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu")
    device_map = "auto"
    safe_print(f"🔧 Using device: {device}")

warnings.filterwarnings("ignore")

# Minimal test questions
TEST_QUESTIONS = [
    "What email address should I use to contact support?",
    "Is there a discount for new customers?"
]

def quick_test():
    """Run a quick validation test."""
    safe_print("🚀 Quick Fine-tuning Validation Test")
    safe_print("=" * 50)
    
    # Load model
    safe_print("📥 Loading model...")
    tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL_NAME)
    
    # Load model with appropriate device mapping
    if device_map is None:
        # CPU-only mode
        model = AutoModelForCausalLM.from_pretrained(BASE_MODEL_NAME, torch_dtype=torch.float32)
        model = model.to(device)
    else:
        # Auto device mapping
        model = AutoModelForCausalLM.from_pretrained(BASE_MODEL_NAME, device_map=device_map).to(device)
    
    # Minimal training data
    train_data = [
        {"instruction": "How can I contact customer support?", "response": "Email us at support@axiomcart.com or use our live chat! 📞"},
        {"instruction": "Are there any discounts for new customers?", "response": "Yes! New customers get 10% off with code 'FIRST10'! 🎉"},
        {"instruction": "What payment methods do you accept?", "response": "We accept all major credit cards, PayPal, and bank transfers! 💳"},
    ]
    
    train_dataset = Dataset.from_list(train_data)
    
    # Setup LoRA
    peft_config = LoraConfig(r=8, lora_alpha=16, lora_dropout=0.1, bias="none", task_type="CAUSAL_LM")
    model = get_peft_model(model, peft_config)
    
    # Quick training
    training_args = TrainingArguments(
        output_dir=OUTPUT_DIR,
        per_device_train_batch_size=2,
        num_train_epochs=EPOCHS,
        learning_rate=0.0001,
        logging_steps=1,
        save_steps=1,
        remove_unused_columns=False,
    )
    
    trainer = SFTTrainer(
        model=model,
        train_dataset=train_dataset,
        formatting_func=lambda data: f"Instruction: {data['instruction']}\nResponse: {data['response']}{tokenizer.eos_token}",
        args=training_args
    )
    trainer.processing_class = tokenizer
    
    safe_print(f"🎓 Training for {EPOCHS} epochs...")
    try:
        trainer.train()
    except TypeError as e:
        if "keep_torch_compile" in str(e):
            safe_print("❌ Compatibility issue detected between transformers and accelerate versions")
            safe_print("   This is usually caused by version mismatch. Please ensure:")
            safe_print("   - accelerate >= 1.0.0")
            safe_print("   - transformers >= 4.21.0")
            safe_print(f"   Current error: {e}")
            sys.exit(1)
        else:
            raise e
    except Exception as e:
        safe_print(f"❌ Training failed with error: {e}")
        sys.exit(1)
    
    # Test
    safe_print("\n🧪 Testing quick fine-tuned model:")
    for question in TEST_QUESTIONS:
        input_text = f"Instruction: {question}\nResponse: "
        inputs = tokenizer(input_text, return_tensors="pt").to(device)
        
        with torch.no_grad():
            outputs = model.generate(**inputs, max_new_tokens=50, temperature=0.1, do_sample=True, pad_token_id=tokenizer.eos_token_id)
        
        response = tokenizer.decode(outputs[0], skip_special_tokens=True).split("Response: ")[-1].strip()
        safe_print(f"Q: {question}")
        safe_print(f"A: {response}")
        safe_print("-" * 30)
    
    safe_print("✅ Quick test completed!")

if __name__ == "__main__":
    quick_test()
