# 🔨 Building PresenterPro Server .exe

Step-by-step instructions to create the Windows executable.

---

## 📋 Prerequisites

1. **Python 3.10 or later** installed
2. **pip** package manager
3. **Windows OS** (for building Windows .exe)

---

## 🚀 Quick Build (3 Steps)

### Step 1: Install Dependencies
Open Command Prompt or PowerShell in the `python_server` folder and run:

```bash
pip install -r requirements_gui.txt
```

This will install:
- customtkinter (GUI framework)
- qrcode (QR code generation)
- Pillow (Image processing)
- pyinstaller (Executable builder)
- All server dependencies

### Step 2: Build the Executable
Run the build script:

```bash
python build_exe.py
```

This will:
- Create a single `.exe` file
- Bundle all dependencies
- Include server modules
- Create it in the `dist` folder

### Step 3: Find Your .exe
The executable will be created at:

```
python_server/dist/PresenterPro Server.exe
```

**That's it! You can now run this .exe on any Windows PC (no Python required).**

---

## 🎯 Detailed Steps

### 1. Setup Virtual Environment (Recommended)

```bash
# Create virtual environment
python -m venv venv

# Activate it (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements_gui.txt
```

### 2. Test the GUI First (Before Building)

```bash
python server_gui.py
```

You should see:
- Beautiful GUI window
- Your IP address displayed
- QR code generated
- "Start Server" button

If this works, you're ready to build!

### 3. Build with PyInstaller

```bash
python build_exe.py
```

### 4. Test the .exe

```bash
cd dist
"PresenterPro Server.exe"
```

---

## 📦 What Gets Bundled

The .exe includes:
- Python runtime
- customtkinter library
- QR code generator
- Image libraries
- WebSocket server
- Slide controller code
- All dependencies

**Size**: Approximately 50-80 MB

---

## 🔧 Advanced Build Options

### Manual PyInstaller Command

If you want more control:

```bash
pyinstaller --name="PresenterPro Server" ^
            --onefile ^
            --windowed ^
            --add-data="slide_controller_server.py;." ^
            --add-data="slide_capture_extension.py;." ^
            --hidden-import=customtkinter ^
            --hidden-import=qrcode ^
            --collect-all=customtkinter ^
            --clean ^
            server_gui.py
```

### Add Custom Icon

1. Get an `.ico` file (256x256 recommended)
2. Add to build command:
   ```bash
   --icon=path/to/icon.ico
   ```

### Reduce File Size

1. Use UPX compression:
   ```bash
   --upx-dir=path/to/upx
   ```
2. Exclude unused packages
3. Use `--onedir` instead of `--onefile` (slower startup but smaller)

---

## 🧪 Testing Checklist

After building, test these features:

- [ ] GUI opens without errors
- [ ] IP address is detected correctly
- [ ] QR code is displayed
- [ ] "Copy IP" button works
- [ ] "Start Server" button works
- [ ] Server status updates correctly
- [ ] Can connect from phone
- [ ] "Stop Server" button works
- [ ] Window closes properly

---

## 🐛 Common Issues & Solutions

### Issue 1: "customtkinter not found"
**Solution**: Make sure you installed all dependencies:
```bash
pip install -r requirements_gui.txt
```

### Issue 2: Build fails with "module not found"
**Solution**: Add hidden imports in build script:
```python
'--hidden-import=module_name',
```

### Issue 3: .exe won't start
**Solution**: 
1. Try running from command line to see errors
2. Check if antivirus is blocking it
3. Try rebuilding with `--clean` flag

### Issue 4: QR code doesn't appear
**Solution**: Make sure Pillow is installed correctly:
```bash
pip install --upgrade Pillow
```

### Issue 5: Large file size
**Solution**: This is normal. The .exe includes entire Python runtime. Expected size: 50-80 MB.

---

## 📁 Output Structure

After building:

```
python_server/
├── build/              (temporary build files, can delete)
├── dist/
│   └── PresenterPro Server.exe  ← YOUR EXECUTABLE!
├── PresenterPro Server.spec     (build configuration, can delete)
├── server_gui.py
├── build_exe.py
└── requirements_gui.txt
```

---

## 🚀 Distribution

### To share the .exe:

1. **Just the .exe**: Users can run it directly (all dependencies included)
2. **With README**: Include `GUI_README.md` for instructions
3. **Zip it**: Create a zip file for easy download
4. **Sign it** (optional): For professional distribution

### What users need:
- **Windows 10 or later**
- **PowerPoint installed** (for slide control)
- **Nothing else!** No Python, no dependencies

---

## 🎯 Optimization Tips

### For Faster Startup
- Use `--onedir` instead of `--onefile`
- Users will have a folder with .exe and dependencies

### For Smaller Size
- Exclude unused packages
- Use UPX compression
- Remove debug symbols

### For Better Compatibility
- Build on oldest supported Windows version
- Test on multiple Windows versions
- Include Visual C++ redistributables if needed

---

## 📊 Build Time Expectations

- **First build**: 2-5 minutes
- **Subsequent builds**: 30-90 seconds
- **Clean build**: 2-3 minutes

---

## ✅ Success Indicators

You've successfully built the .exe when:
1. ✅ `dist/PresenterPro Server.exe` exists
2. ✅ File size is 50-80 MB
3. ✅ Double-clicking opens the GUI
4. ✅ All features work correctly
5. ✅ Can run on PC without Python installed

---

## 🎉 Next Steps

1. **Test thoroughly** on your PC
2. **Test on another PC** without Python
3. **Share with team/users**
4. **Get feedback**
5. **Iterate and improve**

---

**Happy Building!** 🔨✨

