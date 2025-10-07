import asyncio
import json
import logging
import socket
import pyautogui
from websockets.server import serve
from websockets.exceptions import ConnectionClosed
from slide_capture_extension import slide_capture, init_slide_capture, on_slide_change, on_keystroke, on_keystroke_force, on_presentation_start, on_presentation_end

# Optimize pyautogui for zero latency
pyautogui.PAUSE = 0.0  # No pause between actions
pyautogui.FAILSAFE = False  # Disable failsafe for maximum speed

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class LaserPointer:
    """Simple laser pointer implementation using mouse cursor"""
    
    def __init__(self):
        self.is_visible = False
        self.screen_width, self.screen_height = pyautogui.size()
        self.current_x = 0
        self.current_y = 0
        
    def init_laser_pointer(self):
        """Initialize the laser pointer"""
        logger.info("🔴 Laser pointer system initialized")
    
    def show(self):
        """Show the laser pointer by enabling PowerPoint laser mode"""
        try:
            if not self.is_visible:
                # Enable PowerPoint laser pointer mode
                pyautogui.hotkey('ctrl', 'l')
                self.is_visible = True
                logger.info("🔴 Laser pointer shown (PowerPoint mode)")
        except Exception as e:
            logger.error(f"❌ Error showing laser pointer: {e}")
    
    def hide(self):
        """Hide the laser pointer"""
        try:
            if self.is_visible:
                # Disable PowerPoint laser pointer mode
                pyautogui.hotkey('ctrl', 'l')
                self.is_visible = False
                logger.info("🔴 Laser pointer hidden")
        except Exception as e:
            logger.error(f"❌ Error hiding laser pointer: {e}")
    
    def move(self, x_percent, y_percent):
        """Move laser pointer to specific coordinates - ZERO LATENCY"""
        try:
            # Convert percentages to actual coordinates (optimized)
            x = int(x_percent * self.screen_width * 0.01)
            y = int(y_percent * self.screen_height * 0.01)
            
            # Move mouse cursor to position (this will show the laser dot in PowerPoint)
            pyautogui.moveTo(x, y, duration=0.0)  # Instant movement
            
        except Exception as e:
            logger.error(f"❌ Error moving laser pointer: {e}")
    
    def cleanup(self):
        """Clean up the laser pointer"""
        try:
            if self.is_visible:
                self.hide()
            logger.info("🔴 Laser pointer cleaned up")
        except Exception as e:
            logger.error(f"❌ Error during laser pointer cleanup: {e}")

