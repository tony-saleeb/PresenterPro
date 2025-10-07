#!/usr/bin/env python3
"""
Simple test script for the laser pointer functionality
Run this to test if the laser pointer is working correctly
"""

import pyautogui
import time
import sys

def test_laser_pointer():
    """Test the laser pointer by moving the mouse cursor around"""
    print("🧪 Testing Laser Pointer...")
    print("=" * 50)
    
    # Get screen dimensions
    screen_width, screen_height = pyautogui.size()
    print(f"Screen size: {screen_width}x{screen_height}")
    
    # Test positions (as percentages)
    test_positions = [
        (25, 25, "Top-left"),
        (75, 25, "Top-right"), 
        (50, 50, "Center"),
        (25, 75, "Bottom-left"),
        (75, 75, "Bottom-right"),
    ]
    
    print("\n🔴 Moving laser pointer to test positions...")
    print("Make sure PowerPoint is open and in presentation mode (F5)")
    print("Press Ctrl+L to enable laser pointer mode")
    print("\nPress Enter to start test, or Ctrl+C to cancel...")
    input()
    
    try:
        # Enable PowerPoint laser pointer mode
        print("🔴 Enabling PowerPoint laser pointer mode...")
        pyautogui.hotkey('ctrl', 'l')
        time.sleep(1)
        
        for x_percent, y_percent, description in test_positions:
            # Convert percentages to actual coordinates
            x = int((x_percent / 100.0) * screen_width)
            y = int((y_percent / 100.0) * screen_height)
            
            print(f"📍 Moving to {description}: {x_percent}%, {y_percent}% ({x}, {y})")
            
            # Move mouse cursor to position
            pyautogui.moveTo(x, y, duration=0.0)  # Instant movement
            
            # Wait a bit to see the movement
            time.sleep(1)
        
        print("\n✅ Laser pointer test completed!")
        print("You should have seen the red laser dot move around the screen.")
        
        # Disable laser pointer mode
        print("🔴 Disabling laser pointer mode...")
        pyautogui.hotkey('ctrl', 'l')
        
    except KeyboardInterrupt:
        print("\n🛑 Test cancelled by user")
        # Make sure to disable laser pointer mode
        pyautogui.hotkey('ctrl', 'l')
    except Exception as e:
        print(f"❌ Error during test: {e}")
        # Make sure to disable laser pointer mode
        pyautogui.hotkey('ctrl', 'l')

if __name__ == "__main__":
    test_laser_pointer()
