import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';

/// Real laser pointer implementation using accelerometer for physical movement
/// Inspired by the Kotlin example provided
class GyroscopeLaserPointer extends StatefulWidget {
  const GyroscopeLaserPointer({super.key});

  @override
  State<GyroscopeLaserPointer> createState() => _GyroscopeLaserPointerState();
}

class _GyroscopeLaserPointerState extends State<GyroscopeLaserPointer> {
  // Real laser pointer variables (using accelerometer for physical movement)
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _pointerX = 50.0;
  double _pointerY = 50.0;
  double _sensitivity = 1.0;
  bool _isActive = false;
  
  // Calibration for real laser pointer behavior
  double _calibratedX = 0.0;
  double _calibratedY = 0.0;
  bool _isCalibrated = false;

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlideControllerBloc, SlideControllerState>(
      builder: (context, state) {
        if (!state.isPresenting) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Debug info
            if (_isCalibrated)
              Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Calibrated: X:${_calibratedX.toStringAsFixed(1)} Y:${_calibratedY.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            _buildLaserPointerButton(context, state),
            // Test button
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => _testLaserPointer(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TEST',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Real Laser Pointer Button - Calibrate on first tap, use on hold
  Widget _buildLaserPointerButton(BuildContext context, SlideControllerState state) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;
    final buttonSize = (isTablet ? 60 : 55) * scale;

    return GestureDetector(
      onTapDown: (_) => _startLaserPointer(state),
      onTapUp: (_) => _stopLaserPointer(),
      onTapCancel: () => _stopLaserPointer(),
      onLongPress: () => _calibrateLaserPointer(),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isActive 
              ? const Color(0xFFFF4444) 
              : _isCalibrated 
                  ? const Color(0xFFE74C3C) 
                  : const Color(0xFF95A5A6), // Gray when not calibrated
          boxShadow: [
            BoxShadow(
              color: (_isActive ? const Color(0xFFFF4444) : const Color(0xFFE74C3C)).withOpacity(0.6),
              blurRadius: 15 * scale,
              spreadRadius: 3 * scale,
              offset: Offset(0, 4 * scale),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _isCalibrated ? Icons.radio_button_checked : Icons.center_focus_weak,
            color: Colors.white,
            size: (isTablet ? 25 : 22) * scale,
          ),
        ),
      ),
    );
  }

  /// Start laser pointer - similar to Kotlin's setVisibility(true)
  void _startLaserPointer(SlideControllerState state) {
    print('Starting laser pointer...');
    
    if (!state.isPresenting) {
      print('Not presenting, cannot start laser pointer');
      return;
    }

    // If not calibrated, calibrate first
    if (!_isCalibrated) {
      print('Not calibrated, calibrating first...');
      _calibrateLaserPointer();
      return;
    }

    print('Starting laser pointer with calibration - X: ${_calibratedX.toStringAsFixed(2)}, Y: ${_calibratedY.toStringAsFixed(2)}');

    setState(() {
      _isActive = true;
    });

    // Reset pointer to center - like Kotlin's resetPos()
    _pointerX = 50.0;
    _pointerY = 50.0;

    // Start accelerometer stream for real laser pointer movement
    _accelerometerSubscription = accelerometerEventStream().listen(
      _handleAccelerometerEvent,
      onError: (error) {
        print('Accelerometer error: $error');
      },
    );

    // Enable PC laser pointer
    context.read<SlideControllerBloc>().add(ToggleLaserPointer());

    // Haptic feedback
    HapticFeedback.lightImpact();
    
    print('Laser pointer started successfully');
  }

  /// Stop laser pointer - similar to Kotlin's setVisibility(false)
  void _stopLaserPointer() {
    print('Stopping laser pointer...');
    
    setState(() {
      _isActive = false;
    });

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    // Disable PC laser pointer
    context.read<SlideControllerBloc>().add(ToggleLaserPointer());

    // Haptic feedback
    HapticFeedback.lightImpact();
    
    print('Laser pointer stopped');
  }

  /// Calibrate laser pointer to current phone position
  void _calibrateLaserPointer() {
    print('Starting calibration...');
    
    // Get current accelerometer reading as calibration point
    accelerometerEventStream().take(1).listen((event) {
      setState(() {
        _calibratedX = event.x;
        _calibratedY = event.y;
        _isCalibrated = true;
      });
      
      // Reset pointer to center
      _pointerX = 50.0;
      _pointerY = 50.0;
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      print('Laser pointer calibrated - X: ${_calibratedX.toStringAsFixed(2)}, Y: ${_calibratedY.toStringAsFixed(2)}');
    }, onError: (error) {
      print('Calibration error: $error');
    });
  }

  /// Handle accelerometer events for real laser pointer movement
  void _handleAccelerometerEvent(AccelerometerEvent event) {
    if (!_isCalibrated || !_isActive) {
      return;
    }
    
    // SIMPLIFIED LASER POINTER BEHAVIOR:
    // Move phone RIGHT → laser moves RIGHT
    // Move phone LEFT → laser moves LEFT  
    // Move phone UP → laser moves UP
    // Move phone DOWN → laser moves DOWN
    
    // Calculate movement relative to calibrated position
    double deltaX = (event.x - _calibratedX) * 10.0; // X-axis for left/right
    double deltaY = -(event.y - _calibratedY) * 10.0; // Y-axis for up/down (inverted)
    
    // Apply dead zone to prevent drift
    if (deltaX.abs() < 0.1) deltaX = 0.0;
    if (deltaY.abs() < 0.1) deltaY = 0.0;
    
    // Only update if there's actual movement
    if (deltaX != 0.0 || deltaY != 0.0) {
      // Update pointer position
      _pointerX += deltaX;
      _pointerY += deltaY;
      
      // Clamp to screen bounds (0-100%)
      _pointerX = _pointerX.clamp(0.0, 100.0);
      _pointerY = _pointerY.clamp(0.0, 100.0);
      
      // Send pointer position to server
      context.read<SlideControllerBloc>().add(MovePointer(x: _pointerX, y: _pointerY));
    }
  }
  
  /// Test laser pointer by sending test commands
  void _testLaserPointer() {
    print('🧪 Testing laser pointer...');
    
    // Test positions
    final testPositions = [
      (25.0, 25.0, "Top-left"),
      (75.0, 25.0, "Top-right"),
      (50.0, 50.0, "Center"),
      (25.0, 75.0, "Bottom-left"),
      (75.0, 75.0, "Bottom-right"),
    ];
    
    // Send test positions
    for (final (x, y, description) in testPositions) {
      print('🧪 Sending test position: $description ($x%, $y%)');
      context.read<SlideControllerBloc>().add(MovePointer(x: x, y: y));
    }
    
    print('🧪 Test completed!');
  }
}
