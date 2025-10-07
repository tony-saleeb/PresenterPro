#!/usr/bin/env python3
"""
Ultra-simple test to verify mouse movement works
This will definitely show movement on screen
"""

import pyautogui
import time

def test_mouse_movement():
    """Test basic mouse movement"""
    print("🧪 Testing mouse movement...")
    print("=" * 40)
    
    # Get screen size
    screen_width, screen_height = pyautogui.size()
    print(f"Screen size: {screen_width}x{screen_height}")
    
    print("\n🔴 Moving mouse cursor around the screen...")
    print("You should see the mouse cursor moving!")
    print("Press Ctrl+C to stop")
    
    try:
        # Test positions
        positions = [
            (screen_width // 4, screen_height // 4, "Top-left"),
            (3 * screen_width // 4, screen_height // 4, "Top-right"),
            (screen_width // 2, screen_height // 2, "Center"),
            (screen_width // 4, 3 * screen_height // 4, "Bottom-left"),
            (3 * screen_width // 4, 3 * screen_height // 4, "Bottom-right"),
        ]
        
        while True:
            for x, y, description in positions:
                print(f"📍 Moving to {description}: ({x}, {y})")
                pyautogui.moveTo(x, y, duration=0.5)
                time.sleep(1)
                
    except KeyboardInterrupt:
        print("\n🛑 Test stopped by user")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_mouse_movement()
