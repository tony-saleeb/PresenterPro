@echo off
echo 🎯 Slide Controller Server - Executable Builder
echo ================================================

echo 📦 Installing requirements...
pip install -r requirements_gui.txt

echo.
echo 🔨 Building executable...
python build_exe.py

echo.
echo ✅ Build process completed!
echo 📁 Check the current directory for SlideControllerServer.exe
echo 🚀 Double-click the .exe file to run the GUI

pause
