#!/usr/bin/env python3
"""
Test script to verify Unicode/emoji handling across different platforms.
This script should run successfully on both Windows and Linux CI environments.
"""

def safe_print(text):
    """Print text with fallback for encoding issues."""
    try:
        print(text)
    except UnicodeEncodeError:
        # Remove emojis and special characters for Windows compatibility
        import re
        clean_text = re.sub(r'[^\x00-\x7F]+', '', text)
        print(clean_text)

def test_unicode_handling():
    """Test various Unicode characters and emojis."""
    test_messages = [
        "🚀 Rocket emoji test",
        "📥 Download emoji test",
        "✅ Check mark emoji test", 
        "🧪 Test tube emoji test",
        "💬 Speech bubble emoji test",
        "❓ Question mark emoji test",
        "🎯 Target emoji test",
        "📊 Chart emoji test",
        "🔧 Wrench emoji test",
        "Regular ASCII text should always work"
    ]
    
    safe_print("Testing Unicode/Emoji Handling")
    safe_print("=" * 40)
    
    for i, message in enumerate(test_messages, 1):
        safe_print(f"{i:2d}. {message}")
    
    safe_print("-" * 40)
    safe_print("✅ All tests completed!")
    
    # Test system encoding info
    import sys
    safe_print(f"\nSystem Info:")
    safe_print(f"Platform: {sys.platform}")
    safe_print(f"Python version: {sys.version}")
    safe_print(f"Default encoding: {sys.getdefaultencoding()}")
    safe_print(f"File system encoding: {sys.getfilesystemencoding()}")
    
    # Test environment variables
    import os
    safe_print(f"PYTHONIOENCODING: {os.environ.get('PYTHONIOENCODING', 'Not set')}")
    safe_print(f"PYTHONUTF8: {os.environ.get('PYTHONUTF8', 'Not set')}")

if __name__ == "__main__":
    test_unicode_handling()