class SlideController:
    def __init__(self):
        self.presentation_mode = False
        self.current_slide = 0
        self.connected_clients = set()
        
        # Disable pyautogui's fail-safe feature for presentations
        pyautogui.FAILSAFE = False
        
        # ZERO LATENCY: Minimal pause for maximum speed
        pyautogui.PAUSE = 0.01
        
        # Initialize laser pointer
        self.laser_pointer = LaserPointer()
        self.laser_pointer.init_laser_pointer()
        
        # Initialize slide capture
        init_slide_capture()
        logger.info("🖼️ Slide capture system initialized")
    
    def _is_powerpoint_focused(self):
        """Check if PowerPoint is the active window"""
        try:
            # Try to get active window (this may require additional dependencies)
            active_window = pyautogui.getActiveWindow()
            if active_window:
                window_title = active_window.title.lower()
                # Check if PowerPoint is in the window title
                is_ppt = any(keyword in window_title for keyword in [
                    'powerpoint', 'microsoft powerpoint', 'presentation', '.pptx', '.ppt'
                ])
                if is_ppt:
                    logger.info("✅ PowerPoint window is active and focused")
                    return True
                else:
                    logger.warning(f"⚠️  PowerPoint not focused - Active window: '{active_window.title}'")
                    return False
            else:
                logger.warning("⚠️  Could not detect active window")
                return True  # Assume it's okay if we can't detect
        except Exception as e:
            # Fallback: If we can't detect focus, assume it's okay
            logger.debug(f"Focus detection failed: {e} - Continuing anyway")
            return True
    
    async def next_slide(self):
        """Move to the next slide using keyboard shortcut"""
        logger.info("🎯 NEXT SLIDE command received")
        try:
            # FOCUS VERIFICATION: Ensure PowerPoint is focused
            if not self._is_powerpoint_focused():
                logger.warning("⚠️  PowerPoint may not be focused - Keystroke might not work")
            
            # Try multiple methods for next slide
            logger.info("📡 Sending Right Arrow key...")
            pyautogui.press('right')
            logger.info("✅ Right Arrow key sent successfully")
            
            # SLIDESHOW-ONLY MIRRORING: Only capture during active presentation
            if self.presentation_mode:
                # ANIMATION-AWARE: Always capture after any keystroke to catch animations
                logger.info(f"⚡ SLIDESHOW ACTIVE - Capturing slide/animation change")
                
                # SIMPLE ANIMATION FIX: Single immediate capture with force
                logger.info("⏱️  Starting immediate animation capture")
                
                # Capture immediately after keystroke - FORCE capture
                await asyncio.sleep(0.05)  # Very short wait (50ms)
                await on_keystroke_force(self.connected_clients, self.current_slide)
                logger.info("📸 IMMEDIATE capture after keystroke (forced)")
                
                logger.info("🚀 Immediate animation capture completed")
            else:
                logger.info("ℹ️  Not in slideshow mode - No mirroring needed")
            
            # Alternative method - uncomment if right arrow doesn't work
            # pyautogui.press('space')  # Space bar
            # pyautogui.press('pagedown')  # Page Down
            
        except Exception as e:
            logger.error(f"❌ Error sending next slide command: {e}")
        
    async def previous_slide(self):
        """Move to the previous slide using keyboard shortcut"""
        logger.info("🎯 PREVIOUS SLIDE command received")
        try:
            # FOCUS VERIFICATION: Ensure PowerPoint is focused
            if not self._is_powerpoint_focused():
                logger.warning("⚠️  PowerPoint may not be focused - Keystroke might not work")
            
            # Try multiple methods for previous slide
            logger.info("📡 Sending Left Arrow key...")
            pyautogui.press('left')
            logger.info("✅ Left Arrow key sent successfully")
            
            # SLIDESHOW-ONLY MIRRORING: Only capture during active presentation
            if self.presentation_mode:
                # ANIMATION-AWARE: Always capture after any keystroke to catch animations
                logger.info(f"⚡ SLIDESHOW ACTIVE - Capturing slide/animation change")
                
                # SIMPLE ANIMATION FIX: Single immediate capture with force
                logger.info("⏱️  Starting immediate animation capture")
                
                # Capture immediately after keystroke - FORCE capture
                await asyncio.sleep(0.05)  # Very short wait (50ms)
                await on_keystroke_force(self.connected_clients, self.current_slide)
                logger.info("📸 IMMEDIATE capture after keystroke (forced)")
                
                logger.info("🚀 Immediate animation capture completed")
            else:
                logger.info("ℹ️  Not in slideshow mode - No mirroring needed")
            
            # Alternative method - uncomment if left arrow doesn't work
            # pyautogui.press('backspace')  # Backspace
            # pyautogui.press('pageup')  # Page Up
            
        except Exception as e:
            logger.error(f"❌ Error sending previous slide command: {e}")
    
    async def handle_keystroke(self, key):
        """Handle any keystroke that might trigger animations or slide changes"""
        logger.info(f"⌨️  KEYSTROKE command received: {key}")
        try:
            # FOCUS VERIFICATION: Ensure PowerPoint is focused
            if not self._is_powerpoint_focused():
                logger.warning("⚠️  PowerPoint may not be focused - Keystroke might not work")
            
            # Send the keystroke
            logger.info(f"📡 Sending {key} key...")
            pyautogui.press(key)
            logger.info(f"✅ {key} key sent successfully")
            
            # SLIDESHOW-ONLY MIRRORING: Only capture during active presentation
            if self.presentation_mode:
                # ANIMATION-AWARE: Always capture after any keystroke to catch animations
                logger.info(f"⚡ SLIDESHOW ACTIVE - Capturing slide/animation change after {key}")
                
                # SIMPLE ANIMATION FIX: Single immediate capture with force
                logger.info("⏱️  Starting immediate animation capture")
                
                # Capture immediately after keystroke - FORCE capture
                await asyncio.sleep(0.05)  # Very short wait (50ms)
                await on_keystroke_force(self.connected_clients, self.current_slide)
                logger.info("📸 IMMEDIATE capture after keystroke (forced)")
                
                logger.info("🚀 Immediate animation capture completed")
            else:
                logger.info("ℹ️  Not in slideshow mode - No mirroring needed")
            
        except Exception as e:
            logger.error(f"❌ Error sending {key} command: {e}")
        
    async def start_presentation(self):
        """Start presentation mode using F5 (PowerPoint) or Ctrl+F5 (Google Slides)"""
        logger.info("🎯 START PRESENTATION command received")
        try:
            logger.info("📡 Sending F5 key...")
            pyautogui.press('f5')  # F5 to start slideshow
            logger.info("✅ F5 key sent successfully")
            
            # PROPER SLIDESHOW RESET: Always start fresh
            self.presentation_mode = True
            self.current_slide = 1  # Always reset to slide 1 when starting
            logger.info(f"🎮 Presentation mode activated - RESET to slide {self.current_slide}")
            
            # ZERO LATENCY: Instant presentation capture
            logger.info(f"⚡ SLIDESHOW STARTED - Broadcasting first slide to {len(self.connected_clients)} clients")
            asyncio.create_task(on_presentation_start(self.connected_clients))
            logger.info("🚀 SLIDESHOW mirroring activated")
            
        except Exception as e:
            logger.error(f"❌ Error starting presentation: {e}")
        
    async def end_presentation(self):
        """End presentation mode using Escape key"""
        logger.info("🎯 END PRESENTATION command received")
        try:
            logger.info("📡 Sending Escape key...")
            pyautogui.press('esc')  # Escape to end slideshow
            logger.info("✅ Escape key sent successfully")
            
            # PROPER SLIDESHOW CLEANUP: Complete reset
            self.presentation_mode = False
            self.current_slide = 0  # Reset counter completely
            logger.info("🛑 SLIDESHOW ENDED - Presentation mode deactivated, counter RESET")
            
            # Stop slide capture and notify clients
            await on_presentation_end(self.connected_clients)
            logger.info("📱 Slide mirroring STOPPED - All clients notified")
            
        except Exception as e:
            logger.error(f"❌ Error ending presentation: {e}")
    
    def laser_pointer(self):
        """Toggle laser pointer visibility"""
        logger.info("🔴 LASER POINTER toggle command received")
        try:
            if self.laser_pointer.is_visible:
                self.laser_pointer.hide()
                logger.info("✅ Laser pointer hidden")
            else:
                self.laser_pointer.show()
                logger.info("✅ Laser pointer shown")
        except Exception as e:
            logger.error(f"❌ Error toggling laser pointer: {e}")

    def laser_pointer_move(self, x_percent, y_percent):
        """Move laser pointer to specific screen coordinates based on percentages"""
        try:
            # Zero-latency: No logging during movement
            
            # Ensure laser pointer is visible when moving (only log once)
            if not self.laser_pointer.is_visible:
                self.laser_pointer.show()
            
            # Move the laser pointer
            self.laser_pointer.move(x_percent, y_percent)
            
        except Exception as e:
            logger.error(f"❌ Error moving laser pointer: {e}")
    
    def test_laser_pointer(self):
        """Test the laser pointer by moving it around the screen"""
        logger.info("🧪 Testing laser pointer...")
        try:
            # Show laser pointer
            self.laser_pointer.show()
            
            # Test positions
            test_positions = [
                (25, 25),   # Top-left
                (75, 25),   # Top-right
                (50, 50),   # Center
                (25, 75),   # Bottom-left
                (75, 75),   # Bottom-right
            ]
            
            for x, y in test_positions:
                self.laser_pointer.move(x, y)
                logger.info(f"🧪 Test position: {x}%, {y}%")
                pyautogui.sleep(0.5)  # Wait between movements
            
            logger.info("🧪 Laser pointer test completed")
            
        except Exception as e:
            logger.error(f"❌ Error testing laser pointer: {e}")

    def laser_pointer_click(self, x_percent, y_percent):
        """Click at specific coordinates (useful for highlighting)"""
        try:
            # Get screen dimensions
            screen_width, screen_height = pyautogui.size()
            
            # Convert percentages to actual coordinates
            x = int((x_percent / 100.0) * screen_width)
            y = int((y_percent / 100.0) * screen_height)
            
            # Click at the position
            pyautogui.click(x, y)
            logger.info(f"👆 Laser pointer clicked at ({x}, {y}) - {x_percent:.1f}%, {y_percent:.1f}%")
            
        except Exception as e:
            logger.error(f"❌ Error clicking laser pointer: {e}")
    
    def black_screen(self):
        """Black out the screen (B key in most presentation software)"""
        logger.info("⚫ BLACK SCREEN command received")
        try:
            pyautogui.press('b')  # B key for black screen
            logger.info("✅ Black screen toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling black screen: {e}")
    
    def white_screen(self):
        """White out the screen (W key in most presentation software)"""
        logger.info("⚪ WHITE SCREEN command received")
        try:
            pyautogui.press('w')  # W key for white screen
            logger.info("✅ White screen toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling white screen: {e}")
    
    def presentation_view(self):
        """Toggle presentation view (Alt+F5 or Ctrl+F5)"""
        logger.info("📺 PRESENTATION VIEW command received")
        try:
            pyautogui.hotkey('alt', 'f5')  # Alt+F5 for presenter view
            logger.info("✅ Presentation view toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling presentation view: {e}")
    
    def volume_up(self):
        """Increase system volume"""
        logger.info("🔊 VOLUME UP command received")
        try:
            pyautogui.press('volumeup')
            logger.info("✅ Volume increased")
        except Exception as e:
            logger.error(f"❌ Error increasing volume: {e}")
    
    def volume_down(self):
        """Decrease system volume"""
        logger.info("🔉 VOLUME DOWN command received")
        try:
            pyautogui.press('volumedown')
            logger.info("✅ Volume decreased")
        except Exception as e:
            logger.error(f"❌ Error decreasing volume: {e}")
    
    def mute(self):
        """Toggle system mute"""
        logger.info("🔇 MUTE command received")
        try:
            pyautogui.press('volumemute')
            logger.info("✅ Mute toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling mute: {e}")
    
    def first_slide(self):
        """Go to first slide (Home key)"""
        logger.info("⏮️ FIRST SLIDE command received")
        try:
            pyautogui.press('home')
            logger.info("✅ Moved to first slide")
        except Exception as e:
            logger.error(f"❌ Error going to first slide: {e}")
    
    def last_slide(self):
        """Go to last slide (End key)"""
        logger.info("⏭️ LAST SLIDE command received")
        try:
            pyautogui.press('end')
            logger.info("✅ Moved to last slide")
        except Exception as e:
            logger.error(f"❌ Error going to last slide: {e}")
    
    def full_screen(self):
        """Enter full screen mode (F11)"""
        logger.info("🖥️ FULL SCREEN command received")
        try:
            pyautogui.press('f11')
            logger.info("✅ Entered full screen")
        except Exception as e:
            logger.error(f"❌ Error entering full screen: {e}")
    
    def exit_full_screen(self):
        """Exit full screen mode (F11 or Esc)"""
        logger.info("🖥️ EXIT FULL SCREEN command received")
        try:
            pyautogui.press('f11')  # F11 toggles, or use Esc
            logger.info("✅ Exited full screen")
        except Exception as e:
            logger.error(f"❌ Error exiting full screen: {e}")
        
    async def handle_command(self, command, params=None):
        """Handle incoming commands from the mobile app"""
        # Async commands that need slide capture
        async_commands = {
            'next': self.next_slide,
            'previous': self.previous_slide,
            'start_presentation': self.start_presentation,
            'end_presentation': self.end_presentation,
            'keystroke': self.handle_keystroke,
        }
        
        # Sync commands
        sync_commands = {
            'laser_pointer': self.laser_pointer,
            'laser_pointer_move': self.laser_pointer_move,
            'laser_pointer_click': self.laser_pointer_click,
            'test_laser_pointer': self.test_laser_pointer,
            'black_screen': self.black_screen,
            'white_screen': self.white_screen,
            'presentation_view': self.presentation_view,
            'volume_up': self.volume_up,
            'volume_down': self.volume_down,
            'mute': self.mute,
            'first_slide': self.first_slide,
            'last_slide': self.last_slide,
            'full_screen': self.full_screen,
            'exit_full_screen': self.exit_full_screen,
        }
        
        if command in async_commands:
            try:
                # Handle commands that need parameters
                if command == 'keystroke' and params:
                    key = params.get('key', 'space')
                    await async_commands[command](key)
                else:
                    await async_commands[command]()
                return {'status': 'success', 'command': command}
            except Exception as e:
                logger.error(f"Error executing async command {command}: {e}")
                return {'status': 'error', 'message': str(e)}
        elif command in sync_commands:
            try:
                # Handle commands that need parameters
                if command in ['laser_pointer_move', 'laser_pointer_click'] and params:
                    x_percent = params.get('x_percent', 50)
                    y_percent = params.get('y_percent', 50)
                    sync_commands[command](x_percent, y_percent)
                else:
                    sync_commands[command]()
                return {'status': 'success', 'command': command}
            except Exception as e:
                logger.error(f"Error executing sync command {command}: {e}")
                return {'status': 'error', 'message': str(e)}
        else:
            return {'status': 'error', 'message': f'Unknown command: {command}'}

