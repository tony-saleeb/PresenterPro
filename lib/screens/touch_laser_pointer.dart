import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';

/// Simple touch-based laser pointer
class TouchLaserPointer extends StatefulWidget {
  const TouchLaserPointer({super.key});

  @override
  State<TouchLaserPointer> createState() => _TouchLaserPointerState();
}

class _TouchLaserPointerState extends State<TouchLaserPointer> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlideControllerBloc, SlideControllerState>(
      builder: (context, state) {
        if (!state.isPresenting) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: _togglePointerMode,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state.isPointerMode ? Colors.red : Colors.grey,
              boxShadow: [
                BoxShadow(
                  color: (state.isPointerMode ? Colors.red : Colors.grey).withOpacity(0.5),
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
        );
      },
    );
  }

  void _togglePointerMode() {
    // Send pointer mode state to BLoC
    context.read<SlideControllerBloc>().add(TogglePointerMode());
  }
}
