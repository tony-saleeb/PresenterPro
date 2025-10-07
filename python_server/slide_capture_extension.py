#!/usr/bin/env python3
"""
Slide Capture Extension for Slide Controller Server
Adds screenshot capture functionality for live slide mirroring.
"""

import io
import base64
import logging
from PIL import Image, ImageGrab, ImageChops
import asyncio
import json
import hashlib

logger = logging.getLogger(__name__)

class SlideCaptureExtension:
    def __init__(self):
        self.capture_enabled = False
        self.capture_quality = 70  # Better quality for readable text
        self.capture_scale = 0.6   # Larger size for better visibility
        self.last_screenshot_time = 0
        self.screenshot_cache = None
        self.last_screenshot_hash = None  # For duplicate detection
        self.last_screenshot_data = None  # Store last screenshot data
        
        logger.info("⚡ ZERO-LATENCY Slide Capture Extension with CHANGE DETECTION initialized")
    
    def enable_capture(self, enabled=True):
        """Enable or disable slide capture"""
        self.capture_enabled = enabled
        
        # Reset hash when capture mode changes
        if enabled:
            self.last_screenshot_hash = None  # Reset to detect first slide as changed
            logger.info("📸 Slide capture ENABLED - Hash reset for fresh start")
        else:
            logger.info("📸 Slide capture DISABLED")
            # Optionally reset hash when disabled
            self.last_screenshot_hash = None
    
    def set_capture_quality(self, quality):
        """Set JPEG compression quality (1-100, higher = better quality)"""
        self.capture_quality = max(1, min(100, quality))
        logger.info(f"🎚️ Capture quality set to {self.capture_quality}%")
    
    def set_capture_scale(self, scale):
        """Set image scaling factor (0.1-1.0, smaller = faster transfer)"""
        self.capture_scale = max(0.1, min(1.0, scale))
        logger.info(f"📏 Capture scale set to {self.capture_scale}x")
    
    def _calculate_image_hash(self, image_data):
        """Calculate MD5 hash of image data for duplicate detection"""
        return hashlib.md5(image_data).hexdigest()
    
    def _has_slide_changed(self, new_image_data):
        """Check if the slide has actually changed by comparing image hashes"""
        new_hash = self._calculate_image_hash(new_image_data)
        
        if self.last_screenshot_hash is None:
            # First screenshot, always consider it changed
            self.last_screenshot_hash = new_hash
            return True
        
        if new_hash != self.last_screenshot_hash:
            # Slide has changed (including animations)
            self.last_screenshot_hash = new_hash
            logger.info("🔄 SLIDE/ANIMATION CHANGE DETECTED - New content found")
            return True
        else:
            # Same slide content - but for animations, we might want to force capture
            logger.info("⏸️  NO VISUAL CHANGE - Same content detected, skipping broadcast")
            return False
    
    def force_capture(self):
        """Force a capture even if content appears unchanged (for subtle animations)"""
        logger.info("🎬 FORCING CAPTURE - Animation might be too subtle for hash detection")
        # Reset hash to force next capture to be considered changed
        self.last_screenshot_hash = None
    
    async def capture_slide_screenshot(self):
        """Capture current screen and return as base64 encoded image"""
        if not self.capture_enabled:
            logger.debug("📸 Capture disabled - Slideshow not active")
            return None
        
        try:
            # Capture screenshot
            screenshot = ImageGrab.grab()
            
            # Scale down for faster transfer
            if self.capture_scale != 1.0:
                new_size = (
                    int(screenshot.width * self.capture_scale),
                    int(screenshot.height * self.capture_scale)
                )
                screenshot = screenshot.resize(new_size, Image.Resampling.LANCZOS)  # Better quality resize
            
            # HIGH QUALITY: Better JPEG with optimization
            buffer = io.BytesIO()
            screenshot.save(buffer, format='JPEG', quality=self.capture_quality, optimize=True)
            buffer.seek(0)
            
            # Get raw image data for change detection
            raw_image_data = buffer.getvalue()
            
            # CRITICAL: Check if slide has actually changed
            if not self._has_slide_changed(raw_image_data):
                # Same slide detected - don't send duplicate
                return "UNCHANGED"  # Special flag to indicate no change
            
            # Encode to base64
            image_base64 = base64.b64encode(raw_image_data).decode('utf-8')
            
            # Create data URL
            data_url = f"data:image/jpeg;base64,{image_base64}"
            
            logger.info(f"⚡ NEW SLIDE captured and ready: {len(data_url)} bytes")
            return data_url
            
        except Exception as e:
            logger.error(f"❌ Screenshot capture failed: {e}")
            return None
    
    async def create_slide_message(self, slide_number=None):
        """Create a slide update message with screenshot"""
        screenshot_data = await self.capture_slide_screenshot()
        
        # Handle unchanged slides
        if screenshot_data == "UNCHANGED":
            logger.info("🚫 SKIPPING BROADCAST - No slide change detected")
            return None  # Don't create message for unchanged slides
        
        message = {
            'type': 'slide_update',
            'timestamp': asyncio.get_event_loop().time(),
            'slide_number': slide_number,
            'has_image': screenshot_data is not None and screenshot_data != "UNCHANGED"
        }
        
        if screenshot_data and screenshot_data != "UNCHANGED":
            message['image_data'] = screenshot_data
            message['image_format'] = 'jpeg'
            message['image_scale'] = self.capture_scale
            message['image_quality'] = self.capture_quality
        
        return message
    
    async def broadcast_slide_update(self, websockets_clients, slide_number=None):
        """Broadcast slide update to all connected clients"""
        if not websockets_clients:
            logger.debug("📡 No clients connected - Skipping broadcast")
            return
        if not self.capture_enabled:
            logger.debug("📡 Capture disabled - No slideshow mirroring needed")
            return
        
        try:
            message = await self.create_slide_message(slide_number)
            
            # Skip broadcast if no change detected
            if message is None:
                logger.info("⏸️  BROADCAST SKIPPED - Slide unchanged, preventing duplicate mirroring")
                return
            
            message_json = json.dumps(message)
            
            # Send to all connected clients
            disconnected_clients = set()
            for client in websockets_clients:
                try:
                    await client.send(message_json)
                except Exception as e:
                    logger.warning(f"📱 Failed to send slide update to client: {e}")
                    disconnected_clients.add(client)
            
            # Remove disconnected clients
            for client in disconnected_clients:
                websockets_clients.discard(client)
            
            logger.info(f"⚡ INSTANT broadcast to {len(websockets_clients)} clients - NEW SLIDE CONFIRMED")
            
        except Exception as e:
            logger.error(f"❌ Failed to broadcast slide update: {e}")

