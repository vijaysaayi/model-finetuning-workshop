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
from datasets import Dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments
from trl import SFTTrainer
from peft import LoraConfig, get_peft_model

# Quick test configuration
BASE_MODEL_NAME = "Qwen/Qwen2-0.5B"
OUTPUT_DIR = "./quick_test_output"
EPOCHS = 3  # Very minimal for quick testing

# Setup
os.environ["HF_HUB_ENABLE_HF_TRANSFER"] = "1"
device = torch.device("cpu")
warnings.filterwarnings("ignore")

# Minimal test questions
TEST_QUESTIONS = [
    "What email address should I use to contact support?",
    "Is there a discount for new customers?"
]

def safe_print(text):
    """Print text with fallback for encoding issues."""
    try:
        print(text)
    except UnicodeEncodeError:
        # Remove emojis and special characters for Windows compatibility
        import re
        clean_text = re.sub(r'[^\x00-\x7F]+', '', text)
        print(clean_text)

def quick_test():
    """Run a quick validation test."""
    safe_print("🚀 Quick Fine-tuning Validation Test")
    safe_print("=" * 50)
    
    # Load model
    safe_print("📥 Loading model...")
    tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL_NAME)
    model = AutoModelForCausalLM.from_pretrained(BASE_MODEL_NAME, device_map="auto").to(device)
    
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
    trainer.train()
    
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
