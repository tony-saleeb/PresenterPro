# 🎨 PresenterPro Server GUI

A beautiful, modern GUI application for running the PresenterPro server with QR code scanning support.

---

## ✨ Features

### 🎯 **Beautiful Modern UI**
- Dark mode interface with gradient accents
- Professional design with CustomTkinter
- Smooth animations and transitions
- Clean, intuitive layout

### 📱 **QR Code Scanner**
- Auto-generated QR code for your server IP
- Scan with your phone to instantly connect
- No need to type IP addresses manually
- Blue-colored QR code matching app theme

### 🌐 **Smart IP Detection**
- Automatically detects your local IP address
- Works on WiFi, Ethernet, and hotspot
- One-click copy to clipboard
- Large, easy-to-read display

### 🚀 **Easy Server Control**
- Start/Stop server with one click
- Real-time status indicators
- Visual feedback for all actions
- Clean shutdown handling

---

## 📦 Installation

### Option 1: Use the Pre-built .exe (Easiest)
1. Download `PresenterPro Server.exe`
2. Double-click to run
3. That's it! No installation needed.

### Option 2: Run from Source
1. Install Python 3.10 or later
2. Install dependencies:
   ```bash
   pip install -r requirements_gui.txt
   ```
3. Run the GUI:
   ```bash
   python server_gui.py
   ```

### Option 3: Build Your Own .exe
1. Install dependencies:
   ```bash
   pip install -r requirements_gui.txt
   ```
2. Build the executable:
   ```bash
   python build_exe.py
   ```
3. Find the .exe in the `dist` folder

---

## 🎮 How to Use

### Step 1: Start the Server
1. **Open the application** - Double-click `PresenterPro Server.exe`
2. **Check your IP** - The server IP is displayed in the center
3. **Click "Start Server"** - Green button at the bottom
4. **Wait for confirmation** - You'll see "Server is running" message

### Step 2: Connect Your Phone

#### Method A: Scan QR Code (Recommended)
1. Open PresenterPro app on your phone
2. Tap the QR scanner button
3. Scan the QR code displayed in the GUI
4. **Auto-connect!** - No typing needed!

#### Method B: Manual IP Entry
1. Click "Copy IP Address" in the GUI
2. Open PresenterPro app on your phone
3. Paste the IP address
4. Tap "Connect to PC"

### Step 3: Start Presenting
1. Open your PowerPoint presentation
2. Control slides from your phone
3. Use touch laser pointer for precision
4. Enjoy zero-latency control!

---

## 🎨 GUI Overview

### Main Window (600x800)

```
┌─────────────────────────────────────────┐
│                                         │
│  🎬 PresenterPro Server                 │
│  Professional PowerPoint Control        │
│                                         │
├─────────────────────────────────────────┤
│  🔴 Server Status                       │
│  ⚫ Server is stopped                   │
├─────────────────────────────────────────┤
│  🌐 Server IP Address                   │
│  ┌───────────────────────────────────┐ │
│  │     192.168.1.100                 │ │
│  └───────────────────────────────────┘ │
│  📋 Copy IP Address                    │
├─────────────────────────────────────────┤
│  📱 Scan to Connect                     │
│                                         │
│        [  QR CODE HERE  ]              │
│                                         │
│  Open PresenterPro app and scan        │
├─────────────────────────────────────────┤
│  ▶️  Start Server                       │
└─────────────────────────────────────────┘
```

### When Server is Running

```
┌─────────────────────────────────────────┐
│  🟢 Server Status                       │
│  🟢 Server is running                   │
│  ...                                    │
│  ⏹️  Stop Server                        │
└─────────────────────────────────────────┘
```

---

## 🎨 Design Features

