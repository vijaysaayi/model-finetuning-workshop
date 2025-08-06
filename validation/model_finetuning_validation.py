#!/usr/bin/env python3
"""
Model Fine-tuning Validation Script
===================================

This script validates the fine-tuning process for creating a custom AI assistant for Axiomcart.
It loads a base model, fine-tunes it with custom data, and compares the performance.

Key Features:
- Uses Qwen2-0.5B as the base model
- Fine-tunes with LoRA (Low-Rank Adaptation) for efficiency
- Tests both base and fine-tuned models
- Reduced epochs for faster execution

Usage:
    python model_finetuning_validation.py
"""

import torch
import random
import warnings
import os
from datasets import Dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments
from trl import SFTTrainer
from peft import LoraConfig, get_peft_model

def safe_print(text):
    """Print text with fallback for encoding issues on Windows."""
    try:
        print(text)
    except UnicodeEncodeError:
        # Remove emojis and special characters for Windows compatibility
        import re
        clean_text = re.sub(r'[^\x00-\x7F]+', '', text)
        print(clean_text)

# Configuration
BASE_MODEL_NAME = "Qwen/Qwen2-0.5B"
OUTPUT_DIR = "./validation_output"
REDUCED_EPOCHS = 10  # Reduced from 40 to 10 for faster execution

# Setup
os.environ["HF_HUB_ENABLE_HF_TRANSFER"] = "1"
device = torch.device("cpu")

# Suppress warnings for cleaner output
warnings.filterwarnings("ignore")
warnings.filterwarnings("ignore", category=UserWarning, module="tqdm")
warnings.filterwarnings("ignore", message=".*IProgress not found.*")
warnings.filterwarnings("ignore", message=".*Trainer.tokenizer is now deprecated.*")

# Axiomcart Knowledge Base
KNOWLEDGE_BASE = """
    **COMPANY KNOWLEDGE BASE:**

    **Account Management:**
    - Account Creation: Customers can create accounts by navigating to our comprehensive sign-up page where they will need to carefully fill in all their personal details including their full name, valid email address, and a secure password that meets our security requirements. After completing the registration form and submitting all required information, customers must verify their email address by clicking the verification link sent to their email inbox to fully activate their account and gain access to all platform features.

    **Payment Methods:**
    - Accepted payments: Axiomcart proudly accepts a wide variety of payment methods to ensure maximum convenience for our valued customers, including all major credit cards such as Visa, MasterCard, and American Express, as well as popular digital payment solutions like PayPal, and traditional bank transfer options for those who prefer direct banking transactions.

    **Order Management:**
    - Order Tracking: Once your order has been carefully processed by our fulfillment team and handed over to our trusted shipping partners, you will automatically receive a detailed tracking number via email notification. This tracking number can be used to monitor your package's journey in real-time either through our comprehensive order tracking system on our website or by visiting the carrier's official tracking portal for the most up-to-date delivery information.
    - Order Changes/Cancellations: Customers have the flexibility to cancel or modify their orders within a 24-hour window from the time of initial placement, provided that the order has not yet been processed by our fulfillment center and moved to the shipping preparation stage. Once an order has entered the processing phase, customers will need to contact our dedicated customer service team who will do their best to accommodate any changes or cancellation requests.

    **Returns & Exchanges:**
    - Return Policy: Axiomcart maintains a customer-friendly 30-day return policy that allows customers to return items that are in their original, unused condition with all original tags and packaging intact. To initiate a return, customers must first contact our customer service team to obtain proper return authorization and receive detailed instructions on the return process.

    **Security & Privacy:**
    - Data Protection: At Axiomcart, we take your privacy and data security extremely seriously. We employ industry-standard encryption technologies and robust security protocols to safeguard all personal information provided by our customers. We maintain strict policies regarding data sharing and absolutely do not share, sell, or distribute customer data to any third parties without explicit customer consent, except where required by law.

    **Shipping:**
    - International Shipping: Axiomcart is proud to offer comprehensive international shipping services to customers in over 50 countries worldwide. Please note that shipping rates, delivery timeframes, and available shipping options may vary significantly depending on your specific geographic location, local customs requirements, and the size and weight of your order.

    **Customer Support:**
    - Contact Methods: Our dedicated customer support team is available to assist you through multiple convenient channels including direct email communication at support@axiomcart.com, or through our real-time live chat feature readily accessible on our website for immediate assistance.
    - Issue Resolution: If you encounter any problems or concerns regarding your order, please don't hesitate to contact our customer service team with your complete order number and a detailed description of the issue you're experiencing. Our trained representatives will work diligently to investigate and resolve your concern promptly.

    **Promotions:**
    - First-time Customer Discount: As a special welcome offer for new customers joining the Axiomcart family, we are pleased to provide an exclusive 10% discount on your very first purchase. Simply use the promotional code 'FIRST10' during checkout to take advantage of this limited-time offer.
"""

