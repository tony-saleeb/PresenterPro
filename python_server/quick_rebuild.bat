@echo off
echo ========================================
echo  PresenterPro Server - Quick Rebuild
echo ========================================
echo.

echo Stopping any running instances...
taskkill /f /im "PresenterPro Server.exe" 2>nul
taskkill /f /im python.exe 2>nul

echo.
echo Building new executable...
C:\Users\TONY\AppData\Local\Programs\Python\Python313\python.exe build_exe.py

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Build successful!
    echo 📁 Executable location: dist\PresenterPro Server.exe
    echo.
    echo 🚀 You can now run the executable!
) else (
    echo.
    echo ❌ Build failed. Check the error messages above.
)

echo.
pause
