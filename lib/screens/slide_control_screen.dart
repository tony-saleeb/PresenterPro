import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';
import 'advanced_controls_screen.dart';
import 'settings_screen.dart';
import 'qr_scanner_screen.dart';
import 'touch_laser_pointer.dart';

class SlideControlScreen extends StatefulWidget {
  const SlideControlScreen({super.key});

  @override
  State<SlideControlScreen> createState() => _SlideControlScreenState();
}

class _SlideControlScreenState extends State<SlideControlScreen> {
  
  @override
  void initState() {
    super.initState();
    // Load settings when the app starts
    context.read<SlideControllerBloc>().add(LoadSettings());
  }

  @override
  void dispose() {
    super.dispose();
  }


  // Portrait mode touch handling (using DragDetails)
  void _handleLaserPointerStartPortrait(BuildContext context, DragStartDetails details, SlideControllerState state) {
    print('🎯 Laser pointer tracking started at: ${details.globalPosition}');
    _sendLaserPointerPositionPortrait(context, details.globalPosition, state);
    HapticFeedback.lightImpact();
  }

  void _handleLaserPointerMovePortrait(BuildContext context, DragUpdateDetails details, SlideControllerState state) {
    // Send position updates in real-time as finger moves
    _sendLaserPointerPositionPortrait(context, details.globalPosition, state);
  }

  void _handleLaserPointerEndPortrait(BuildContext context, DragEndDetails details, SlideControllerState state) {
    print('🎯 Laser pointer tracking ended');
    HapticFeedback.lightImpact();
  }

  // Landscape mode gesture handling (using DragDetails with RepaintBoundary)
  void _handleLaserPointerStartGesture(BuildContext context, DragStartDetails details, SlideControllerState state) {
    print('🎯 Laser pointer tracking started at: ${details.globalPosition}');
    _sendLaserPointerPositionGesture(context, details.globalPosition, state);
    HapticFeedback.lightImpact();
  }

  void _handleLaserPointerMoveGesture(BuildContext context, DragUpdateDetails details, SlideControllerState state) {
    // Send position updates in real-time as finger moves
    _sendLaserPointerPositionGesture(context, details.globalPosition, state);
  }

  void _handleLaserPointerEndGesture(BuildContext context, DragEndDetails details, SlideControllerState state) {
    print('🎯 Laser pointer tracking ended');
    HapticFeedback.lightImpact();
  }


  void _sendLaserPointerPositionPortrait(BuildContext context, Offset globalPosition, SlideControllerState state) {
    // Calculate the position relative to the slide preview area
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(globalPosition);
    
    // Get the slide preview area size
    final slidePreviewSize = renderBox.size;
    
    // Calculate percentage position (0-100) - simpler for portrait mode
    final xPercent = (localPosition.dx / slidePreviewSize.width) * 100;
    final yPercent = (localPosition.dy / slidePreviewSize.height) * 100;
    
    // Clamp to valid range
    final clampedX = xPercent.clamp(0.0, 100.0);
    final clampedY = yPercent.clamp(0.0, 100.0);
    
    print('🎯 Portrait touch at: (${localPosition.dx.toStringAsFixed(1)}, ${localPosition.dy.toStringAsFixed(1)})');
    print('🎯 Portrait percentage: (${clampedX.toStringAsFixed(1)}%, ${clampedY.toStringAsFixed(1)}%)');
    
    // Send laser pointer position to server
    context.read<SlideControllerBloc>().add(MovePointer(x: clampedX, y: clampedY));
  }