# Test Questions
TEST_QUESTIONS = [
    "What email address should I use to contact support?",
    "Can I use credit card for payment and store it?",
    "How many days do I have to return an item I don't want?",
    "Is there a discount for new customers?"
]

def load_model_and_tokenizer(model_name, device):
    """
    Load model and tokenizer from Hugging Face Hub.
    
    Args:
        model_name (str): The name/path of the model to load
        device (torch.device): The device to load the model on (CPU/GPU)
        
    Returns:
        tuple: (tokenizer, model) - The loaded tokenizer and model
    """
    safe_print(f"🚀 Loading model: {model_name}")
    
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(model_name, device_map="auto").to(device)
    
    safe_print(f"✅ Model loaded successfully!")
    safe_print(f"📊 Model parameters: {model.num_parameters():,}")
    safe_print()
    
    return tokenizer, model

def test_model_responses(model, tokenizer, test_questions, model_name="Model"):
    """
    Test a model with a list of questions and print the responses.
    
    Args:
        model: The language model to test
        tokenizer: The tokenizer associated with the model
        test_questions: List of questions to ask the model
        model_name: Name to display for the model (for identification)
    """
    safe_print(f"🧪 TESTING {model_name.upper()}")
    safe_print("=" * 80)
    
    for i, question in enumerate(test_questions, 1):
        input_text = f"""                    
                        SystemPrompt: 
                            You are a helpful and professional customer service AI assistant for Axiomcart, an e-commerce platform. 
                            Your role is to provide comprehensive, detailed, and thorough responses to customer inquiries based on the company's policies and procedures. 
                            You are very spontaneous and humorous, always maintaining a friendly and professional tone. 
                            You provide concise and accurate answers, ensuring that customers feel valued and understood.

                            {KNOWLEDGE_BASE}

                        UserQuery:
                            {question}

                        Response:
                      """
        
        # Convert text to model tokens and move to device
        inputs = tokenizer(input_text, return_tensors="pt").to(device)

        # Generate response without computing gradients (inference mode)   
        with torch.no_grad():
            outputs = model.generate(
                **inputs, 
                temperature=0.1,
                max_new_tokens=200,
                do_sample=True,
                pad_token_id=tokenizer.eos_token_id
            )
        
        # Convert model output tokens back to text
        response = tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # Extract only the generated response part after "Response:"
        response = response.split("Response:")[-1].strip()

        safe_print(f"❓ Question {i}: {question}")
        safe_print(f"💬 Response: {response}")
        safe_print("-" * 80)

