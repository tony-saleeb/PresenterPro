#!/usr/bin/env python3
"""
Manual test script to simulate Flutter app commands
This will help us test the laser pointer without the Flutter app
"""

import asyncio
import json
import websockets
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def test_laser_pointer():
    """Test laser pointer by sending commands to the server"""
    
    # Server URL
    server_url = "ws://localhost:8765"
    
    try:
        logger.info("🔌 Connecting to debug server...")
        async with websockets.connect(server_url) as websocket:
            logger.info("✅ Connected to server!")
            
            # Test 1: Toggle laser pointer
            logger.info("\n🧪 Test 1: Toggle laser pointer")
            command = {"command": "laser_pointer"}
            await websocket.send(json.dumps(command))
            logger.info("📤 Sent: laser_pointer")
            await asyncio.sleep(2)
            
            # Test 2: Move laser pointer around
            logger.info("\n🧪 Test 2: Move laser pointer around")
            test_positions = [
                (25, 25, "Top-left"),
                (75, 25, "Top-right"),
                (50, 50, "Center"),
                (25, 75, "Bottom-left"),
                (75, 75, "Bottom-right"),
            ]
            
            for x, y, description in test_positions:
                command = {
                    "command": "laser_pointer_move",
                    "params": {
                        "x_percent": x,
                        "y_percent": y
                    }
                }
                await websocket.send(json.dumps(command))
                logger.info(f"📤 Sent: laser_pointer_move to {description} ({x}%, {y}%)")
                await asyncio.sleep(1)
            
            # Test 3: Test command
            logger.info("\n🧪 Test 3: Full test command")
            command = {"command": "test_laser_pointer"}
            await websocket.send(json.dumps(command))
            logger.info("📤 Sent: test_laser_pointer")
            await asyncio.sleep(5)
            
            # Test 4: Toggle off
            logger.info("\n🧪 Test 4: Toggle laser pointer off")
            command = {"command": "laser_pointer"}
            await websocket.send(json.dumps(command))
            logger.info("📤 Sent: laser_pointer (toggle off)")
            await asyncio.sleep(2)
            
            logger.info("\n✅ All tests completed!")
            
    except ConnectionRefused:
        logger.error("❌ Could not connect to server. Make sure debug_laser_pointer.py is running.")
    except Exception as e:
        logger.error(f"❌ Error during test: {e}")

def main():
    """Main function"""
    logger.info("=" * 60)
    logger.info("MANUAL LASER POINTER TEST")
    logger.info("=" * 60)
    logger.info("This script will test the laser pointer by sending")
    logger.info("commands to the debug server.")
    logger.info("=" * 60)
    logger.info("Make sure:")
    logger.info("1. PowerPoint is open and in presentation mode (F5)")
    logger.info("2. debug_laser_pointer.py is running")
    logger.info("=" * 60)
    
    input("Press Enter to start the test...")
    
    try:
        asyncio.run(test_laser_pointer())
    except KeyboardInterrupt:
        logger.info("\n🛑 Test cancelled by user")
    except Exception as e:
        logger.error(f"❌ Test error: {e}")

if __name__ == "__main__":
    main()