### Color Scheme
- **Background**: Dark slate (#0F172A, #1E293B)
- **Primary**: Blue (#3B82F6)
- **Success**: Green (#10B981)
- **Error**: Red (#EF4444)
- **Text**: White (#FFFFFF) with slate accents (#94A3B8)

### Typography
- **Headers**: Bold, 18-28pt
- **IP Address**: Consolas, 32pt, Bold
- **Body**: Regular, 13-16pt

### Components
- **Rounded corners**: 12-20px radius
- **Card-based layout**: Separated sections
- **Icon-led design**: Emoji icons for clarity
- **Large touch targets**: 40-60px buttons

---

## 🔧 Technical Details

### Dependencies
- **customtkinter**: Modern UI framework
- **qrcode**: QR code generation
- **Pillow**: Image processing
- **websockets**: WebSocket server
- **pyautogui**: Keyboard/mouse control
- **mss**: Screen capture

### Architecture
```
server_gui.py
    ├── GUI (CustomTkinter)
    ├── QR Code Generator (qrcode)
    ├── IP Detection (socket)
    └── Server Manager (threading)
         └── slide_controller_server.py
              ├── WebSocket Server (websockets)
              ├── Slide Capture (slide_capture_extension.py)
              └── Input Control (pyautogui)
```

### Threading
- **Main Thread**: GUI (tkinter main loop)
- **Server Thread**: WebSocket server (asyncio event loop)
- **Capture Thread**: Slide capture (background)

---

## 🛠️ Building the .exe

### Requirements
- Python 3.10 or later
- PyInstaller 6.3.0 or later
- All dependencies from `requirements_gui.txt`

### Build Command
```bash
python build_exe.py
```

### Build Options
The build script creates:
- **Single file**: All dependencies bundled
- **Windowed**: No console window
- **Includes**: All required modules and data files
- **Size**: ~50-80 MB (includes Python runtime)

### Output
```
dist/
└── PresenterPro Server.exe  ← Your executable!
```

---

## 📝 Tips & Tricks

### 1. **QR Code Not Scanning?**
- Make sure your phone camera has good lighting
- Hold phone steady 15-30cm from screen
- Ensure QR code is fully visible on screen

### 2. **IP Address Shows 127.0.0.1?**
- Check your network connection
- Try restarting the application
- Manually enter your correct IP if needed

### 3. **Server Won't Start?**
- Check if port 8765 is already in use
- Make sure PowerPoint is open
- Try running as administrator

### 4. **Multiple Network Adapters?**
- The app will detect the primary adapter
- You can manually check IP with `ipconfig` (Windows)
- Use the IP that matches your WiFi network

---

## 🎯 Keyboard Shortcuts

- **Ctrl+C**: Copy IP address (when window focused)
- **Alt+F4**: Close application
- **Escape**: Close QR code view (if implemented)

---

## 🌟 Features Comparison

| Feature | CLI Version | GUI Version |
|---------|-------------|-------------|
| **Ease of Use** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Visual Feedback** | ❌ | ✅ |
| **QR Code** | ❌ | ✅ |
| **IP Copy** | ❌ | ✅ |
| **Status Display** | Text only | Visual icons |
| **User-Friendly** | Technical | Everyone |

---

## 📱 Mobile App Integration

### Scanning Flow
1. User taps QR scanner button in app
2. Camera opens with scanning overlay
3. User points camera at PC QR code
4. App auto-detects and extracts IP
5. **Instant connection!** No typing needed

### Benefits
- **Zero typing**: No IP entry errors
- **Instant setup**: Connect in 2 seconds
- **User-friendly**: Works for anyone
- **Professional**: Premium experience

---

## 🚀 Future Enhancements

### Potential Features
- [ ] Custom port selection
- [ ] Multiple device connections
- [ ] Connection history
- [ ] Network diagnostics
- [ ] Auto-start with Windows
- [ ] System tray icon
- [ ] Dark/Light theme toggle
- [ ] Presentation mode countdown
- [ ] Connected devices list
- [ ] Network bandwidth monitor

---

## ❓ Troubleshooting

### GUI Won't Open
**Problem**: Double-clicking .exe does nothing  
**Solution**: Check if antivirus is blocking it, run as administrator

### QR Code Appears Blurry
**Problem**: QR code is pixelated or unclear  
**Solution**: Increase your display resolution or zoom in browser

### Connection Fails After Scan
**Problem**: Scan successful but can't connect  
**Solution**: Ensure both PC and phone are on same network

### Server Starts Then Stops
**Problem**: Server status goes green then back to red  
**Solution**: Check if another instance is running, check firewall

---

## 💻 System Requirements

### Minimum
- **OS**: Windows 10 (64-bit)
- **RAM**: 2 GB
- **CPU**: Dual-core 1.5 GHz
- **Display**: 1024x768

### Recommended
- **OS**: Windows 11 (64-bit)
- **RAM**: 4 GB
- **CPU**: Quad-core 2.0 GHz
- **Display**: 1920x1080

---

## 📄 License

Same as PresenterPro main application.

---

## 🙏 Credits

- **CustomTkinter**: Modern UI framework
- **QRCode**: QR code generation
- **PresenterPro Team**: Core server functionality

---

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Ensure all dependencies are installed
3. Try rebuilding the .exe
4. Check firewall/antivirus settings

---

**Enjoy your premium PresenterPro Server GUI!** 🎉✨

