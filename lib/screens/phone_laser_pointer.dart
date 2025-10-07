import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';

/// Phone-controlled laser pointer that actually works
class PhoneLaserPointer extends StatefulWidget {
  const PhoneLaserPointer({super.key});

  @override
  State<PhoneLaserPointer> createState() => _PhoneLaserPointerState();
}

class _PhoneLaserPointerState extends State<PhoneLaserPointer> {
  // Sensor and movement variables
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _pointerX = 50.0;
  double _pointerY = 50.0;
  bool _isActive = false;
  
  // Calibration variables
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

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status display
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'LASER POINTER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isCalibrated 
                          ? 'Calibrated: X:${_calibratedX.toStringAsFixed(1)} Y:${_calibratedY.toStringAsFixed(1)}'
                          : 'Not calibrated',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _isActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        color: _isActive ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Calibrate button
                  GestureDetector(
                    onTap: _calibratePointer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isCalibrated ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isCalibrated ? 'RECALIBRATE' : 'CALIBRATE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Laser pointer button
                  GestureDetector(
                    onTapDown: (_) => _startLaserPointer(state),
                    onTapUp: (_) => _stopLaserPointer(),
                    onTapCancel: () => _stopLaserPointer(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isActive ? Colors.red : Colors.grey,
                        boxShadow: [
                          BoxShadow(
                            color: (_isActive ? Colors.red : Colors.grey).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.radio_button_checked,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  
                  // Test button
                  GestureDetector(
                    onTap: _testLaserPointer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'TEST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Calibrate the laser pointer to current phone position
  void _calibratePointer() {
    print('🎯 Calibrating laser pointer...');
    
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
      
      print('✅ Calibrated - X: ${_calibratedX.toStringAsFixed(2)}, Y: ${_calibratedY.toStringAsFixed(2)}');
    }, onError: (error) {
      print('❌ Calibration error: $error');
    });
  }

  /// Start laser pointer control
  void _startLaserPointer(SlideControllerState state) {
    print('🔴 Starting laser pointer...');
    
    if (!state.isPresenting) {
      print('❌ Not presenting, cannot start laser pointer');
      return;
    }

    // If not calibrated, calibrate first
    if (!_isCalibrated) {
      print('⚠️ Not calibrated, calibrating first...');
      _calibratePointer();
      return;
    }

    setState(() {
      _isActive = true;
    });

    // Reset pointer to center
    _pointerX = 50.0;
    _pointerY = 50.0;

    // Start accelerometer stream
    _accelerometerSubscription = accelerometerEventStream().listen(
      _handleAccelerometerEvent,
      onError: (error) {
        print('❌ Accelerometer error: $error');
      },
    );

    // Enable PC laser pointer
    context.read<SlideControllerBloc>().add(ToggleLaserPointer());

    // Haptic feedback
    HapticFeedback.lightImpact();
    
    print('✅ Laser pointer started');
  }

  /// Stop laser pointer control
  void _stopLaserPointer() {
    print('🔴 Stopping laser pointer...');
    
    setState(() {
      _isActive = false;
    });

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    // Disable PC laser pointer
    context.read<SlideControllerBloc>().add(ToggleLaserPointer());

    // Haptic feedback
    HapticFeedback.lightImpact();
    
    print('✅ Laser pointer stopped');
  }

  /// Handle accelerometer events for phone movement
  void _handleAccelerometerEvent(AccelerometerEvent event) {
    if (!_isCalibrated || !_isActive) {
      return;
    }
    
    // Calculate movement relative to calibrated position
    double deltaX = (event.x - _calibratedX) * 15.0; // X-axis for left/right
    double deltaY = -(event.y - _calibratedY) * 15.0; // Y-axis for up/down (inverted)
    
    // Apply dead zone to prevent drift
    if (deltaX.abs() < 0.2) deltaX = 0.0;
    if (deltaY.abs() < 0.2) deltaY = 0.0;
    
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
  
  /// Test laser pointer by sending test positions
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