  void _sendLaserPointerPositionGesture(BuildContext context, Offset globalPosition, SlideControllerState state) {
    // Calculate the position relative to the slide preview area
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(globalPosition);
    
    // Get the slide preview area size
    final slidePreviewSize = renderBox.size;
    
    // For landscape mode with BoxFit.contain, we need to account for the actual image bounds
    // The image maintains aspect ratio and is centered, so we need to map to the actual image area
    final screenWidth = slidePreviewSize.width;
    final screenHeight = slidePreviewSize.height;
    
    // Calculate the actual image bounds (assuming 16:9 aspect ratio for slides)
    // This is a reasonable assumption for most PowerPoint slides
    final imageAspectRatio = 16.0 / 9.0;
    final screenAspectRatio = screenWidth / screenHeight;
    
    double imageWidth, imageHeight, imageOffsetX, imageOffsetY;
    
    if (screenAspectRatio > imageAspectRatio) {
      // Screen is wider than image - image height fills screen, width is smaller
      imageHeight = screenHeight;
      imageWidth = screenHeight * imageAspectRatio;
      imageOffsetX = (screenWidth - imageWidth) / 2;
      imageOffsetY = 0;
    } else {
      // Screen is taller than image - image width fills screen, height is smaller
      imageWidth = screenWidth;
      imageHeight = screenWidth / imageAspectRatio;
      imageOffsetX = 0;
      imageOffsetY = (screenHeight - imageHeight) / 2;
    }
    
    // Calculate position relative to the actual image area
    final relativeX = localPosition.dx - imageOffsetX;
    final relativeY = localPosition.dy - imageOffsetY;
    
    // Calculate percentage position (0-100) based on actual image bounds (optimized)
    final xPercent = (relativeX / imageWidth) * 100;
    final yPercent = (relativeY / imageHeight) * 100;
    
    // Apply vertical offset to move laser pointer more up (optimized)
    const double verticalOffset = 7.0; // Increased offset (7% up)
    final adjustedYPercent = yPercent - verticalOffset;
    
    // Clamp to valid range (optimized)
    final clampedX = xPercent < 0.0 ? 0.0 : (xPercent > 100.0 ? 100.0 : xPercent);
    final clampedY = adjustedYPercent < 0.0 ? 0.0 : (adjustedYPercent > 100.0 ? 100.0 : adjustedYPercent);
    
    // Zero-latency: No logging during movement
    
    // Send laser pointer position to server
    context.read<SlideControllerBloc>().add(MovePointer(x: clampedX, y: clampedY));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlideControllerBloc, SlideControllerState>(
      builder: (context, state) {
        // Check if we're in landscape mode (pointer mode active)
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        
        if (state.isPointerMode && isLandscape) {
          // Fullscreen landscape mode for pointer control
          return _buildLandscapePointerMode(context, state);
        } else {
          // Normal portrait mode
        return Scaffold(
          backgroundColor: state.settings.isDarkMode 
              ? Colors.black 
              : const Color(0xFFF5F7FA), // Updated light background
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: _buildControlArea(context, state),
                ),
                _buildFooter(context, state),
              ],
            ),
          ),
        );
        }
      },
    );
  }

  /// Fullscreen landscape mode for laser pointer control
  Widget _buildLandscapePointerMode(BuildContext context, SlideControllerState state) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure black background for fullscreen
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Fullscreen slide mirror with touch handling
            if (state.isPresenting && state.hasSlideImage && state.currentSlideImageData != null)
              _buildFullscreenSlideImageWithTouch(context, state)
            else
              _buildFullscreenPlaceholder(state),
            
            // Exit pointer mode button (top-right corner)
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  // Exit pointer mode
                  context.read<SlideControllerBloc>().add(TogglePointerMode());
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fullscreen slide image with touch handling for landscape mode
  Widget _buildFullscreenSlideImageWithTouch(BuildContext context, SlideControllerState state) {
    try {
      final dataUrl = state.currentSlideImageData!;
      if (dataUrl.startsWith('data:image')) {
        final base64Data = dataUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        
        return GestureDetector(
          // Use GestureDetector with translucent behavior to avoid interfering with image
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) => _handleLaserPointerStartGesture(context, details, state),
          onPanUpdate: (details) => _handleLaserPointerMoveGesture(context, details, state),
          onPanEnd: (details) => _handleLaserPointerEndGesture(context, details, state),
          child: RepaintBoundary(
            // Use RepaintBoundary to isolate image rendering
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.memory(
                bytes,
                fit: BoxFit.contain, // Maintain aspect ratio
                alignment: Alignment.center,
                // Add these properties to ensure stable rendering
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error displaying fullscreen slide image: $e');
    }
    
    return _buildFullscreenPlaceholder(state);
  }


  /// Fullscreen placeholder when no slide is available
  Widget _buildFullscreenPlaceholder(SlideControllerState state) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.slideshow,
              color: Colors.white54,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'LASER POINTER MODE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Touch screen to control laser pointer',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SlideControllerState state) {
    final isDark = state.settings.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [
                  const Color(0xFF0F172A), // Dark slate
                  const Color(0xFF1E293B), // Slate 800
                  const Color(0xFF334155), // Slate 700
                ]
              : [
                  const Color(0xFF1E40AF), // Blue 800
                  const Color(0xFF3B82F6), // Blue 500
                  const Color(0xFF60A5FA), // Blue 400
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : Colors.blue.withOpacity(0.2),
            blurRadius: 20 * scale,
            spreadRadius: 0,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 * scale : 16 * scale,
            isTablet ? 16 * scale : 12 * scale,
            isTablet ? 24 * scale : 16 * scale,
            isTablet ? 20 * scale : 16 * scale,
          ),
          child: Column(
            children: [
              // Main Header Row
              Row(
                children: [
                  // App Logo and Brand
                  _buildModernBrandSection(context, state, isTablet, scale),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  _buildModernActionButtons(context, state, isTablet, scale),
                ],
              ),
              
              SizedBox(height: 12 * scale),
              
              // Status Card
              _buildModernStatusCard(context, state, isTablet, scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBrandSection(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Row(
      children: [
        // Modern App Icon with Glass Effect
        Container(
          width: (isTablet ? 52 : 44) * scale,
          height: (isTablet ? 52 : 44) * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 12 * scale,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8 * scale,
                spreadRadius: 0,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: Icon(
            Icons.slideshow_rounded,
            color: Colors.white,
            size: (isTablet ? 26 : 22) * scale,
          ),
        ),
        
        SizedBox(width: 12 * scale),
        
        // Modern App Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                ],
              ).createShader(bounds),
              child: Text(
                'Slide Controller',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (isTablet ? 22 : 18) * scale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * scale,
                vertical: 2 * scale,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(12 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8 * scale,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (isTablet ? 10 : 9) * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernActionButtons(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    final buttonSize = (isTablet ? 44 : 40) * scale;
    final iconSize = (isTablet ? 22 : 20) * scale;
    
    return Row(
      children: [
        // Settings Button
        _buildModernActionButton(
          context,
          Icons.settings_rounded,
          'Settings',
          buttonSize,
          iconSize,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<SlideControllerBloc>(),
                  child: const SettingsScreen(),
                ),
              ),
            );
          },
        ),
        
        if (state.connectionStatus == ConnectionStatus.connected) ...[
          SizedBox(width: 8 * scale),
          
          // Advanced Controls Button
          _buildModernActionButton(
            context,
            Icons.tune_rounded,
            'Advanced Controls',
            buttonSize,
            iconSize,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<SlideControllerBloc>(),
                    child: const AdvancedControlsScreen(),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(width: 8 * scale),
          
          // Disconnect Button
          _buildModernActionButton(
            context,
            Icons.power_settings_new_rounded,
            'Disconnect',
            buttonSize,
            iconSize,
            () {
              context.read<SlideControllerBloc>().add(DisconnectFromServer());
            },
            isDestructive: true,
          ),
        ],
      ],
    );
  }

  Widget _buildModernActionButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    double size,
    double iconSize,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDestructive 
                ? [
                    Colors.red.withOpacity(0.3),
                    Colors.red.withOpacity(0.1),
                  ]
                : [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
          ),
          border: Border.all(
            color: isDestructive 
                ? Colors.red.withOpacity(0.4)
                : Colors.white.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDestructive 
                  ? Colors.red.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: onPressed,
            child: Center(
              child: Icon(
                icon,
                color: isDestructive ? Colors.red.shade300 : Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatusCard(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 * scale : 12 * scale,
        vertical: isTablet ? 12 * scale : 10 * scale,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8 * scale,
            spreadRadius: 0,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          // Connection Status Indicator
          _buildModernConnectionIndicator(context, state, isTablet, scale),
          
          SizedBox(width: 12 * scale),
          
          // Status Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(state),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (isTablet ? 15 : 13) * scale,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                if (_getStatusSubtitle(state) != null)
                  Text(
                    _getStatusSubtitle(state)!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: (isTablet ? 12 : 11) * scale,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          
          // Connection Quality/Info
          if (state.connectionStatus == ConnectionStatus.connected)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 4 * scale,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.3),
                    Colors.green.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(
                  color: Colors.green.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 6 * scale,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade300,
                    size: (isTablet ? 14 : 12) * scale,
                  ),
                  SizedBox(width: 4 * scale),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.green.shade200,
                      fontSize: (isTablet ? 11 : 10) * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernConnectionIndicator(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    final size = (isTablet ? 36 : 32) * scale;
    final iconSize = (isTablet ? 18 : 16) * scale;
    final color = _getConnectionColor(state.connectionStatus);
    final icon = _getConnectionIcon(state.connectionStatus);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8 * scale,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    ).animate(
      onPlay: (controller) {
        if (state.connectionStatus == ConnectionStatus.connecting ||
            state.connectionStatus == ConnectionStatus.reconnecting) {
          controller.repeat();
        }
      },
    ).rotate(duration: 2.seconds);
  }

  String _getStatusTitle(SlideControllerState state) {
    switch (state.connectionStatus) {
      case ConnectionStatus.connected:
        return 'Connected to ${state.serverIp}';
      case ConnectionStatus.connecting:
        return 'Connecting to Server';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting';
      case ConnectionStatus.error:
        return 'Connection Failed';
      case ConnectionStatus.disconnected:
        return 'Ready to Connect';
    }
  }

  String? _getStatusSubtitle(SlideControllerState state) {
    switch (state.connectionStatus) {
      case ConnectionStatus.connected:
        return state.isPresenting 
            ? 'Presentation Active'
            : 'Ready for presentation control';
      case ConnectionStatus.connecting:
        return 'Establishing secure connection...';
      case ConnectionStatus.reconnecting:
        return 'Attempt ${state.reconnectAttempt} of ${state.settings.reconnectAttempts}';
      case ConnectionStatus.error:
        return state.errorMessage ?? 'Please check connection and try again';
      case ConnectionStatus.disconnected:
        return 'Enter IP address to start controlling slides';
    }
  }

  Widget _buildControlArea(BuildContext context, SlideControllerState state) {
    if (state.connectionStatus != ConnectionStatus.connected) {
      return _buildConnectionScreen(context, state);
    }

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;

    return _buildSlideMirrorView(context, state, screenSize, isTablet, scale);
  }

  Widget _buildSlideMirrorView(BuildContext context, SlideControllerState state, Size screenSize, bool isTablet, double scale) {
    return Container(
        width: double.infinity,
      height: double.infinity,
        child: Column(
          children: [
          // Status Info Bar (when presenting)
            if (state.isPresenting) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Timer (if enabled)
              if ((state.isTimerRunning || state.presentationTimer > 0) && state.settings.showTimer)
                Container(
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                  decoration: BoxDecoration(
                    color: state.settings.isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                  child: Text(
                    '${(state.presentationTimer ~/ 60).toString().padLeft(2, '0')}:${(state.presentationTimer % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          fontSize: (isTablet ? 16 : 14) * scale,
                          fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                ],
              ),
            ),
            SizedBox(height: 8 * scale),
          ],
          
          // Main Slide Preview Area with Enhanced Gestures
          Expanded(
            child: _buildSlidePreviewArea(context, state, screenSize, isTablet, scale),
          ),
          
          // Swipe Instructions (only show when not presenting)
          if (!state.isPresenting)
            Padding(
              padding: EdgeInsets.all(12 * scale),
              child: Column(
                    children: [
                  Text(
                    'Ready to Present',
                    style: TextStyle(
                      color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: (isTablet ? 28 : 24) * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Start your presentation, then swipe to control slides',
                    style: TextStyle(
                      color: state.settings.isDarkMode 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                      fontSize: (isTablet ? 16 : 14) * scale,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlidePreviewArea(BuildContext context, SlideControllerState state, Size screenSize, bool isTablet, double scale) {
    return GestureDetector(
      // Handle touch events for laser pointer when in pointer mode
      onPanStart: (details) {
        if (state.isPointerMode) {
          _handleLaserPointerStartPortrait(context, details, state);
        }
      },
      onPanUpdate: (details) {
        if (state.isPointerMode) {
          _handleLaserPointerMovePortrait(context, details, state);
        } else {
          // Detect horizontal movement during swipe for immediate feedback
          if (details.delta.dx.abs() > details.delta.dy.abs() && details.delta.dx.abs() > 2) {
            // Visual feedback during swipe (could add slide preview sliding effect here)
          }
        }
      },
      onPanEnd: (details) {
        if (state.isPointerMode) {
          _handleLaserPointerEndPortrait(context, details, state);
        } else {
          // Ultra-fast swipe detection with multiple detection methods
          final velocity = details.velocity.pixelsPerSecond.dx;
          
          // Method 1: Velocity-based detection (ultra-low threshold for speed)
          bool isSwipeLeft = velocity < -150;  // Very sensitive threshold
          bool isSwipeRight = velocity > 150;   // Very sensitive threshold
          
          // Method 2: Distance-based detection for slower but deliberate swipes
          if (!isSwipeLeft && !isSwipeRight) {
            final screenWidth = MediaQuery.of(context).size.width;
            final swipeDistance = details.globalPosition.dx - (screenWidth / 2);
            
            if (swipeDistance.abs() > 50) { // Minimum swipe distance
              isSwipeLeft = swipeDistance < 0;
              isSwipeRight = swipeDistance > 0;
            }
          }
          
          if (isSwipeRight && state.currentSlide > 0) {
            // Swipe right - previous slide
            context.read<SlideControllerBloc>().add(PreviousSlide());
            _showSwipeAnimation(context, 'previous');
          } else if (isSwipeLeft) {
            // Swipe left - next slide  
            context.read<SlideControllerBloc>().add(NextSlide());
            _showSwipeAnimation(context, 'next');
          }
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: 2 * scale, // Maximum slide area
        ),
        decoration: BoxDecoration(
          color: Colors.black, // Pure black background for slide area
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16 * scale,
              spreadRadius: 0,
              offset: Offset(0, 8 * scale),
            ),
          ],
          // NO BORDER - Clean look around mirrored slide
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12 * scale),
          child: Stack(
                    children: [
              // Slide Preview Image Area
              _buildSlideImagePreview(context, state, isTablet, scale),
              
              // Swipe Indicators (left and right edges)
              _buildSwipeIndicators(context, state, isTablet, scale),
              
              // Loading/Connection Status Overlay
              if (!state.isPresenting)
                _buildPreviewPlaceholder(context, state, isTablet, scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideImagePreview(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: state.isPresenting 
          ? (state.hasSlideImage && state.currentSlideImageData != null)
              ? _buildActualSlideImage(state, isTablet, scale)
              : _buildSlideLoadingPlaceholder(state, isTablet, scale)
          : Container(),
    );
  }

  Widget _buildActualSlideImage(SlideControllerState state, bool isTablet, double scale) {
    try {
      // Parse the data URL to extract base64 data
      final dataUrl = state.currentSlideImageData!;
      if (dataUrl.startsWith('data:image')) {
        final base64Data = dataUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // The actual slide image
              Positioned.fill(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain, // Maintain aspect ratio
                  filterQuality: FilterQuality.high,
                ),
              ),
              
              // Red Dot Gyroscope Pointer (only when active)
              if (state.isGyroscopePointerActive)
                _buildRedDotPointer(state, scale),

              // Optional: Slide number overlay
              Positioned(
                top: 16 * scale,
                right: 16 * scale,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                  child: Text(
                    '${state.currentSlide}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (isTablet ? 14 : 12) * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                      ),
                    ],
                  ),
        );
      }
    } catch (e) {
      print('Error displaying slide image: $e');
      // Fall back to placeholder if image parsing fails
      return _buildSlideLoadingPlaceholder(state, isTablet, scale);
    }
    
    // Fallback to placeholder
    return _buildSlideLoadingPlaceholder(state, isTablet, scale);
  }

  Widget _buildSlideLoadingPlaceholder(SlideControllerState state, bool isTablet, double scale) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.1),
            const Color(0xFF3B82F6).withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.slideshow,
              size: (isTablet ? 80 : 60) * scale,
              color: const Color(0xFF3B82F6).withOpacity(0.6),
            ),
            SizedBox(height: 16 * scale),
            SizedBox(
              width: 20 * scale,
              height: 20 * scale,
              child: CircularProgressIndicator(
                color: const Color(0xFF3B82F6).withOpacity(0.7),
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Loading slide preview...',
              style: TextStyle(
                color: const Color(0xFF3B82F6).withOpacity(0.7),
                fontSize: (isTablet ? 14 : 12) * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeIndicators(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    if (!state.isPresenting) return Container();
    
    return Row(
      children: [
        // Left swipe indicator
        Container(
          width: 60 * scale,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
                    colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
              child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white.withOpacity(0.3),
              size: 24 * scale,
            ),
          ),
        ),
        const Spacer(),
        // Right swipe indicator
        Container(
          width: 60 * scale,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.3),
              size: 24 * scale,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPlaceholder(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: state.settings.isDarkMode 
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.present_to_all_outlined,
              size: (isTablet ? 80 : 60) * scale,
              color: state.settings.isDarkMode 
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black.withOpacity(0.4),
            ),
            SizedBox(height: 20 * scale),
            Text(
              'Start Presentation',
              style: TextStyle(
                color: state.settings.isDarkMode 
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.7),
                fontSize: (isTablet ? 20 : 16) * scale,
                fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
              'Press F5 on your computer\nor use the start button below',
          style: TextStyle(
                color: state.settings.isDarkMode 
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
                fontSize: (isTablet ? 14 : 12) * scale,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSwipeAnimation(BuildContext context, String direction) {
    // Quick haptic feedback for ultra-responsive feel
    try {
      HapticFeedback.lightImpact(); // Instant haptic feedback
    } catch (e) {
      // Ignore if haptic feedback is not available
    }
    
    // Optional: Add visual swipe animation here (slide transition effect)
  }

  Widget _buildConnectionScreen(BuildContext context, SlideControllerState state) {
    final TextEditingController ipController = TextEditingController();
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;
    
    // Pre-fill with last used IP if available
    if (state.settings.lastUsedIp.isNotEmpty) {
      ipController.text = state.settings.lastUsedIp;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: state.settings.isDarkMode
            ? const Color(0xFF0F172A)  // Solid dark slate
            : const Color(0xFFF8FAFC), // Solid light gray
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 48 * scale : 24 * scale),
      child: Column(
        children: [
              SizedBox(height: screenSize.height * 0.08),
              
              // Hero Section with Logo and Animation
              _buildHeroSection(context, state, isTablet, scale),
              
              SizedBox(height: 60 * scale),
              
              // Main Connection Card
              _buildConnectionCard(context, state, ipController, isTablet, scale),
          
          SizedBox(height: 40 * scale),
          
              // Quick Setup Instructions
              _buildQuickInstructions(context, state, isTablet, scale),
              
              SizedBox(height: 40 * scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Column(
      children: [
        // Logo with Simple Design
        Container(
          width: (isTablet ? 160 : 120) * scale,
          height: (isTablet ? 160 : 120) * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3B82F6), // Same blue as header
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 20 * scale,
                spreadRadius: 0,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: Icon(
            Icons.phone_android,
            size: (isTablet ? 80 : 60) * scale,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: 32 * scale),
        
        // Main Title
          Text(
          'Slide Controller Pro',
            style: TextStyle(
            color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: (isTablet ? 42 : 32) * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
        
        SizedBox(height: 8 * scale),
        
        // Subtitle
          Text(
          'Transform your phone into a presentation remote',
            style: TextStyle(
              color: state.settings.isDarkMode 
                  ? Colors.white.withOpacity(0.8)
                : const Color(0xFF64748B),
            fontSize: (isTablet ? 18 : 16) * scale,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildConnectionCard(BuildContext context, SlideControllerState state, TextEditingController ipController, bool isTablet, double scale) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 480 * scale),
      decoration: BoxDecoration(
        color: state.settings.isDarkMode 
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: state.settings.isDarkMode 
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 16 * scale,
            spreadRadius: 0,
            offset: Offset(0, 8 * scale),
          ),
        ],
        border: Border.all(
          color: state.settings.isDarkMode 
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Icon(
                    Icons.cast_connected,
                    color: Colors.white,
                    size: 24 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            Text(
                        'Connect to Computer',
                        style: TextStyle(
                          color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                          fontSize: (isTablet ? 24 : 20) * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Enter your computer\'s IP address',
              style: TextStyle(
                color: state.settings.isDarkMode 
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xFF64748B),
                fontSize: (isTablet ? 16 : 14) * scale,
              ),
            ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32 * scale),
            
            // Connection History Section
            if (state.connectionHistory.isNotEmpty) ...[
              Text(
                'Recent Connections',
                style: TextStyle(
                  color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: (isTablet ? 18 : 16) * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16 * scale),
            Container(
                height: 60 * scale,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.connectionHistory.length > 3 ? 3 : state.connectionHistory.length,
                itemBuilder: (context, index) {
                  final ip = state.connectionHistory[index];
                  return Padding(
                      padding: EdgeInsets.only(right: 12 * scale),
                      child: GestureDetector(
                      onTap: () {
                        ipController.text = ip;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20 * scale,
                            vertical: 16 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: state.settings.isDarkMode 
                                ? const Color(0xFF374151)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                size: 16 * scale,
                                color: Colors.blue.shade600,
                              ),
                              SizedBox(width: 8 * scale),
                              Text(
                          ip,
                          style: TextStyle(
                                  color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                                  fontSize: (isTablet ? 14 : 12) * scale,
                                  fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                              ),
                            ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
              SizedBox(height: 32 * scale),
            ],
            
            // IP Input Section
            Text(
              'IP Address',
              style: TextStyle(
                color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: (isTablet ? 16 : 14) * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12 * scale),
            
          Row(
            children: [
              Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: state.settings.isDarkMode 
                          ? const Color(0xFF374151)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(
                        color: state.settings.isDarkMode 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                child: TextField(
                  controller: ipController,
                  style: TextStyle(
                        color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                        fontSize: (isTablet ? 18 : 16) * scale,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: '192.168.1.100',
                    hintStyle: TextStyle(
                      color: state.settings.isDarkMode 
                              ? Colors.white.withOpacity(0.4)
                              : Colors.grey.withOpacity(0.6),
                          fontSize: (isTablet ? 18 : 16) * scale,
                          fontFamily: 'monospace',
                        ),
                        prefixIcon: Icon(
                          Icons.computer,
                          color: Colors.blue.shade600,
                          size: 24 * scale,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20 * scale,
                          vertical: 20 * scale,
                        ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
                ),
                SizedBox(width: 16 * scale),
                // Enhanced QR Scanner Button
              Container(
                  height: (isTablet ? 72 : 60) * scale,
                  width: (isTablet ? 72 : 60) * scale,
                decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(20 * scale),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 8 * scale,
                        spreadRadius: 0,
                        offset: Offset(0, 4 * scale),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(20 * scale),
                    onTap: () => _openQRScanner(context),
                    child: Icon(
                        Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                        size: (isTablet ? 32 : 28) * scale,
                    ),
                  ),
                ),
              ),
            ],
            ),
          
            SizedBox(height: 32 * scale),
          
            // Error Message
          if (state.errorMessage != null)
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                  color: Colors.red.shade50.withOpacity(state.settings.isDarkMode ? 0.1 : 1.0),
                  borderRadius: BorderRadius.circular(16 * scale),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20 * scale,
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
              child: Text(
                state.errorMessage!,
                style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: (isTablet ? 16 : 14) * scale,
                          fontWeight: FontWeight.w500,
                ),
              ),
                    ),
                  ],
                ),
              ).animate().shake(duration: 600.ms),
          
            if (state.errorMessage != null) SizedBox(height: 20 * scale),
          
            // Connect Button
            Container(
            width: double.infinity,
            height: (isTablet ? 64 : 56) * scale,
              decoration: BoxDecoration(
                color: (state.connectionStatus == ConnectionStatus.connecting ||
                       state.connectionStatus == ConnectionStatus.reconnecting)
                    ? Colors.grey.shade500
                    : const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(20 * scale),
                boxShadow: (state.connectionStatus == ConnectionStatus.connecting ||
                           state.connectionStatus == ConnectionStatus.reconnecting)
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 12 * scale,
                          spreadRadius: 0,
                          offset: Offset(0, 6 * scale),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20 * scale),
                  onTap: (state.connectionStatus == ConnectionStatus.connecting ||
                         state.connectionStatus == ConnectionStatus.reconnecting)
                  ? null
                  : () {
                      if (ipController.text.isNotEmpty) {
                        context.read<SlideControllerBloc>().add(
                              ConnectToServer(ipController.text),
                            );
                      }
                    },
                  child: Center(
              child: (state.connectionStatus == ConnectionStatus.connecting ||
                      state.connectionStatus == ConnectionStatus.reconnecting)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                      height: 24 * scale,
                      width: 24 * scale,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 16 * scale),
                              Text(
                                state.connectionStatus == ConnectionStatus.connecting
                                    ? 'Connecting...'
                                    : 'Reconnecting...',
                                style: TextStyle(
                                  fontSize: (isTablet ? 20 : 18) * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cast_connected,
                                color: Colors.white,
                                size: (isTablet ? 24 : 20) * scale,
                              ),
                              SizedBox(width: 12 * scale),
                              Text(
                                'Connect Now',
                      style: TextStyle(
                                  fontSize: (isTablet ? 20 : 18) * scale,
                                  fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.3);
  }

  Widget _buildQuickInstructions(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    final instructions = [
      {'icon': Icons.computer, 'title': 'Start Server', 'desc': 'Run python server on your computer'},
      {'icon': Icons.wifi, 'title': 'Same Network', 'desc': 'Ensure both devices are on same WiFi'},
      {'icon': Icons.present_to_all, 'title': 'Open Slides', 'desc': 'Open your presentation software'},
    ];
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 480 * scale),
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: state.settings.isDarkMode 
            ? const Color(0xFF1E293B).withOpacity(0.6)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: state.settings.isDarkMode 
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF3B82F6).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber.shade600,
                size: 24 * scale,
              ),
              SizedBox(width: 12 * scale),
              Text(
                'Quick Setup',
                style: TextStyle(
                  color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: (isTablet ? 20 : 18) * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          Row(
            children: instructions.map((instruction) => Expanded(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      instruction['icon'] as IconData,
                      color: const Color(0xFF3B82F6),
                      size: 24 * scale,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Text(
                    instruction['title'] as String,
                    style: TextStyle(
                      color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                      fontSize: (isTablet ? 14 : 12) * scale,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    instruction['desc'] as String,
                    style: TextStyle(
                      color: state.settings.isDarkMode 
                          ? Colors.white.withOpacity(0.6)
                          : const Color(0xFF64748B),
                      fontSize: (isTablet ? 12 : 10) * scale,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms, duration: 800.ms).slideY(begin: 0.3);
  }

  Widget _buildFooter(BuildContext context, SlideControllerState state) {
    if (state.connectionStatus != ConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    final scale = state.settings.uiScale;

    return Container(
      padding: EdgeInsets.all(16 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterButton(
            context,
            state,
            state.isPresenting ? Icons.stop : Icons.play_arrow,
            state.isPresenting ? 'End' : 'Start',
            () {
              if (state.isPresenting) {
                context.read<SlideControllerBloc>().add(EndPresentation());
              } else {
                context.read<SlideControllerBloc>().add(StartPresentation());
              }
            },
          ),
            // Add touch-based laser pointer if presentation is active
            if (state.isPresenting) 
              const TouchLaserPointer(),
        ],
      ),
    );
  }

  Widget _buildFooterButton(
    BuildContext context,
    SlideControllerState state,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: (isTablet ? 20 : 16) * scale,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: (isTablet ? 18 : 14) * scale,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: (isTablet ? 32 : 24) * scale,
          vertical: (isTablet ? 16 : 12) * scale,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * scale),
        ),
      ),
    );
  }

  IconData _getConnectionIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.connecting:
        return Icons.wifi_find;
      case ConnectionStatus.reconnecting:
        return Icons.wifi_find;
      case ConnectionStatus.error:
        return Icons.wifi_off;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  Color _getConnectionColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.reconnecting:
        return Colors.yellow;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  void _openQRScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<SlideControllerBloc>(),
          child: const QRScannerScreen(),
        ),
      ),
    );
  }

  // Red Dot Pointer Overlay - ULTRA SMOOTH AND RESPONSIVE
  Widget _buildRedDotPointer(SlideControllerState state, double scale) {
    return Positioned(
      left: (state.pointerX / 100.0) * MediaQuery.of(context).size.width - (20 * scale), // Convert percentage to pixels, center dot
      top: (state.pointerY / 100.0) * MediaQuery.of(context).size.height - (20 * scale),  // Convert percentage to pixels, center dot
      child: Container(
        width: 40 * scale,
        height: 40 * scale,
        child: Stack(
          children: [
            // Outer intense glow effect
            Container(
              width: 40 * scale,
              height: 40 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.8),
                    blurRadius: 25 * scale,
                    spreadRadius: 10 * scale,
                  ),
                  BoxShadow(
                    color: Colors.red.withOpacity(0.6),
                    blurRadius: 15 * scale,
                    spreadRadius: 5 * scale,
                  ),
                ],
              ),
            ),
            // Middle glow ring
            Container(
              width: 30 * scale,
              height: 30 * scale,
              margin: EdgeInsets.all(5 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.7),
                    blurRadius: 15 * scale,
                    spreadRadius: 3 * scale,
                  ),
                ],
              ),
            ),
            // Inner bright red dot
            Positioned(
              left: 10 * scale,
              top: 10 * scale,
              child: Container(
                width: 20 * scale,
                height: 20 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.red,
                      const Color(0xFFCC0000),
                      const Color(0xFF990000),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 2 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 3 * scale),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 2 * scale,
                      offset: Offset(0, -1 * scale),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate(
        effects: [
          ScaleEffect(
            duration: 100.ms, // FASTER animation for responsiveness
            curve: Curves.easeOut,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(duration: 100.ms), // FASTER fade
        ],
      ),
    );
  }

}
