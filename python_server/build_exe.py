"""
Build script for PresenterPro Server executable
Creates a standalone Windows .exe file
"""

import PyInstaller.__main__
import os
import shutil

def build_exe():
    """Build the executable"""
    print("Building PresenterPro Server...")
    print("=" * 60)
    
    # Get the current directory
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # PyInstaller arguments
    args = [
        os.path.join(current_dir, 'server_gui.py'),  # Main script with full path
        '--name=PresenterPro Server',  # Name of the executable
        '--onefile',  # Create a single executable
        '--windowed',  # No console window
        '--icon=NONE',  # No icon (you can add one later)
        f'--add-data={os.path.join(current_dir, "slide_controller_server.py")};.',  # Include server module
        f'--add-data={os.path.join(current_dir, "slide_capture_extension.py")};.',  # Include capture extension
        '--hidden-import=customtkinter',
        '--hidden-import=qrcode',
        '--hidden-import=PIL',
        '--hidden-import=websockets',
        '--hidden-import=pyautogui',
        '--hidden-import=mss',
        '--collect-all=customtkinter',
        '--clean',  # Clean cache before building
        f'--distpath={os.path.join(current_dir, "dist")}',
        f'--workpath={os.path.join(current_dir, "build")}',
        f'--specpath={current_dir}',
    ]
    
    print("\nRunning PyInstaller...")
    PyInstaller.__main__.run(args)
    
    print("\nBuild complete!")
    print(f"\nExecutable location: {os.path.join(current_dir, 'dist', 'PresenterPro Server.exe')}")
    print("\nYou can now run 'PresenterPro Server.exe' to start the server!")
    print("\n" + "=" * 60)

if __name__ == "__main__":
    build_exe()