class SlideControllerServer:
    def __init__(self, host='0.0.0.0', port=8080):
        self.host = host
        self.port = port
        self.controller = SlideController()
        self.connected_clients = set()
        # Share connected clients with controller for slide capture
        self.controller.connected_clients = self.connected_clients
        
    def get_local_ip(self):
        """Get the local IP address of the machine"""
        try:
            # Connect to a remote address to determine local IP
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.connect(("8.8.8.8", 80))
                local_ip = s.getsockname()[0]
                return local_ip
        except Exception:
            return "localhost"
    
    async def handle_client(self, websocket, path):
        """Handle WebSocket connections from mobile clients"""
        client_address = websocket.remote_address
        logger.info(f"New client connected: {client_address}")
        self.connected_clients.add(websocket)
        
        try:
            # Send welcome message
            welcome_message = {
                'type': 'welcome',
                'message': 'Connected to Slide Controller Server',
                'server_info': {
                    'version': '1.0.0',
                    'presentation_mode': self.controller.presentation_mode,
                    'current_slide': self.controller.current_slide
                }
            }
            await websocket.send(json.dumps(welcome_message))
            
            async for message in websocket:
                try:
                    data = json.loads(message)
                    logger.info(f"📱 Received message from {client_address}: {data}")
                    
                    # Handle different message types
                    if data.get('type') == 'heartbeat':
                        # Respond to heartbeat with pong
                        pong_response = {
                            'type': 'pong',
                            'timestamp': data.get('timestamp'),
                            'server_time': asyncio.get_event_loop().time()
                        }
                        await websocket.send(json.dumps(pong_response))
                    elif 'command' in data:
                        command = data['command']
                        params = data.get('params', {})
                        logger.info(f"🎯 Processing command: {command} with params: {params}")
                        # Skip heartbeat commands completely
                        if not data.get('heartbeat', False):
                            response = await self.controller.handle_command(command, params)
                            response['timestamp'] = data.get('timestamp')
                            logger.info(f"🎯 Command response: {response}")
                            await websocket.send(json.dumps(response))
                            
                            # Broadcast status to all connected clients
                            if response['status'] == 'success':
                                status_update = {
                                    'type': 'status_update',
                                    'presentation_mode': self.controller.presentation_mode,
                                    'current_slide': self.controller.current_slide,
                                    'last_command': data['command']
                                }
                                await self.broadcast_to_clients(status_update, exclude=websocket)
                    
                except json.JSONDecodeError:
                    error_response = {'status': 'error', 'message': 'Invalid JSON format'}
                    await websocket.send(json.dumps(error_response))
                except Exception as e:
                    error_response = {'status': 'error', 'message': str(e)}
                    await websocket.send(json.dumps(error_response))
                    logger.error(f"Error handling message: {e}")
                    
        except ConnectionClosed:
            logger.info(f"Client {client_address} disconnected")
        except Exception as e:
            logger.error(f"Error with client {client_address}: {e}")
        finally:
            self.connected_clients.discard(websocket)
            
    async def broadcast_to_clients(self, message, exclude=None):
        """Broadcast a message to all connected clients"""
        if not self.connected_clients:
            return
            
        message_str = json.dumps(message)
        disconnected_clients = set()
        
        for client in self.connected_clients:
            if client == exclude:
                continue
                
            try:
                await client.send(message_str)
            except ConnectionClosed:
                disconnected_clients.add(client)
            except Exception as e:
                logger.error(f"Error broadcasting to client: {e}")
                disconnected_clients.add(client)
        
        # Remove disconnected clients
        self.connected_clients -= disconnected_clients
    
    def cleanup(self):
        """Clean up resources when server shuts down"""
        try:
            if hasattr(self, 'laser_pointer'):
                self.laser_pointer.cleanup()
                logger.info("🔴 Laser pointer cleaned up")
        except Exception as e:
            logger.error(f"❌ Error during cleanup: {e}")
    
    async def start_server(self):
        """Start the WebSocket server"""
        local_ip = self.get_local_ip()
        
        logger.info("=" * 60)
        logger.info("SLIDE CONTROLLER SERVER STARTING")
        logger.info("=" * 60)
        logger.info(f"Server running on: {local_ip}:{self.port}")
        logger.info(f"WebSocket URL: ws://{local_ip}:{self.port}")
        logger.info("=" * 60)
        logger.info("POWERPOINT SETUP INSTRUCTIONS:")
        logger.info("1. Open PowerPoint presentation")
        logger.info("2. Click on the PowerPoint window to make it active")
        logger.info("3. Connect your phone using the IP above")
        logger.info("4. Tap 'Start' in the app to begin slideshow (F5)")
        logger.info("5. Swipe left/right to control slides")
        logger.info("=" * 60)
        logger.info("TROUBLESHOOTING TIPS:")
        logger.info("• Make sure PowerPoint window is in FOCUS (click on it)")
        logger.info("• Start slideshow mode first (F5 or Start button)")
        logger.info("• Test manually: F5 → Right Arrow → Left Arrow → Esc")
        logger.info("• If not working, try closing other programs")
        logger.info("=" * 60)
        logger.info("KEYBOARD SHORTCUTS USED:")
        logger.info("• F5: Start presentation")
        logger.info("• Esc: End presentation")
        logger.info("• Right Arrow: Next slide")
        logger.info("• Left Arrow: Previous slide")
        logger.info("=" * 60)
        logger.info("Press Ctrl+C to stop the server")
        logger.info("=" * 60)
        
        try:
            async with serve(self.handle_client, self.host, self.port):
                logger.info("Server started successfully!")
                # Create a future that runs forever until cancelled
                await asyncio.Future()  # Run forever
        except asyncio.CancelledError:
            logger.info("Server shutdown requested")
            raise
        except Exception as e:
            logger.error(f"Server error: {e}")
            raise

def main():
    """Main function to start the server"""
    server = SlideControllerServer()
    
    try:
        asyncio.run(server.start_server())
    except KeyboardInterrupt:
        logger.info("\n" + "=" * 60)
        logger.info("🛑 Server stopped by user")
        logger.info("=" * 60)
        server.controller.cleanup()
    except Exception as e:
        logger.error(f"Server error: {e}")
        server.controller.cleanup()

if __name__ == "__main__":
    main()
