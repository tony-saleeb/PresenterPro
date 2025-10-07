# Laser Pointer Test Guide

## Step 1: Test Basic Mouse Movement

First, let's verify that mouse movement works at all:

```bash
cd python_server
python test_mouse_movement.py
```

**Expected Result**: You should see the mouse cursor moving around the screen in a pattern.

## Step 2: Test PowerPoint Laser Pointer

1. **Open PowerPoint**
2. **Start a presentation** (F5)
3. **Press Ctrl+L** to enable laser pointer mode
4. **Move your mouse** - you should see a red laser dot following your cursor

**Expected Result**: Red laser dot appears and follows mouse movement.

## Step 3: Test Simple Server

```bash
cd python_server
python simple_laser_pointer.py
```

**Expected Result**: Server starts and shows "Server started!" message.

## Step 4: Test Flutter App

1. **Make sure simple server is running** (Step 3)
2. **Open Flutter app**
3. **Connect to localhost:8765**
4. **Start presentation** in PowerPoint
5. **Tap "Start" in Flutter app**
6. **You should see "LASER POINTER TEST" section**
7. **Tap "TOGGLE LASER"** - should enable laser in PowerPoint
8. **Tap position buttons** (TOP-LEFT, CENTER, etc.) - laser should move

**Expected Result**: 
- Server logs show commands received
- PowerPoint laser dot moves to positions
- Flutter app shows test buttons

## Troubleshooting

### If Step 1 fails:
- Check if pyautogui is installed: `pip install pyautogui`
- Try running as administrator

### If Step 2 fails:
- Make sure PowerPoint is in presentation mode (F5)
- Try different PowerPoint versions
- Check if Ctrl+L works manually

### If Step 3 fails:
- Check if websockets is installed: `pip install websockets`
- Try different port if 8765 is busy

### If Step 4 fails:
- Check server logs for received commands
- Verify Flutter app is connected
- Check PowerPoint is in presentation mode

## What to Report

Please tell me:
1. Which step fails?
2. What error messages do you see?
3. What happens in PowerPoint when you press Ctrl+L?
4. Do you see any commands in the server logs?
