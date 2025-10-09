"""
PresenterPro Server - Beautiful GUI Application
A modern, premium GUI for the PresenterPro server with QR code generation
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import messagebox
import qrcode
from PIL import Image, ImageTk
import socket
import threading
import asyncio
from slide_controller_server import SlideControllerServer
import sys
from io import BytesIO

# Set appearance mode and color theme
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")


class PresenterProServerGUI:
    def __init__(self):
        self.root = ctk.CTk()
        self.root.title("PresenterPro Server")
        self.root.geometry("700x1000")
        self.root.resizable(True, True)
        self.root.minsize(600, 900)
        
        # Server state
        self.server = None
        self.server_thread = None
        self.is_running = False
        self.local_ip = self.get_local_ip()
        self.server_task = None
        
        # Setup UI
        self.setup_ui()
        
    def get_local_ip(self):
        """Get the local IP address"""
        try:
            # Create a socket to get local IP
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception:
            # Fallback methods
            try:
                hostname = socket.gethostname()
                ip = socket.gethostbyname(hostname)
                if not ip.startswith("127."):
                    return ip
            except Exception:
                pass
            
            # Last resort
            return "127.0.0.1"
    
    def setup_ui(self):
        """Setup the UI components"""
        # Create scrollable frame
        self.scrollable_frame = ctk.CTkScrollableFrame(self.root, fg_color="transparent")
        self.scrollable_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Main container with padding
        main_frame = ctk.CTkFrame(self.scrollable_frame, fg_color="transparent")
        main_frame.pack(fill="both", expand=True)
        
        # ============ DEBUG TEST BUTTON ============
        test_btn = ctk.CTkButton(
            main_frame,
            text="🔧 TEST BUTTON - If you see this, layout is working!",
            font=ctk.CTkFont(size=16, weight="bold"),
            height=40,
            corner_radius=12,
            fg_color=("#EF4444", "#DC2626"),
            hover_color=("#DC2626", "#B91C1C"),
            command=lambda: messagebox.showinfo("Test", "Layout is working! The start/stop button should be below."),
        )
        test_btn.pack(fill="x", pady=(0, 10))
        
        # ============ HEADER SECTION ============
        header_frame = ctk.CTkFrame(main_frame, fg_color=("#1E293B", "#0F172A"), corner_radius=20)
        header_frame.pack(fill="x", pady=(0, 20))
        header_frame.pack_propagate(False)
        header_frame.configure(height=140)
        
        # Logo and title
        logo_label = ctk.CTkLabel(
            header_frame,
            text="🎬",
            font=ctk.CTkFont(size=48),
        )
        logo_label.pack(pady=(15, 5))
        
        title_label = ctk.CTkLabel(
            header_frame,
            text="PresenterPro Server",
            font=ctk.CTkFont(size=28, weight="bold"),
            text_color=("#FFFFFF", "#FFFFFF"),
        )
        title_label.pack()
        
        subtitle_label = ctk.CTkLabel(
            header_frame,
            text="Professional PowerPoint Control • Zero Latency",
            font=ctk.CTkFont(size=13),
            text_color=("#94A3B8", "#94A3B8"),
        )
        subtitle_label.pack(pady=(2, 10))
        
        # ============ STATUS CARD ============
        status_frame = ctk.CTkFrame(main_frame, fg_color=("#1E293B", "#0F172A"), corner_radius=20)
        status_frame.pack(fill="x", pady=(0, 20))
        
        # Status indicator
        status_header = ctk.CTkFrame(status_frame, fg_color="transparent")
        status_header.pack(fill="x", padx=25, pady=(20, 10))
        
        status_icon_label = ctk.CTkLabel(
            status_header,
            text="🔴",
            font=ctk.CTkFont(size=20),
        )
        status_icon_label.pack(side="left")
        
        status_title = ctk.CTkLabel(
            status_header,
            text="Server Status",
            font=ctk.CTkFont(size=18, weight="bold"),
            text_color=("#FFFFFF", "#FFFFFF"),
        )
        status_title.pack(side="left", padx=(10, 0))
        
        self.status_icon = status_icon_label
        
        # Status text
        self.status_label = ctk.CTkLabel(
            status_frame,
            text="⚫ Server is stopped",
            font=ctk.CTkFont(size=16, weight="bold"),
            text_color=("#94A3B8", "#94A3B8"),
        )
        self.status_label.pack(padx=25, pady=(0, 20))
        
        # ============ IP ADDRESS CARD ============
        ip_frame = ctk.CTkFrame(main_frame, fg_color=("#1E293B", "#0F172A"), corner_radius=20)
        ip_frame.pack(fill="x", pady=(0, 20))
        
        ip_header = ctk.CTkFrame(ip_frame, fg_color="transparent")
        ip_header.pack(fill="x", padx=25, pady=(20, 10))
        
        ip_icon = ctk.CTkLabel(
            ip_header,
            text="🌐",
            font=ctk.CTkFont(size=20),
        )
        ip_icon.pack(side="left")
        
        ip_title = ctk.CTkLabel(
            ip_header,
            text="Server IP Address",
            font=ctk.CTkFont(size=18, weight="bold"),
            text_color=("#FFFFFF", "#FFFFFF"),
        )
        ip_title.pack(side="left", padx=(10, 0))
        
        # IP address display
        ip_display_frame = ctk.CTkFrame(ip_frame, fg_color=("#334155", "#1E293B"), corner_radius=12)
        ip_display_frame.pack(fill="x", padx=25, pady=(0, 15))
        
        self.ip_label = ctk.CTkLabel(
            ip_display_frame,
            text=self.local_ip,
            font=ctk.CTkFont(size=32, weight="bold", family="Consolas"),
            text_color=("#3B82F6", "#3B82F6"),
        )
        self.ip_label.pack(pady=20)
        
        # Copy button
        copy_btn = ctk.CTkButton(
            ip_frame,
            text="📋 Copy IP Address",
            font=ctk.CTkFont(size=14, weight="bold"),
            height=40,
            corner_radius=12,
            fg_color=("#3B82F6", "#2563EB"),
            hover_color=("#2563EB", "#1D4ED8"),
            command=self.copy_ip,
        )
        copy_btn.pack(padx=25, pady=(0, 20))
        
        # ============ QR CODE CARD ============
        qr_frame = ctk.CTkFrame(main_frame, fg_color=("#1E293B", "#0F172A"), corner_radius=20)
        qr_frame.pack(fill="x", pady=(0, 20))
        qr_frame.pack_propagate(False)
        qr_frame.configure(height=350)
        
        qr_header = ctk.CTkFrame(qr_frame, fg_color="transparent")
        qr_header.pack(fill="x", padx=25, pady=(20, 10))
        
        qr_icon = ctk.CTkLabel(
            qr_header,
            text="📱",
            font=ctk.CTkFont(size=20),
        )
        qr_icon.pack(side="left")
        
        qr_title = ctk.CTkLabel(
            qr_header,
            text="Scan to Connect",
            font=ctk.CTkFont(size=18, weight="bold"),
            text_color=("#FFFFFF", "#FFFFFF"),
        )
        qr_title.pack(side="left", padx=(10, 0))
        
        # QR code container with better spacing
        qr_container = ctk.CTkFrame(qr_frame, fg_color=("#334155", "#1E293B"), corner_radius=15)
        qr_container.pack(fill="x", padx=25, pady=(10, 10))
        qr_container.pack_propagate(False)
        qr_container.configure(height=200)
        
        # QR code display with proper sizing
        self.qr_label = ctk.CTkLabel(
            qr_container,
            text="",
            width=180,
            height=180,
        )
        self.qr_label.pack(expand=True, pady=10)
        
        # Generate QR code
        self.generate_qr_code()
        
        qr_instruction = ctk.CTkLabel(
            qr_frame,
            text="Open PresenterPro app and scan this QR code",
            font=ctk.CTkFont(size=13),
            text_color=("#94A3B8", "#94A3B8"),
        )
        qr_instruction.pack(pady=(0, 10))
        
        # ============ CONTROL BUTTONS ============
        button_frame = ctk.CTkFrame(main_frame, fg_color=("#1E293B", "#0F172A"), corner_radius=20)
        button_frame.pack(fill="x", pady=(0, 20))
        button_frame.pack_propagate(False)
        button_frame.configure(height=120)
        
        # Button header
        btn_header = ctk.CTkFrame(button_frame, fg_color="transparent")
        btn_header.pack(fill="x", padx=25, pady=(15, 5))
        
        btn_icon = ctk.CTkLabel(
            btn_header,
            text="🎮",
            font=ctk.CTkFont(size=20),
        )
        btn_icon.pack(side="left")
        
        btn_title = ctk.CTkLabel(
            btn_header,
            text="Server Control",
            font=ctk.CTkFont(size=18, weight="bold"),
            text_color=("#FFFFFF", "#FFFFFF"),
        )
        btn_title.pack(side="left", padx=(10, 0))
        
        # Button container for better spacing
        btn_container = ctk.CTkFrame(button_frame, fg_color="transparent")
        btn_container.pack(fill="x", padx=25, pady=(5, 10))
        
        self.start_btn = ctk.CTkButton(
            btn_container,
            text="▶️  Start Server",
            font=ctk.CTkFont(size=20, weight="bold"),
            height=50,
            corner_radius=16,
            fg_color=("#10B981", "#059669"),
            hover_color=("#059669", "#047857"),
            command=self.toggle_server,
        )
        self.start_btn.pack(fill="x")
        
        # Additional info label
        info_label = ctk.CTkLabel(
            button_frame,
            text="💡 Tip: Start the server before scanning QR code",
            font=ctk.CTkFont(size=12),
            text_color=("#94A3B8", "#94A3B8"),
        )
        info_label.pack(pady=(0, 10))
        
    def generate_qr_code(self):
        """Generate QR code for the server IP"""
        try:
            # Create QR code with better settings
            qr = qrcode.QRCode(
                version=1,
                error_correction=qrcode.constants.ERROR_CORRECT_H,
                box_size=12,
                border=4,
            )
            qr.add_data(self.local_ip)
            qr.make(fit=True)
            
            # Create QR image with better colors and contrast
            qr_img = qr.make_image(fill_color="#1E293B", back_color="white")
            
            # Resize for display with better quality
            qr_img = qr_img.resize((180, 180), Image.Resampling.LANCZOS)
            
            # Convert to PhotoImage
            qr_photo = ImageTk.PhotoImage(qr_img)
            
            # Update label
            self.qr_label.configure(image=qr_photo)
            self.qr_label.image = qr_photo  # Keep a reference
            
        except Exception as e:
            print(f"Error generating QR code: {e}")
            # Show error message in QR area
            self.qr_label.configure(text="❌ QR Code Error", font=ctk.CTkFont(size=16))
    
    def copy_ip(self):
        """Copy IP address to clipboard"""
        self.root.clipboard_clear()
        self.root.clipboard_append(self.local_ip)
        self.root.update()
        
        # Show feedback
        messagebox.showinfo("Copied!", f"IP address {self.local_ip} copied to clipboard!")
    
    def toggle_server(self):
        """Start or stop the server"""
        if not self.is_running:
            self.start_server()
        else:
            self.stop_server()
    
    def start_server(self):
        """Start the WebSocket server"""
        try:
            # Update UI immediately
            self.is_running = True
            self.start_btn.configure(
                text="⏹️  Stop Server",
                fg_color=("#EF4444", "#DC2626"),
                hover_color=("#DC2626", "#B91C1C"),
            )
            self.status_label.configure(
                text="🟢 Server is running",
                text_color=("#10B981", "#10B981"),
            )
            self.status_icon.configure(text="🟢")
            
            # Disable button temporarily to prevent multiple starts
            self.start_btn.configure(state="disabled")
            
            # Start server in a separate thread
            self.server_thread = threading.Thread(target=self.run_server, daemon=True)
            self.server_thread.start()
            
            # Re-enable button after a short delay
            self.root.after(1000, lambda: self.start_btn.configure(state="normal"))
            
            # Show success message
            self.root.after(500, lambda: messagebox.showinfo(
                "Server Started", 
                f"✅ Server is now running on {self.local_ip}:8080\n\n📱 Scan the QR code with your phone to connect!\n\n🎯 Ready for presentations!"
            ))
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to start server: {e}")
            self.is_running = False
            self.start_btn.configure(state="normal")
    
    def stop_server(self):
        """Stop the WebSocket server"""
        try:
            self.is_running = False
            
            # Disable button temporarily
            self.start_btn.configure(state="disabled")
            
            # Update UI
            self.start_btn.configure(
                text="▶️  Start Server",
                fg_color=("#10B981", "#059669"),
                hover_color=("#059669", "#047857"),
            )
            self.status_label.configure(
                text="⚫ Server is stopped",
                text_color=("#94A3B8", "#94A3B8"),
            )
            self.status_icon.configure(text="🔴")
            
            # Stop the server if it exists
            if self.server:
                try:
                    # Try to stop the server gracefully
                    if hasattr(self.server, 'stop'):
                        self.server.stop()
                except Exception as e:
                    print(f"Error stopping server: {e}")
            
            # Re-enable button
            self.start_btn.configure(state="normal")
            
            # Show confirmation
            messagebox.showinfo("Server Stopped", "✅ Server has been stopped successfully.\n\n📱 Disconnected clients will need to reconnect.")
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to stop server: {e}")
            self.start_btn.configure(state="normal")
    
    def run_server(self):
        """Run the WebSocket server"""
        try:
            # Create new event loop for this thread
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            
            # Create and run server
            self.server = SlideControllerServer()
            
            # Run server until stopped
            while self.is_running:
                try:
                    loop.run_until_complete(self.server.start_server())
                    break
                except Exception as e:
                    if self.is_running:
                        print(f"Server error: {e}")
                        # Wait a bit before retrying
                        import time
                        time.sleep(1)
                    else:
                        break
            
        except Exception as e:
            print(f"Server error: {e}")
            self.is_running = False
            # Update UI on error
            self.root.after(0, self.reset_ui_on_error)
    
    def reset_ui_on_error(self):
        """Reset UI when server encounters an error"""
        self.is_running = False
        self.start_btn.configure(
            text="▶️  Start Server",
            fg_color=("#10B981", "#059669"),
            hover_color=("#059669", "#047857"),
            state="normal"
        )
        self.status_label.configure(
            text="❌ Server error - Click to restart",
            text_color=("#EF4444", "#EF4444"),
        )
        self.status_icon.configure(text="🔴")
        messagebox.showerror("Server Error", "Server encountered an error and stopped.\n\nClick 'Start Server' to try again.")
    
    def run(self):
        """Run the application"""
        self.root.mainloop()
    
    def on_closing(self):
        """Handle window closing"""
        if self.is_running:
            if messagebox.askokcancel("Quit", "Server is still running. Do you want to stop it and quit?"):
                self.stop_server()
                self.root.after(1000, self.root.destroy)  # Give time for server to stop
        else:
            self.root.destroy()


def main():
    """Main entry point"""
    try:
        app = PresenterProServerGUI()
        app.root.protocol("WM_DELETE_WINDOW", app.on_closing)
        app.run()
    except Exception as e:
        print(f"Error: {e}")
        messagebox.showerror("Error", f"Failed to start application: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
