#!/usr/bin/env python3
"""
Test script for touch-based laser pointer
This script tests the server's laser pointer functionality directly
"""

import asyncio
import json
import websockets
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def test_laser_pointer():
    """Test the laser pointer by sending commands to the server"""
    
    # Server details
    server_ip = "localhost"  # Change this to your server IP
    server_port = 8080
    
    try:
        # Connect to server
        uri = f"ws://{server_ip}:{server_port}"
        logger.info(f"Connecting to {uri}")
        
        async with websockets.connect(uri) as websocket:
            logger.info("Connected to server!")
            
            # Wait for welcome message
            welcome = await websocket.recv()
            logger.info(f"Welcome message: {welcome}")
            
            # Test laser pointer move commands
            test_positions = [
                (25, 25),   # Top-left
                (75, 25),   # Top-right
                (50, 50),   # Center
                (25, 75),   # Bottom-left
                (75, 75),   # Bottom-right
            ]
            
            for x, y in test_positions:
                logger.info(f"Testing laser pointer at {x}%, {y}%")
                
                # Send laser pointer move command
                command = {
                    'command': 'laser_pointer_move',
                    'params': {
                        'x_percent': x,
                        'y_percent': y,
                    },
                    'timestamp': asyncio.get_event_loop().time()
                }
                
                await websocket.send(json.dumps(command))
                
                # Wait for response
                response = await websocket.recv()
                logger.info(f"Response: {response}")
                
                # Wait a bit between moves
                await asyncio.sleep(1)
            
            logger.info("Test completed!")
            
    except Exception as e:
        logger.error(f"Test failed: {e}")

if __name__ == "__main__":
    asyncio.run(test_laser_pointer())
