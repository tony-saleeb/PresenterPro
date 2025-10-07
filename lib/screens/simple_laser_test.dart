import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';

/// Ultra-simple laser pointer test widget
class SimpleLaserTest extends StatelessWidget {
  const SimpleLaserTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'LASER POINTER TEST',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Toggle button
          ElevatedButton(
            onPressed: () {
              print('🔴 Toggling laser pointer...');
              context.read<SlideControllerBloc>().add(ToggleLaserPointer());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('TOGGLE LASER'),
          ),
          
          const SizedBox(height: 8),
          
          // Test positions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTestButton(context, 'TOP-LEFT', 25, 25),
              _buildTestButton(context, 'TOP-RIGHT', 75, 25),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTestButton(context, 'CENTER', 50, 50),
              _buildTestButton(context, 'BOTTOM-LEFT', 25, 75),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTestButton(context, 'BOTTOM-RIGHT', 75, 75),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestButton(BuildContext context, String label, double x, double y) {
    return ElevatedButton(
      onPressed: () {
        print('🧪 Testing position: $label ($x%, $y%)');
        context.read<SlideControllerBloc>().add(
          SendLaserPointerMove(x, y),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}
