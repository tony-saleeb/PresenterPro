@echo off
echo ========================================
echo  PresenterPro Server - Rebuild Executable
echo ========================================
echo.

echo Stopping any running instances...
taskkill /f /im "PresenterPro Server.exe" 2>nul

echo.
echo Building new executable...
C:\Users\TONY\AppData\Local\Programs\Python\Python313\python.exe build_exe.py

echo.
echo Build complete! Check the 'dist' folder for your executable.
echo.
pause
