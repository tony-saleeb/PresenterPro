# 🔍 TESTING LIVE STREAMING

## ⚠️ CRITICAL: You Must Start Presentation Mode!

The live streaming **only starts when you press F5** to start the presentation!

---

## 📋 **Step-by-Step Test:**

### **Step 1: Start Server**
```bash
python python_server/slide_controller_server.py
```

**Check console for:**
```
🎥 LIVE STREAMING Slide Capture Extension initialized
```

---

### **Step 2: Connect Phone**
1. Open PresenterPro app
2. Enter server IP
3. Connect

**Check console for:**
```
New client connected: ...
```

---

### **Step 3: Start Presentation (CRITICAL!)**

**On PC:**
1. Open PowerPoint presentation
2. **Press F5** to start slideshow

**OR from phone:**
1. Tap the "Start Presentation" button

**Check console for:**
```
🎬 SLIDESHOW STARTED - Starting LIVE STREAMING
🎥 LIVE STREAMING ACTIVE - Phone will show real-time PC screen
🎥 LIVE STREAMING STARTED - Capturing every 300ms (3.3 fps)
```

---

### **Step 4: Check Phone**
- Phone should start showing slides
- Updates every 300ms
- Should see console messages every 300ms:
```
⚡ Broadcast to 1 clients (forced=True)
```

---

### **Step 5: Navigate**
1. Swipe right/left on phone
2. Watch phone update within 300ms
3. Check sync with PC

---

## ❌ **Common Issues:**

### **Issue 1: Streaming Not Starting**
**Symptom:** No "LIVE STREAMING STARTED" message

**Cause:** Presentation mode not activated

**Solution:** 
- Press F5 on PC to start presentation
- OR tap "Start Presentation" button on phone

---

### **Issue 2: No Updates**
**Symptom:** Phone shows old slide, no updates

**Cause:** Streaming not active

**Solution:**
1. Check if presentation is running (F5)
2. Check console for streaming messages
3. Restart server if needed

---

### **Issue 3: Still Using Old Code**
**Symptom:** No streaming messages at all

**Cause:** Running old server code

**Solution:**
1. Stop server (Ctrl+C)
2. Restart: `python python_server/slide_controller_server.py`
3. Check for "LIVE STREAMING" in startup message

---

## ✅ **Expected Console Output:**

### **When Starting Presentation:**
```
🎯 START PRESENTATION command received
📡 Sending F5 key...
✅ F5 key sent successfully
🎮 Presentation mode activated - RESET to slide 1
⚡ SLIDESHOW STARTED - Broadcasting first slide to 1 clients
🎬 SLIDESHOW STARTED - Starting LIVE STREAMING
🎥 LIVE STREAMING ACTIVE - Phone will show real-time PC screen
```

### **During Streaming:**
```
⚡ Broadcast to 1 clients (forced=True)
⚡ Broadcast to 1 clients (forced=True)
⚡ Broadcast to 1 clients (forced=True)
... (every 300ms)
```

### **When Stopping:**
```
🛑 SLIDESHOW ENDED - Stopping live streaming
🛑 LIVE STREAMING STOPPED
```

---

## 🎯 **Quick Test:**

1. **Start server** → See "LIVE STREAMING" in init
2. **Connect phone** → See "New client connected"
3. **Press F5** → See "LIVE STREAMING STARTED"
4. **Watch console** → See broadcasts every 300ms
5. **Check phone** → Should update continuously

---

## 💡 **The Key:**

**Live streaming ONLY works when:**
- ✅ Server is running with new code
- ✅ Phone is connected
- ✅ **Presentation mode is active (F5 pressed)**

**If presentation mode is NOT active:**
- ❌ No streaming
- ❌ No updates
- ❌ Phone shows old slides

---

**Try it now: Restart server, connect phone, PRESS F5, and watch the console!**