def create_training_dataset():
    """
    Create the training dataset with Axiomcart-specific FAQ data.
    
    Returns:
        tuple: (train_dataset, eval_dataset) - Training and evaluation datasets
    """
    faq_data = [
        # Account Management
        {"instruction": "How do I create an account on Axiomcart?", "response": "Creating an account is super easy! 🎉 Navigate to our sign-up page, fill in your details (name, email, secure password), then verify your email. Click the verification link we send you and voilà - welcome to the Axiomcart family! 🚀"},
        
        {"instruction": "I forgot my password, how can I reset it?", "response": "Happens to the best of us! 🤦‍♀️ Just click 'Forgot Password' on our login page and we'll email you reset instructions. Follow the link to create a new secure password - maybe avoid 'password123' this time! 😉🔐"},
        
        # Payment Methods
        {"instruction": "What payment methods does Axiomcart accept?", "response": "We're the Swiss Army knife of payments! 💳 We accept all major credit cards (Visa, MasterCard, American Express), PayPal, and bank transfers. Basically, we've got more payment options than a food court has restaurants! 🍕💰"},
        
        {"instruction": "Is it safe to save my credit card information?", "response": "Absolutely! Your payment info is locked up tighter than Fort Knox! 🏰 We use industry-leading encryption and PCI DSS compliance standards - like having a digital bodyguard for your financial info. We take security more seriously than a sommelier takes wine! 🍷🛡️"},
        
        # Order Management
        {"instruction": "How can I track my order?", "response": "The eternal 'where's my stuff?' question! 📦 Once processed, you'll get a tracking number via email automatically. Use it on our website or the carrier's portal to follow your package's journey - it's like GPS for goodies! 🗺️✨"},
        
        {"instruction": "How long does shipping usually take?", "response": "We're faster than your morning coffee delivery! ⏰ Domestic orders: 3-5 days standard, 1-2 days express. International shipping takes 7-14 days depending on location and customs - time for your package to collect passport stamps! 🌍✈️"},
        
        {"instruction": "Can I change or cancel my order after placing it?", "response": "Changed your mind? We totally get it! 🎭 You have 24 hours to modify or cancel, unless it's already processing. After that, contact our customer service team - we're basically order-modification wizards! 🪄⚡"},
        
        # Returns & Refunds
        {"instruction": "What is your return policy?", "response": "Got buyer's remorse? It happens! 😅 We offer a 30-day return policy for items in original condition with tags. Contact customer service for return authorization and step-by-step instructions - we won't judge your shopping decisions! 🛍️💭"},
        
        {"instruction": "How do I return a defective item?", "response": "A defective item is totally unacceptable! 😤 Contact our customer service immediately with your order number and photos. We'll arrange free return shipping and send a replacement or refund - defective items get VIP treatment! 📦✨"},
        
        # Customer Support
        {"instruction": "How can I contact customer support?", "response": "We're easier to reach than your favorite pizza place! 📞🍕 Email us at support@axiomcart.com or use our live chat on the website. We're standing by like customer service superheroes, coffee in hand, ready to help! ☕🦸‍♀️"},
        
        {"instruction": "What are your customer service hours?", "response": "We're practically nocturnal! 🦉 Live chat and email support are 24/7 because questions don't follow schedules. Phone support: Monday-Friday 8 AM-8 PM EST, weekends 10 AM-6 PM EST. We're here more than your favorite coffee shop! ☕⏰"},
        
        # Shipping & International
        {"instruction": "Does Axiomcart ship internationally?", "response": "Around the world in 50+ countries! 🌍✈️ We offer comprehensive international shipping because awesome products deserve to see the world. Rates and timeframes vary by location - we haven't figured out teleportation yet! 🚀📦"},
        
        {"instruction": "Do I have to pay customs fees for international orders?", "response": "Ah, the customs question! 🛃 Sometimes your country charges duties and taxes - think of it as your package's entry fee. These fees are determined by your local customs authority and are the customer's responsibility - international shopping's adventure tax! 🌍💰"},
        
        # Promotions & Discounts
        {"instruction": "Are there any discounts for first-time customers?", "response": "Welcome to the party! 🎉 New customers get an exclusive 10% discount on their first purchase. Just use code 'FIRST10' at checkout - it's like a secret handshake for savings! 💰✨"},
        
        {"instruction": "Do you have a loyalty program?", "response": "You bet! 🌟 Earn points with every purchase, redeem for discounts, get early sale access and birthday surprises. The more you shop, the more perks you unlock - like leveling up in a game with useful rewards! 🎮🎁"},
        
        # Security & Privacy
        {"instruction": "How secure is my personal information on Axiomcart?", "response": "Your data is more secure than the Crown Jewels! 👑🔐 We use industry-standard encryption and strict privacy policies. We don't share, sell, or distribute your data to third parties without consent - your secrets are safe with us! 🤝✨"},
        
        # Product & Inventory
        {"instruction": "How do I know if an item is in stock?", "response": "Our inventory updates faster than small-town gossip! 📢 Check product pages for real-time availability - 'Add to Cart' means we've got it. Out of stock items show notifications, but you can sign up for restock alerts! 📦✅"}
    ]

    # Create balanced train/test split
    random.seed(42)
    all_data = faq_data.copy()
    random.shuffle(all_data)

    # Split: 80% training, 20% evaluation
    train_size = int(len(all_data) * 0.8)
    train_data = all_data[:train_size]
    eval_data = all_data[train_size:]

    train_dataset = Dataset.from_list(train_data)
    eval_dataset = Dataset.from_list(eval_data)

    safe_print(f"📚 Dataset Statistics:")
    safe_print(f"- Training examples: {len(train_dataset)}")
    safe_print(f"- Evaluation examples: {len(eval_dataset)}")
    safe_print(f"- Total examples: {len(train_dataset) + len(eval_dataset)}")
    safe_print()

    return train_dataset, eval_dataset

def setup_lora_config():
    """
    Set up LoRA configuration for efficient fine-tuning.
    
    Returns:
        LoraConfig: Configured LoRA parameters
    """
    peft_config = LoraConfig(
        r=16,
        lora_alpha=32,
        lora_dropout=0.1,
        bias="none",
        task_type="CAUSAL_LM",
        modules_to_save=["lm_head", "embed_token"],
    )

    safe_print(f"🔧 LoRA Configuration:")
    safe_print(f"- Rank (r): {peft_config.r}")
    safe_print(f"- Alpha: {peft_config.lora_alpha}")
    safe_print(f"- Dropout: {peft_config.lora_dropout}")
    safe_print()

    return peft_config

