# Debug Touch-Based Laser Pointer

## Issue: Touch events not working

The touch-based laser pointer isn't working. Let's debug this step by step.

## Step 1: Check Flutter Console

**Run the Flutter app and check the console output:**

1. **Enable pointer mode** (tap the red button)
2. **Touch the slide** 
3. **Look for these messages in Flutter console:**
   ```
   🎯 Touch detected at: Offset(x, y)
   🎯 Local position: Offset(x, y), Slide size: Size(width, height)
   🎯 Sending laser pointer to: X.X%, Y.Y%
   🎯 BLoC: MovePointer event received - X: X.X%, Y: Y.Y%
   🎯 BLoC: isGyroscopePointerActive: false, isPresenting: true
   🎯 BLoC: isPointerMode: true, connectionStatus: connected
   🎯 BLoC: Sending message to server: {command: laser_pointer_move, params: {x_percent: X.X, y_percent: Y.Y}}
   ```

**If you DON'T see these messages:**
- Touch events aren't being detected
- Check if pointer mode is actually enabled
- Check if you're touching the slide area (not outside)

## Step 2: Check Server Logs

**Look for these messages in the server console:**

```
📱 Received message from ('IP', port): {'command': 'laser_pointer_move', 'params': {'x_percent': X.X, 'y_percent': Y.Y}}
🎯 Processing command: laser_pointer_move with params: {'x_percent': X.X, 'y_percent': Y.Y}
🎯 Server: Received laser_pointer_move command - X: X.X%, Y: X.X%
🎯 Server: Enabling laser pointer visibility
🔴 Laser pointer shown (PowerPoint mode)
🔴 Laser pointer moved to X.X%, Y.Y%
🎯 Command response: {'status': 'success', 'command': 'laser_pointer_move'}
```

**If you DON'T see these messages:**
- Flutter app isn't sending messages to server
- WebSocket connection might be broken
- Check server connection status

## Step 3: Test Server Directly

**Run the test script to verify server works:**

```bash
cd python_server
python test_touch_pointer.py
```

**Expected output:**
```
Connecting to ws://localhost:8080
Connected to server!
Welcome message: {"type": "welcome", "message": "Connected to Slide Controller Server"}
Testing laser pointer at 25%, 25%
Response: {"status": "success", "command": "laser_pointer_move"}
Testing laser pointer at 75%, 25%
Response: {"status": "success", "command": "laser_pointer_move"}
...
Test completed!
```

**If this fails:**
- Server isn't running
- Server has issues with laser pointer
- PowerPoint isn't in presentation mode

## Step 4: Check PowerPoint

**Make sure PowerPoint is set up correctly:**

1. **Open PowerPoint**
2. **Start presentation** (F5)
3. **Make sure PowerPoint window is active/focused**
4. **Try pressing Ctrl+L manually** - should show/hide laser pointer
5. **Try moving mouse** - should show red laser dot

**If PowerPoint laser doesn't work:**
- PowerPoint isn't in presentation mode
- PowerPoint window isn't focused
- PowerPoint version doesn't support laser pointer

## Step 5: Common Issues

### Issue 1: Touch events not detected
**Symptoms:** No Flutter console messages
**Solutions:**
- Make sure pointer mode is enabled (button is red)
- Touch the slide area, not outside
- Check if slide preview is visible

### Issue 2: Messages not sent to server
**Symptoms:** Flutter messages but no server messages
**Solutions:**
- Check WebSocket connection status
- Restart server
- Check network connectivity

### Issue 3: Server receives but laser doesn't move
**Symptoms:** Server messages but no laser movement
**Solutions:**
- Make sure PowerPoint is in presentation mode (F5)
- Make sure PowerPoint window is focused
- Try pressing Ctrl+L manually in PowerPoint

### Issue 4: Laser appears but doesn't move
**Symptoms:** Laser appears but stays in one place
**Solutions:**
- Check if pyautogui is working
- Try the test script
- Check if mouse cursor is moving

## Step 6: Report Results

**Please tell me:**

1. **Flutter console messages** (copy/paste the 🎯 messages)
2. **Server console messages** (copy/paste the 📱 and 🎯 messages)
3. **Test script results** (did it work?)
4. **PowerPoint behavior** (does Ctrl+L work manually?)
5. **What exactly happens** when you touch the slide

This will help me identify exactly where the problem is!
