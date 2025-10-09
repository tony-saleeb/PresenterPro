# 🔧 PresenterPro Troubleshooting Guide

Common issues and their solutions.

---

## 📱 Mobile App Issues

### Issue: MissingPluginException for mobile_scanner

**Error Message:**
```
MissingPluginException(No implementation found for method listen on channel dev.steenbakker.mobile_scanner/scanner/event)
```

**Solution:**
The plugin wasn't properly registered after adding the package. Run these commands:

```bash
flutter clean
flutter pub get
flutter build apk --debug
flutter run
```

**Why it happens:**
- New plugins need to be fully integrated into the Android build
- `flutter clean` removes old build files
- Rebuilding registers the plugin properly

---

### Issue: Camera Permission Denied

**Error Message:**
```
Camera permission not granted
```

**Solution:**
1. Go to Android **Settings** → **Apps** → **PresenterPro**
2. Tap **Permissions**
3. Enable **Camera** permission
4. Restart the app

**Alternative:**
Uninstall and reinstall the app to trigger permission request again.

---

### Issue: QR Scanner Won't Open

**Symptoms:**
- Tapping QR button does nothing
- App crashes when opening scanner

**Solutions:**

**A. Check Camera Permissions**
```bash
# Check if permissions are in AndroidManifest.xml
grep -i camera android/app/src/main/AndroidManifest.xml
```
Should show:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**B. Rebuild the App**
```bash
flutter clean
flutter pub get
flutter run
```

**C. Check Device Camera**
- Open device's default camera app
- If camera doesn't work there, it's a hardware issue

---

### Issue: QR Code Not Scanning

**Symptoms:**
- Scanner opens but doesn't detect QR code
- Takes very long to scan

**Solutions:**

**A. Lighting**
- Turn on **flashlight** in scanner
- Ensure good lighting
- Avoid glare on PC screen

**B. Distance**
- Hold phone **15-30cm** from screen
- Keep phone steady
- Ensure entire QR code is visible

**C. QR Code Quality**
- Make sure PC screen brightness is high
- QR code should be clear and sharp
- Try regenerating QR code on PC

**D. Camera Focus**
- Tap screen to focus camera
- Wait for camera to autofocus
- Clean phone camera lens

---

### Issue: Auto-Connect Fails After Scan

**Symptoms:**
- QR scans successfully
- But connection fails
- Returns to connection screen

**Solutions:**

**A. Network Check**
- Ensure phone and PC are on **same WiFi network**
- Phone hotspot is connected to PC
- No VPN on either device

**B. Server Check**
- Make sure server is **running** on PC
- Check server status shows **green**
- Try manual IP connection to verify server works

**C. Firewall**
- Check Windows Firewall isn't blocking port 8765
- Add exception for PresenterPro Server
- Temporarily disable firewall to test

---

### Issue: App Crashes on Startup

**Solutions:**

**A. Clear App Data**
```bash
flutter clean
rm -rf build/
flutter pub get
flutter run
```

**B. Check Logs**
```bash
flutter logs
```
Look for specific error messages

**C. Reinstall**
```bash
flutter run --uninstall-first
```

---

## 💻 PC Server Issues

### Issue: GUI Won't Open

**Error Message:**
```
No module named 'customtkinter'
```

**Solution:**
Install GUI dependencies:
```bash
pip install -r requirements_gui.txt
```

---

### Issue: QR Code Doesn't Display

**Symptoms:**
- GUI opens but QR code area is blank
- Error about PIL or qrcode

**Solution:**

**A. Install Pillow**
```bash
pip install --upgrade Pillow
pip install qrcode[pil]
```

**B. Reinstall Dependencies**
```bash
pip uninstall qrcode pillow
pip install qrcode[pil] Pillow
```

**C. Check Image Format Support**
```python
# Test in Python console
from PIL import Image
import qrcode
qr = qrcode.QRCode()
qr.add_data("test")
qr.make()
img = qr.make_image()
print("QR code generated successfully!")
```

---

### Issue: IP Shows 127.0.0.1

**Symptoms:**
- Server IP displays as 127.0.0.1
- Can't connect from phone

**Solution:**

**A. Check Network Connection**
- Make sure PC is connected to WiFi or Ethernet
- Not just "connected" but actually has internet

**B. Multiple Network Adapters**
Find your correct IP manually:

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" under your WiFi/Ethernet adapter

**Manual Override:**
If detection fails, you can manually set IP in the code (temporary fix):
```python
# In server_gui.py, line ~33
self.local_ip = "192.168.1.XXX"  # Your actual IP
```

---

### Issue: Server Won't Start

**Error Message:**
```
Address already in use
```

**Solution:**

**A. Port Already in Use**
Another program is using port 8765:

**Windows:**
```bash
netstat -ano | findstr :8765
taskkill /PID <PID_NUMBER> /F
```

**B. Previous Instance Running**
- Check Task Manager for "PresenterPro Server"
- End the process
- Try starting again

**C. Try Different Port**
Modify `slide_controller_server.py`:
```python
# Change port from 8765 to 8766
websockets.serve(self.handle_client, "0.0.0.0", 8766)
```

Then update phone app to use new port.

---

### Issue: .exe Build Fails

**Error Message:**
```
ModuleNotFoundError during build
```

**Solution:**

**A. Install PyInstaller**
```bash
pip install --upgrade pyinstaller
```

**B. Missing Modules**
Add to `build_exe.py`:
```python
'--hidden-import=missing_module_name',
```