def setup_training_args():
    """
    Set up training arguments for the fine-tuning process.
    
    Returns:
        TrainingArguments: Configured training parameters
    """
    training_args = TrainingArguments(
        output_dir=OUTPUT_DIR,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        num_train_epochs=REDUCED_EPOCHS,  # Reduced for faster execution
        learning_rate=0.0001,
        fp16=False,
        save_steps=2,
        logging_steps=3,
        remove_unused_columns=False,
        eval_strategy="epoch",
    )

    safe_print(f"⚙️ Training Configuration:")
    safe_print(f"- Epochs: {training_args.num_train_epochs} (reduced for validation)")
    safe_print(f"- Batch size: {training_args.per_device_train_batch_size}")
    safe_print(f"- Learning rate: {training_args.learning_rate}")
    safe_print(f"- Gradient accumulation steps: {training_args.gradient_accumulation_steps}")
    safe_print()

    return training_args

def formatting_func(data, tokenizer):
    """
    Format data for SFTTrainer.
    
    Args:
        data: Training data point
        tokenizer: Model tokenizer
        
    Returns:
        str: Formatted training string
    """
    return f"Instruction: {data['instruction']}\nResponse: {data['response']}{tokenizer.eos_token}"

def main():
    """
    Main function to execute the fine-tuning validation process.
    """
    safe_print("🎯 Model Fine-tuning Validation Script")
    safe_print("=" * 60)
    safe_print(f"📱 Using device: {device}")
    safe_print(f"🔢 Reduced epochs: {REDUCED_EPOCHS} (for faster validation)")
    safe_print()

    # Step 1: Load base model and tokenizer
    safe_print("📥 STEP 1: Loading base model and tokenizer")
    tokenizer, base_model = load_model_and_tokenizer(BASE_MODEL_NAME, device)

    # Step 2: Test base model performance
    safe_print("🧪 STEP 2: Testing base model performance")
    test_model_responses(base_model, tokenizer, TEST_QUESTIONS, "Base Model")
    safe_print()

    # Step 3: Prepare training data
    safe_print("📊 STEP 3: Preparing training dataset")
    train_dataset, eval_dataset = create_training_dataset()

    # Step 4: Set up LoRA configuration
    safe_print("🛠️ STEP 4: Setting up LoRA configuration")
    peft_config = setup_lora_config()
    model = get_peft_model(base_model, peft_config)
    model.print_trainable_parameters()
    safe_print()

    # Step 5: Configure training arguments
    safe_print("⚙️ STEP 5: Configuring training arguments")
    training_args = setup_training_args()

    # Step 6: Initialize trainer
    safe_print("🎓 STEP 6: Initializing trainer")
    trainer = SFTTrainer(
        model=model,
        train_dataset=train_dataset,
        eval_dataset=eval_dataset,
        formatting_func=lambda data: formatting_func(data, tokenizer),
        args=training_args
    )
    trainer.processing_class = tokenizer
    safe_print("✅ Trainer initialized successfully!")
    safe_print()

    # Step 7: Start training
    safe_print("🚀 STEP 7: Starting fine-tuning process")
    safe_print(f"⏱️ Training will run for {REDUCED_EPOCHS} epochs (reduced for validation)")
    safe_print("This may take several minutes depending on your hardware...")
    safe_print()
    
    trainer.train()
    safe_print("✅ Training completed!")
    safe_print()

    # Step 8: Save the fine-tuned model
    safe_print("💾 STEP 8: Saving fine-tuned model")
    model_save_path = f"{OUTPUT_DIR}/fine-tuned-qwen-0.5b"
    trainer.save_model(model_save_path)
    safe_print(f"✅ Model saved to: {model_save_path}")
    safe_print()

    # Step 9: Test fine-tuned model
    safe_print("🎯 STEP 9: Testing fine-tuned model performance")
    fine_tuned_model = AutoModelForCausalLM.from_pretrained(model_save_path).to(device)
    test_model_responses(fine_tuned_model, tokenizer, TEST_QUESTIONS, "Fine-tuned Model")
    safe_print()

    # Summary
    safe_print("🎉 VALIDATION COMPLETED SUCCESSFULLY!")
    safe_print("=" * 60)
    safe_print("✅ Summary of completed steps:")
    safe_print("   1. Loaded base model (Qwen2-0.5B)")
    safe_print("   2. Tested base model performance")
    safe_print("   3. Prepared Axiomcart training dataset")
    safe_print("   4. Configured LoRA for efficient fine-tuning")
    safe_print(f"   5. Fine-tuned model for {REDUCED_EPOCHS} epochs")
    safe_print("   6. Saved fine-tuned model")
    safe_print("   7. Compared base vs fine-tuned performance")
    safe_print()
    safe_print("🔍 Next steps:")
    safe_print("   - Compare responses between base and fine-tuned models")
    safe_print("   - Experiment with different LoRA configurations")
    safe_print("   - Try different epoch numbers for optimal results")
    safe_print("   - Explore Azure AI Foundry for production deployments")

if __name__ == "__main__":
    main()
