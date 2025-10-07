import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import threading
import asyncio
import json
import logging
import socket
import sys
import os
from pathlib import Path
import subprocess
import time

# Add the current directory to Python path to import our modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from slide_controller_server import SlideControllerServer

class ServerGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Slide Controller Server")
        self.root.geometry("600x500")
        self.root.resizable(True, True)
        
        # Server variables
        self.server = None
        self.server_thread = None
        self.is_running = False
        self.server_loop = None
        self.server_task = None
        self.local_ip = self.get_local_ip()
        
        # Configure logging to capture in GUI
        self.setup_logging()
        
        # Create GUI
        self.create_widgets()
        
        # Center window on screen
        self.center_window()
        
    def get_local_ip(self):
        """Get the local IP address of the machine"""
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.connect(("8.8.8.8", 80))
                local_ip = s.getsockname()[0]
                return local_ip
        except Exception:
            return "localhost"
    
    def setup_logging(self):
        """Setup logging to capture in GUI"""
        # Create a custom log handler that writes to our text widget
        class GUILogHandler(logging.Handler):
            def __init__(self, text_widget):
                super().__init__()
                self.text_widget = text_widget
                
            def emit(self, record):
                msg = self.format(record)
                # Use after() to ensure thread safety
                self.text_widget.after(0, lambda: self.append_log(msg))
                
            def append_log(self, msg):
                self.text_widget.insert(tk.END, msg + "\n")
                self.text_widget.see(tk.END)
        
        # Configure logging
        logging.basicConfig(level=logging.INFO)
        logger = logging.getLogger()
        
        # Remove default handlers
        for handler in logger.handlers[:]:
            logger.removeHandler(handler)
        
        # Add our GUI handler
        self.log_handler = GUILogHandler(None)  # Will be set later
        self.log_handler.setFormatter(logging.Formatter('%(asctime)s - %(message)s', datefmt='%H:%M:%S'))
        logger.addHandler(self.log_handler)
    
    def create_widgets(self):
        """Create all GUI widgets"""
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(3, weight=1)
        
        # Title
        title_label = ttk.Label(main_frame, text="🎯 Slide Controller Server", 
                               font=("Arial", 16, "bold"))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))
        
        # Server info frame
        info_frame = ttk.LabelFrame(main_frame, text="Server Information", padding="10")
        info_frame.grid(row=1, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(0, 10))
        info_frame.columnconfigure(1, weight=1)
        
        # IP Address
        ttk.Label(info_frame, text="IP Address:").grid(row=0, column=0, sticky=tk.W, padx=(0, 10))
        self.ip_label = ttk.Label(info_frame, text=self.local_ip, font=("Arial", 10, "bold"))
        self.ip_label.grid(row=0, column=1, sticky=tk.W)
        
        # Port
        ttk.Label(info_frame, text="Port:").grid(row=1, column=0, sticky=tk.W, padx=(0, 10))
        self.port_label = ttk.Label(info_frame, text="8080", font=("Arial", 10, "bold"))
        self.port_label.grid(row=1, column=1, sticky=tk.W)
        
        # WebSocket URL
        ttk.Label(info_frame, text="WebSocket URL:").grid(row=2, column=0, sticky=tk.W, padx=(0, 10))
        self.url_label = ttk.Label(info_frame, text=f"ws://{self.local_ip}:8080", 
                                  font=("Arial", 10, "bold"), foreground="blue")
        self.url_label.grid(row=2, column=1, sticky=tk.W)
        
        # Control buttons frame
        control_frame = ttk.Frame(main_frame)
        control_frame.grid(row=2, column=0, columnspan=3, pady=(0, 10))
        
        # Start/Stop button
        self.start_button = ttk.Button(control_frame, text="🚀 Start Server", 
                                      command=self.start_server, style="Accent.TButton")
        self.start_button.pack(side=tk.LEFT, padx=(0, 10))
        
        self.stop_button = ttk.Button(control_frame, text="🛑 Stop Server", 
                                     command=self.stop_server, state="disabled")
        self.stop_button.pack(side=tk.LEFT, padx=(0, 10))
        
        # Status indicator
        self.status_label = ttk.Label(control_frame, text="● Stopped", foreground="red")
        self.status_label.pack(side=tk.LEFT, padx=(20, 0))
        
        # Log frame
        log_frame = ttk.LabelFrame(main_frame, text="Server Logs", padding="5")
        log_frame.grid(row=3, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S))
        log_frame.columnconfigure(0, weight=1)
        log_frame.rowconfigure(0, weight=1)
        
        # Log text widget
        self.log_text = scrolledtext.ScrolledText(log_frame, height=15, width=70, 
                                                 font=("Consolas", 9))
        self.log_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Set the log handler's text widget
        self.log_handler.text_widget = self.log_text
        
        # Clear log button
        clear_button = ttk.Button(log_frame, text="Clear Logs", command=self.clear_logs)
        clear_button.grid(row=1, column=0, pady=(5, 0), sticky=tk.W)
        
        # Instructions frame
        instructions_frame = ttk.LabelFrame(main_frame, text="Quick Instructions", padding="10")
        instructions_frame.grid(row=4, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(10, 0))
        
        instructions_text = """1. 📊 Open PowerPoint presentation
2. 🖱️ Click on PowerPoint window to make it active  
3. 📱 Connect your phone using the IP address above
4. 🎮 Tap 'Start' in the app to begin slideshow (F5)
5. 👆 Swipe left/right to control slides"""
        
        ttk.Label(instructions_frame, text=instructions_text, justify=tk.LEFT).pack(anchor=tk.W)
        
        # Initial log message
        self.log_message("Slide Controller Server GUI Ready")
        self.log_message(f"Server will run on: {self.local_ip}:8080")
        self.log_message("Click 'Start Server' to begin")
    
    def center_window(self):
        """Center the window on the screen"""
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f"{width}x{height}+{x}+{y}")
    
    def log_message(self, message):
        """Add a message to the log"""
        self.log_text.insert(tk.END, f"{time.strftime('%H:%M:%S')} - {message}\n")
        self.log_text.see(tk.END)
    
    def clear_logs(self):
        """Clear the log text widget"""
        self.log_text.delete(1.0, tk.END)
    
    def start_server(self):
        """Start the server in a separate thread"""
        if self.is_running:
            return
        
        try:
            self.log_message("🚀 Starting Slide Controller Server...")
            
            # Create server instance
            self.server = SlideControllerServer()
            
            # Start server in a separate thread
            self.server_thread = threading.Thread(target=self.run_server, daemon=True)
            self.server_thread.start()
            
            # Update UI
            self.is_running = True
            self.start_button.config(state="disabled")
            self.stop_button.config(state="normal")
            self.status_label.config(text="● Running", foreground="green")
            
            self.log_message("Server started successfully!")
            self.log_message(f"Connect your phone to: {self.local_ip}:8080")
            
        except Exception as e:
            self.log_message(f"Error starting server: {e}")
            messagebox.showerror("Error", f"Failed to start server:\n{e}")
    
    def run_server(self):
        """Run the server (called in separate thread)"""
        try:
            # Create new event loop for this thread
            self.server_loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self.server_loop)
            
            # Create a task for the server
            self.server_task = self.server_loop.create_task(self.server.start_server())
            
            # Run the server
            self.server_loop.run_until_complete(self.server_task)
            
        except Exception as e:
            self.log_message(f"Server error: {e}")
        finally:
            # Clean up the event loop
            if self.server_loop:
                try:
                    # Cancel any remaining tasks
                    if self.server_task and not self.server_task.done():
                        self.server_task.cancel()
                    
                    # Close the loop
                    self.server_loop.close()
                except:
                    pass
                self.server_loop = None
                self.server_task = None
            
            # Update UI when server stops
            self.root.after(0, self.server_stopped)
    
    def stop_server(self):
        """Stop the server"""
        if not self.is_running:
            return
        
        try:
            self.log_message("Stopping server...")
            
            # Stop the server by canceling the task
            if self.server_loop and not self.server_loop.is_closed():
                if self.server_task and not self.server_task.done():
                    # Cancel the server task
                    self.server_loop.call_soon_threadsafe(self.server_task.cancel)
                # Stop the event loop
                self.server_loop.call_soon_threadsafe(self.server_loop.stop)
            
            # Update UI immediately
            self.is_running = False
            self.start_button.config(state="normal")
            self.stop_button.config(state="disabled")
            self.status_label.config(text="● Stopped", foreground="red")
            
            self.log_message("Server stopped")
            
        except Exception as e:
            self.log_message(f"Error stopping server: {e}")
    
    def server_stopped(self):
        """Called when server stops (from server thread)"""
        self.is_running = False
        self.start_button.config(state="normal")
        self.stop_button.config(state="disabled")
        self.status_label.config(text="● Stopped", foreground="red")
        self.log_message("Server stopped")
    
    def on_closing(self):
        """Handle window closing"""
        if self.is_running:
            if messagebox.askokcancel("Quit", "Server is running. Do you want to quit?"):
                self.stop_server()
                self.root.destroy()
        else:
            self.root.destroy()

def main():
    """Main function"""
    root = tk.Tk()
    
    # Set window icon (if available)
    try:
        # You can add an icon file here if you have one
        # root.iconbitmap("icon.ico")
        pass
    except:
        pass
    
    # Create and run the GUI
    app = ServerGUI(root)
    
    # Handle window closing
    root.protocol("WM_DELETE_WINDOW", app.on_closing)
    
    # Start the GUI
    root.mainloop()

if __name__ == "__main__":
    main()