**C. Clean Build**
```bash
# Delete old build files
rmdir /s /q build dist
del "PresenterPro Server.spec"

# Rebuild
python build_exe.py
```

---

### Issue: .exe Won't Run

**Symptoms:**
- Double-clicking does nothing
- Briefly appears then closes

**Solutions:**

**A. Run from Command Line**
To see error messages:
```bash
cd dist
"PresenterPro Server.exe"
```

**B. Antivirus Blocking**
- Check antivirus logs
- Add exception for the .exe
- Windows Defender might flag it

**C. Missing DLLs**
Ensure Visual C++ Redistributables are installed:
- Download from Microsoft website
- Install both x86 and x64 versions

**D. Build with Console**
For debugging, build with console visible:
```python
# In build_exe.py, change:
'--windowed',  # Remove this line
```
Rebuild and run to see error messages.

---

## 🌐 Network Issues

### Issue: Can't Connect - Same WiFi

**Checklist:**
- [ ] Both devices show same WiFi name
- [ ] PC can ping phone (if phone IP is known)
- [ ] No VPN active on either device
- [ ] Firewall allows port 8765
- [ ] Server is actually running

**Test Connection:**

**From PC to Phone:**
- Get phone IP: Settings → About → Status
- Ping from PC: `ping <phone_ip>`

**From Phone to PC:**
- In PresenterPro app, manually enter PC IP
- Should connect if network is working

---

### Issue: Hotspot Connection Fails

**Symptoms:**
- Phone hotspot shows "no internet"
- Connection fails

**Solution:**
This is expected and should still work! The app doesn't need internet, just local network.

**Verify:**
1. Connect PC to phone hotspot
2. On PC, check IP: `ipconfig`
3. Use that IP in app (should be 192.168.x.x)
4. Should work even without cellular data

---

### Issue: Firewall Blocking Connection

**Symptoms:**
- Connection times out
- Works on one PC but not another

**Solution:**

**Windows Firewall:**
1. Open **Windows Defender Firewall**
2. Click **Advanced settings**
3. Click **Inbound Rules** → **New Rule**
4. Choose **Port**, click **Next**
5. Choose **TCP**, enter **8765**, click **Next**
6. Choose **Allow the connection**, click **Next**
7. Check all profiles, click **Next**
8. Name it "PresenterPro Server", click **Finish**

**Quick Test:**
Temporarily disable firewall and test connection.

---

## 🎯 Performance Issues

### Issue: High Latency

**Symptoms:**
- Laser pointer lags
- Slide changes are slow

**Solutions:**

**A. Network Quality**
- Use 5GHz WiFi instead of 2.4GHz
- Reduce distance between PC and phone
- Remove obstacles between devices

**B. PC Performance**
- Close unnecessary programs
- Check CPU usage in Task Manager
- Restart PC if running for long time

**C. Phone Performance**
- Close background apps
- Check phone isn't in battery saver mode
- Restart phone

---

### Issue: Slide Capture Slow

**Symptoms:**
- Mirrored slides update slowly
- Animations not syncing

**Solution:**

**A. Lower Quality** (if needed)
In `slide_capture_extension.py`:
```python
self.capture_quality = 70  # Lower from 85
self.capture_scale = 0.4   # Lower from 0.5
```

**B. PC Resources**
- Ensure PowerPoint isn't lagging
- Check PC has enough RAM
- Close heavy programs

---

## 🔍 Debugging Tips

### Enable Verbose Logging

**Mobile App:**
```dart
// In slide_control_screen.dart
// Uncomment debug print statements
print('🎯 Touch detected at: $position');
print('🎯 Sending laser pointer to: $x%, $y%');
```

**PC Server:**
```python
# In slide_controller_server.py
# Add logging
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Check Plugin Registration

```bash
flutter doctor -v
```
Should show all plugins including mobile_scanner.

### Test Components Separately

**A. Test QR Code Generation**
```python
import qrcode
qr = qrcode.QRCode()
qr.add_data("192.168.1.100")
qr.make()
img = qr.make_image()
img.save("test_qr.png")
print("QR code saved!")
```

**B. Test Camera**
Use device's default camera app to ensure hardware works.

**C. Test Network**
Ping between devices to verify network connectivity.

---

## 📞 Getting More Help

### Collect Debug Information

When reporting issues, include:
1. **Flutter version**: `flutter --version`
2. **Python version**: `python --version`
3. **OS versions**: Windows version, Android version
4. **Error messages**: Full error text
5. **Steps to reproduce**: What you did before error
6. **Logs**: From `flutter logs` or server console

### Check Documentation
- `QR_SCANNER_AND_GUI_IMPLEMENTATION.md` - Technical details
- `GUI_README.md` - Server GUI guide
- `BUILD_INSTRUCTIONS.md` - Build process
- `QUICK_START_GUIDE.md` - Basic usage

---

## ✅ Prevention Tips

### Regular Maintenance
- Keep Flutter updated: `flutter upgrade`
- Keep packages updated: `flutter pub upgrade`
- Keep Python packages updated: `pip install --upgrade -r requirements_gui.txt`

### Before Presenting
- Test connection 5-10 minutes before
- Ensure both devices fully charged
- Have backup (laptop with PowerPoint remote)
- Keep devices close during presentation

### Best Practices
- Use 5GHz WiFi when available
- Keep firewall rules configured
- Don't update software right before presenting
- Test on the actual presentation PC beforehand

---

**Most issues can be solved with a clean rebuild. When in doubt, try: `flutter clean && flutter pub get && flutter run`** 🔧✨

