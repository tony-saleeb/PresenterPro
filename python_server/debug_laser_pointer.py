#!/usr/bin/env python3
"""
Debug script to test laser pointer commands
This will help us see if the server is receiving the commands correctly
"""

import asyncio
import json
import logging
import pyautogui
from websockets.server import serve
from websockets.exceptions import ConnectionClosed

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DebugLaserPointer:
    def __init__(self):
        self.connected_clients = set()
        self.laser_visible = False
        
    async def handle_client(self, websocket, path):
        """Handle WebSocket client connections"""
        client_id = f"{websocket.remote_address[0]}:{websocket.remote_address[1]}"
        logger.info(f"🔌 Client connected: {client_id}")
        
        self.connected_clients.add(websocket)
        
        try:
            async for message in websocket:
                try:
                    data = json.loads(message)
                    command = data.get('command')
                    params = data.get('params', {})
                    
                    logger.info(f"📨 Received command: {command} with params: {params}")
                    
                    # Handle laser pointer commands
                    if command == 'laser_pointer':
                        await self.handle_laser_pointer_toggle()
                    elif command == 'laser_pointer_move':
                        x_percent = params.get('x_percent', 50)
                        y_percent = params.get('y_percent', 50)
                        await self.handle_laser_pointer_move(x_percent, y_percent)
                    elif command == 'test_laser_pointer':
                        await self.handle_test_laser_pointer()
                    else:
                        logger.info(f"❓ Unknown command: {command}")
                        
                except json.JSONDecodeError:
                    logger.error(f"❌ Invalid JSON received: {message}")
                except Exception as e:
                    logger.error(f"❌ Error processing message: {e}")
                    
        except ConnectionClosed:
            logger.info(f"🔌 Client disconnected: {client_id}")
        except Exception as e:
            logger.error(f"❌ Client error: {e}")
        finally:
            self.connected_clients.discard(websocket)
    
    async def handle_laser_pointer_toggle(self):
        """Toggle laser pointer visibility"""
        try:
            if self.laser_visible:
                # Disable laser pointer
                pyautogui.hotkey('ctrl', 'l')
                self.laser_visible = False
                logger.info("🔴 Laser pointer DISABLED")
            else:
                # Enable laser pointer
                pyautogui.hotkey('ctrl', 'l')
                self.laser_visible = True
                logger.info("🔴 Laser pointer ENABLED")
        except Exception as e:
            logger.error(f"❌ Error toggling laser pointer: {e}")
    
    async def handle_laser_pointer_move(self, x_percent, y_percent):
        """Move laser pointer to specific coordinates"""
        try:
            # Get screen dimensions
            screen_width, screen_height = pyautogui.size()
            
            # Convert percentages to actual coordinates
            x = int((x_percent / 100.0) * screen_width)
            y = int((y_percent / 100.0) * screen_height)
            
            # Move mouse cursor to position
            pyautogui.moveTo(x, y, duration=0.0)
            
            logger.info(f"🔴 Laser pointer moved to {x_percent:.1f}%, {y_percent:.1f}% ({x}, {y})")
            
        except Exception as e:
            logger.error(f"❌ Error moving laser pointer: {e}")
    
    async def handle_test_laser_pointer(self):
        """Test laser pointer by moving it around"""
        logger.info("🧪 Starting laser pointer test...")
        
        try:
            # Enable laser pointer
            if not self.laser_visible:
                pyautogui.hotkey('ctrl', 'l')
                self.laser_visible = True
                await asyncio.sleep(0.5)
            
            # Test positions
            test_positions = [
                (25, 25, "Top-left"),
                (75, 25, "Top-right"),
                (50, 50, "Center"),
                (25, 75, "Bottom-left"),
                (75, 75, "Bottom-right"),
            ]
            
            for x, y, description in test_positions:
                await self.handle_laser_pointer_move(x, y)
                logger.info(f"🧪 Test position: {description}")
                await asyncio.sleep(1)
            
            logger.info("🧪 Laser pointer test completed!")
            
        except Exception as e:
            logger.error(f"❌ Error during test: {e}")
    
    async def start_server(self):
        """Start the debug server"""
        logger.info("=" * 60)
        logger.info("DEBUG LASER POINTER SERVER STARTING")
        logger.info("=" * 60)
        logger.info("Server running on: localhost:8765")
        logger.info("WebSocket URL: ws://localhost:8765")
        logger.info("=" * 60)
        logger.info("INSTRUCTIONS:")
        logger.info("1. Open PowerPoint and start presentation (F5)")
        logger.info("2. Connect your Flutter app to localhost:8765")
        logger.info("3. Try the laser pointer button")
        logger.info("4. Watch the logs for commands")
        logger.info("=" * 60)
        
        async with serve(self.handle_client, "localhost", 8765):
            logger.info("✅ Debug server started successfully!")
            await asyncio.Future()  # Run forever

def main():
    """Main function"""
    server = DebugLaserPointer()
    
    try:
        asyncio.run(server.start_server())
    except KeyboardInterrupt:
        logger.info("\n🛑 Debug server stopped by user")
    except Exception as e:
        logger.error(f"❌ Server error: {e}")

if __name__ == "__main__":
    main()
