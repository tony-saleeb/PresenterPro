"""
Build script to create an executable from the server GUI
Run this script to build the executable: python build_exe.py
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def install_pyinstaller():
    """Install PyInstaller if not already installed"""
    try:
        import PyInstaller
        print("PyInstaller is already installed")
    except ImportError:
        print("Installing PyInstaller...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])
        print("PyInstaller installed successfully")

def build_executable():
    """Build the executable using PyInstaller"""
    print("Building executable...")
    
    # Get the current directory
    current_dir = Path(__file__).parent
    
    # PyInstaller command
    cmd = [
        "pyinstaller",
        "--onefile",  # Create a single executable file
        "--windowed",  # No console window (GUI only)
        "--name=SlideControllerServer",  # Name of the executable
        "--hidden-import=websockets",
        "--hidden-import=pyautogui",
        "--hidden-import=PIL",
        "--hidden-import=PIL.Image",
        "--hidden-import=PIL.ImageGrab",
        "--hidden-import=asyncio",
        "--hidden-import=json",
        "--hidden-import=logging",
        "--hidden-import=socket",
        "--hidden-import=threading",
        "--hidden-import=tkinter",
        "--hidden-import=tkinter.ttk",
        "--hidden-import=tkinter.scrolledtext",
        "--hidden-import=tkinter.messagebox",
        "server_gui.py"
    ]
    
    # Remove icon parameter if icon file doesn't exist
    if not (current_dir / "icon.ico").exists():
        cmd = [arg for arg in cmd if not arg.startswith("--icon")]
        print("No icon.ico found, building without icon")
    
    try:
        # Run PyInstaller
        subprocess.run(cmd, check=True, cwd=current_dir)
        print("Executable built successfully!")
        
        # Check if the executable was created
        exe_path = current_dir / "dist" / "SlideControllerServer.exe"
        if exe_path.exists():
            print(f"Executable location: {exe_path}")
            print(f"File size: {exe_path.stat().st_size / (1024*1024):.1f} MB")
            
            # Copy to current directory for easy access
            shutil.copy2(exe_path, current_dir / "SlideControllerServer.exe")
            print("Executable copied to current directory")
            
        else:
            print("Executable not found in dist folder")
            
    except subprocess.CalledProcessError as e:
        print(f"Error building executable: {e}")
        return False
    
    return True

def cleanup():
    """Clean up build files"""
    print("Cleaning up build files...")
    
    current_dir = Path(__file__).parent
    
    # Remove build directories
    for dir_name in ["build", "dist", "__pycache__"]:
        dir_path = current_dir / dir_name
        if dir_path.exists():
            shutil.rmtree(dir_path)
            print(f"Removed {dir_name}/")
    
    # Remove spec file
    spec_file = current_dir / "SlideControllerServer.spec"
    if spec_file.exists():
        spec_file.unlink()
        print("Removed .spec file")

def main():
    """Main function"""
    print("Slide Controller Server - Executable Builder")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not Path("server_gui.py").exists():
        print("Error: server_gui.py not found in current directory")
        print("Please run this script from the python_server directory")
        return
    
    try:
        # Install PyInstaller
        install_pyinstaller()
        
        # Build executable
        if build_executable():
            print("\nBuild completed successfully!")
            print("You can find the executable in the current directory")
            print("Double-click 'SlideControllerServer.exe' to run the GUI")
            
            # Ask if user wants to clean up
            response = input("\nClean up build files? (y/n): ").lower().strip()
            if response in ['y', 'yes']:
                cleanup()
                print("Cleanup completed")
        else:
            print("Build failed")
            
    except KeyboardInterrupt:
        print("\nBuild cancelled by user")
    except Exception as e:
        print(f"Unexpected error: {e}")

if __name__ == "__main__":
    main()
