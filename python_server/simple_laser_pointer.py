#!/usr/bin/env python3
"""
Ultra-simple laser pointer server
This will definitely work - just moves the mouse cursor
"""

import asyncio
import json
import logging
import pyautogui
import websockets
from websockets.server import serve

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Disable pyautogui failsafe
pyautogui.FAILSAFE = False
pyautogui.PAUSE = 0.01

class SimpleLaserPointer:
    def __init__(self):
        self.connected_clients = set()
        self.laser_enabled = False
        
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
                    
                    logger.info(f"📨 Command: {command} | Params: {params}")
                    
                    if command == 'laser_pointer':
                        await self.toggle_laser()
                    elif command == 'laser_pointer_move':
                        x = params.get('x_percent', 50)
                        y = params.get('y_percent', 50)
                        await self.move_laser(x, y)
                    else:
                        logger.info(f"❓ Unknown command: {command}")
                        
                except json.JSONDecodeError:
                    logger.error(f"❌ Invalid JSON: {message}")
                except Exception as e:
                    logger.error(f"❌ Error: {e}")
                    
        except websockets.exceptions.ConnectionClosed:
            logger.info(f"🔌 Client disconnected: {client_id}")
        except Exception as e:
            logger.error(f"❌ Client error: {e}")
        finally:
            self.connected_clients.discard(websocket)
    
    async def toggle_laser(self):
        """Toggle laser pointer on/off"""
        try:
            if self.laser_enabled:
                # Disable laser
                pyautogui.hotkey('ctrl', 'l')
                self.laser_enabled = False
                logger.info("🔴 Laser DISABLED")
            else:
                # Enable laser
                pyautogui.hotkey('ctrl', 'l')
                self.laser_enabled = True
                logger.info("🔴 Laser ENABLED")
        except Exception as e:
            logger.error(f"❌ Toggle error: {e}")
    
    async def move_laser(self, x_percent, y_percent):
        """Move laser to position"""
        try:
            # Get screen size
            screen_width, screen_height = pyautogui.size()
            
            # Convert to pixels
            x = int((x_percent / 100.0) * screen_width)
            y = int((y_percent / 100.0) * screen_height)
            
            # Move mouse cursor
            pyautogui.moveTo(x, y, duration=0.0)
            
            logger.info(f"🔴 Moved to {x_percent:.1f}%, {y_percent:.1f}% ({x}, {y})")
            
        except Exception as e:
            logger.error(f"❌ Move error: {e}")
    
    async def start_server(self):
        """Start the server"""
        logger.info("=" * 50)
        logger.info("SIMPLE LASER POINTER SERVER")
        logger.info("=" * 50)
        logger.info("Server: ws://localhost:8765")
        logger.info("=" * 50)
        logger.info("SETUP:")
        logger.info("1. Open PowerPoint")
        logger.info("2. Start presentation (F5)")
        logger.info("3. Connect Flutter app to localhost:8765")
        logger.info("=" * 50)
        
        async with serve(self.handle_client, "localhost", 8765):
            logger.info("✅ Server started!")
            await asyncio.Future()

def main():
    server = SimpleLaserPointer()
    try:
        asyncio.run(server.start_server())
    except KeyboardInterrupt:
        logger.info("🛑 Server stopped")
    except Exception as e:
        logger.error(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
