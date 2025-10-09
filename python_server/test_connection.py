#!/usr/bin/env python3
"""
Quick test script to verify the server is running and accepting connections
"""

import asyncio
import websockets
import sys

async def test_connection(ip, port=8080):
    """Test connection to the server"""
    try:
        uri = f"ws://{ip}:{port}"
        print(f"Testing connection to: {uri}")
        
        async with websockets.connect(uri) as websocket:
            print("✅ Connection successful!")
            
            # Send a test message
            test_message = {
                "command": "test",
                "params": {},
                "timestamp": 1234567890
            }
            
            await websocket.send(str(test_message))
            print("✅ Test message sent!")
            
            # Wait for response
            response = await asyncio.wait_for(websocket.recv(), timeout=5.0)
            print(f"✅ Response received: {response}")
            
            return True
            
    except asyncio.TimeoutError:
        print("❌ Connection timeout - server not responding")
        return False
    except ConnectionRefusedError:
        print("❌ Connection refused - server not running")
        return False
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return False

async def main():
    if len(sys.argv) != 2:
        print("Usage: python test_connection.py <server_ip>")
        print("Example: python test_connection.py 192.168.1.4")
        sys.exit(1)
    
    ip = sys.argv[1]
    success = await test_connection(ip)
    
    if success:
        print("\n🎉 Server is working correctly!")
        print("📱 You can now connect from your phone!")
    else:
        print("\n💥 Server connection test failed!")
        print("🔧 Make sure the server is running and accessible")

if __name__ == "__main__":
    asyncio.run(main())