# Global instance for easy integration
slide_capture = SlideCaptureExtension()

# Integration functions for the main server
def init_slide_capture():
    """Initialize slide capture (call this in main server startup)"""
    slide_capture.enable_capture(True)
    slide_capture.set_capture_quality(70)  # Better quality for readable text
    slide_capture.set_capture_scale(0.6)   # 60% size for better visibility
    logger.info("⚡ HIGH-QUALITY Slide Capture Extension ready!")

async def on_slide_change(websockets_clients, slide_number):
    """Call this when slides change to broadcast updates"""
    await slide_capture.broadcast_slide_update(websockets_clients, slide_number)

async def on_keystroke(websockets_clients, slide_number):
    """Call this after any keystroke to capture animations and slide changes"""
    logger.info("⌨️  Keystroke detected - Capturing for animations/slide changes")
    await slide_capture.broadcast_slide_update(websockets_clients, slide_number)

async def on_keystroke_force(websockets_clients, slide_number):
    """Call this after any keystroke to force capture animations (even if hash is same)"""
    logger.info("⌨️  Keystroke detected - FORCING capture for subtle animations")
    slide_capture.force_capture()  # Force capture even if hash is same
    await slide_capture.broadcast_slide_update(websockets_clients, slide_number)

async def on_presentation_start(websockets_clients):
    """Call this when presentation starts"""
    logger.info("🎬 SLIDESHOW STARTED - Enabling slide capture")
    slide_capture.enable_capture(True)
    await slide_capture.broadcast_slide_update(websockets_clients, 1)

async def on_presentation_end(websockets_clients):
    """Call this when presentation ends"""
    logger.info("🛑 SLIDESHOW ENDED - Disabling slide capture")
    slide_capture.enable_capture(False)
    # Send end message
    end_message = {
        'type': 'presentation_end',
        'timestamp': asyncio.get_event_loop().time()
    }
    message_json = json.dumps(end_message)
    
    for client in list(websockets_clients):
        try:
            await client.send(message_json)
            logger.info("📱 Client notified: Slideshow ended")
        except:
            websockets_clients.discard(client)
