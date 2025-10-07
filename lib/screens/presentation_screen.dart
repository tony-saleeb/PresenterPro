import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';
import 'advanced_controls_screen.dart';
import 'settings_screen.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlideControllerBloc, SlideControllerState>(
      builder: (context, state) {
        final screenSize = MediaQuery.of(context).size;
        final isTablet = screenSize.width > 600;
        final scale = state.settings.uiScale;
        
        return Scaffold(
          backgroundColor: state.settings.isDarkMode 
              ? const Color(0xFF0A0A0A) 
              : const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                // Header with connection status and controls
                _buildHeader(context, state, isTablet, scale),
                
                // Main presentation controls
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all((isTablet ? 24 : 16) * scale),
                    child: Column(
                      children: [
                        // Timer Display
                        _buildTimerDisplay(context, state, isTablet, scale),
                        
                        SizedBox(height: (isTablet ? 30 : 24) * scale),
                        
                        // Slide Navigation Controls
                        _buildSlideControls(context, state, isTablet, scale),
                        
                        SizedBox(height: (isTablet ? 30 : 24) * scale),
                        
                        // Presentation Controls
                        _buildPresentationControls(context, state, isTablet, scale),
                        
                        SizedBox(height: (isTablet ? 30 : 24) * scale),
                        
                        // Quick Access Controls
                        _buildQuickControls(context, state, isTablet, scale),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      padding: EdgeInsets.all((isTablet ? 20 : 16) * scale),
      decoration: BoxDecoration(
        color: state.settings.isDarkMode 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: state.settings.isDarkMode ? 0.3 : 0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Connection Status and Server IP
          Row(
            children: [
              Container(
                padding: EdgeInsets.all((isTablet ? 8 : 6) * scale),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular((isTablet ? 8 : 6) * scale),
                ),
                child: Icon(
                  Icons.wifi,
                  color: Colors.green,
                  size: (isTablet ? 24 : 20) * scale,
                ),
              ),
              SizedBox(width: (isTablet ? 12 : 8) * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: (isTablet ? 18 : 16) * scale,
                        fontWeight: FontWeight.bold,
                        color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (state.serverIp != null)
                      Text(
                        state.serverIp!,
                        style: TextStyle(
                          fontSize: (isTablet ? 14 : 12) * scale,
                          color: state.settings.isDarkMode 
                              ? Colors.grey[400] 
                              : Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
              
              // Action Buttons
              Row(
                children: [
                  // Advanced Controls Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular((isTablet ? 8 : 6) * scale),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdvancedControlsScreen(),
                        ),
                      ),
                      icon: Icon(
                        Icons.tune,
                        color: Colors.purple,
                        size: (isTablet ? 24 : 20) * scale,
                      ),
                    ),
                  ),
                  
                  SizedBox(width: (isTablet ? 8 : 6) * scale),
                  
                  // Settings Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular((isTablet ? 8 : 6) * scale),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ),
                      icon: Icon(
                        Icons.settings,
                        color: Colors.orange,
                        size: (isTablet ? 24 : 20) * scale,
                      ),
                    ),
                  ),
                  
                  SizedBox(width: (isTablet ? 8 : 6) * scale),
                  
                  // Disconnect Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular((isTablet ? 8 : 6) * scale),
                    ),
                    child: IconButton(
                      onPressed: () {
                        context.read<SlideControllerBloc>().add(DisconnectFromServer());
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.link_off,
                        color: Colors.red,
                        size: (isTablet ? 24 : 20) * scale,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    final minutes = state.presentationTimer ~/ 60;
    final seconds = state.presentationTimer % 60;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((isTablet ? 24 : 20) * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular((isTablet ? 20 : 16) * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.timer,
                color: Colors.white,
                size: (isTablet ? 28 : 24) * scale,
              ),
              SizedBox(width: (isTablet ? 12 : 8) * scale),
              Text(
                'Presentation Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (isTablet ? 20 : 18) * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: (isTablet ? 16 : 12) * scale),
          
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white,
              fontSize: (isTablet ? 48 : 40) * scale,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ).animate().scale(),
          
          SizedBox(height: (isTablet ? 16 : 12) * scale),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimerButton(
                context,
                state,
                state.isTimerRunning ? Icons.pause : Icons.play_arrow,
                state.isTimerRunning ? 'Pause' : 'Start',
                () {
                  if (state.isTimerRunning) {
                    context.read<SlideControllerBloc>().add(StopTimer());
                  } else {
                    context.read<SlideControllerBloc>().add(StartTimer());
                  }
                },
                isTablet,
                scale,
              ),
              _buildTimerButton(
                context,
                state,
                Icons.refresh,
                'Reset',
                () => context.read<SlideControllerBloc>().add(ResetTimer()),
                isTablet,
                scale,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildTimerButton(
    BuildContext context,
    SlideControllerState state,
    IconData icon,
    String label,
    VoidCallback onPressed,
    bool isTablet,
    double scale,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: (isTablet ? 20 : 18) * scale),
      label: Text(
        label,
        style: TextStyle(fontSize: (isTablet ? 14 : 12) * scale),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: (isTablet ? 20 : 16) * scale,
          vertical: (isTablet ? 12 : 10) * scale,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular((isTablet ? 12 : 10) * scale),
        ),
      ),
    );
  }

  Widget _buildSlideControls(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((isTablet ? 24 : 20) * scale),
      decoration: BoxDecoration(
        color: state.settings.isDarkMode 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        borderRadius: BorderRadius.circular((isTablet ? 20 : 16) * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: state.settings.isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Slide Navigation',
            style: TextStyle(
              fontSize: (isTablet ? 20 : 18) * scale,
              fontWeight: FontWeight.bold,
              color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          
          SizedBox(height: (isTablet ? 20 : 16) * scale),
          
          // Main Navigation Buttons
          Row(
            children: [
              Expanded(
                child: _buildSlideButton(
                  context,
                  state,
                  'Previous',
                  Icons.skip_previous,
                  Colors.orange,
                  () => context.read<SlideControllerBloc>().add(PreviousSlide()),
                  isTablet,
                  scale,
                ),
              ),
              
              SizedBox(width: (isTablet ? 20 : 16) * scale),
              
              Expanded(
                child: _buildSlideButton(
                  context,
                  state,
                  'Next',
                  Icons.skip_next,
                  Colors.green,
                  () => context.read<SlideControllerBloc>().add(NextSlide()),
                  isTablet,
                  scale,
                ),
              ),
            ],
          ),
          
          SizedBox(height: (isTablet ? 16 : 12) * scale),
          
          // Presentation Start/End Buttons
          Row(
            children: [
              Expanded(
                child: _buildSlideButton(
                  context,
                  state,
                  'Start Presentation',
                  Icons.play_circle,
                  Colors.blue,
                  () => context.read<SlideControllerBloc>().add(StartPresentation()),
                  isTablet,
                  scale,
                ),
              ),
              
              SizedBox(width: (isTablet ? 16 : 12) * scale),
              
              Expanded(
                child: _buildSlideButton(
                  context,
                  state,
                  'End Presentation',
                  Icons.stop_circle,
                  Colors.red,
                  () => context.read<SlideControllerBloc>().add(EndPresentation()),
                  isTablet,
                  scale,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildSlideButton(
    BuildContext context,
    SlideControllerState state,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isTablet,
    double scale,
  ) {
    return Container(
      height: (isTablet ? 80 : 70) * scale,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular((isTablet ? 16 : 12) * scale),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular((isTablet ? 16 : 12) * scale),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: (isTablet ? 28 : 24) * scale,
              ),
              SizedBox(height: (isTablet ? 8 : 6) * scale),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (isTablet ? 14 : 12) * scale,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresentationControls(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((isTablet ? 24 : 20) * scale),
      decoration: BoxDecoration(
        color: state.settings.isDarkMode 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        borderRadius: BorderRadius.circular((isTablet ? 20 : 16) * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: state.settings.isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Presentation Controls',
            style: TextStyle(
              fontSize: (isTablet ? 20 : 18) * scale,
              fontWeight: FontWeight.bold,
              color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          
          SizedBox(height: (isTablet ? 20 : 16) * scale),
          
          // Laser Pointer Toggle
          _buildFeatureToggle(
            context,
            state,
            'Laser Pointer',
            Icons.radio_button_on,
            state.isLaserPointerActive,
            () => context.read<SlideControllerBloc>().add(ToggleLaserPointer()),
            isTablet,
            scale,
          ),
          
          SizedBox(height: (isTablet ? 12 : 10) * scale),
          
          // Black Screen Toggle
          _buildFeatureToggle(
            context,
            state,
            'Black Screen',
            Icons.brightness_1,
            state.isBlackScreen,
            () => context.read<SlideControllerBloc>().add(ToggleBlackScreen()),
            isTablet,
            scale,
          ),
          
          SizedBox(height: (isTablet ? 12 : 10) * scale),
          
          // White Screen Toggle
          _buildFeatureToggle(
            context,
            state,
            'White Screen',
            Icons.brightness_high,
            state.isWhiteScreen,
            () => context.read<SlideControllerBloc>().add(ToggleWhiteScreen()),
            isTablet,
            scale,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms);
  }

  Widget _buildFeatureToggle(
    BuildContext context,
    SlideControllerState state,
    String label,
    IconData icon,
    bool isActive,
    VoidCallback onPressed,
    bool isTablet,
    double scale,
  ) {
    return Container(
      height: (isTablet ? 60 : 50) * scale,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade400, Colors.teal.shade400],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  state.settings.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  state.settings.isDarkMode ? Colors.grey[800]! : Colors.grey[400]!,
                ],
              ),
        borderRadius: BorderRadius.circular((isTablet ? 12 : 10) * scale),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular((isTablet ? 12 : 10) * scale),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: (isTablet ? 16 : 12) * scale),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: (isTablet ? 24 : 20) * scale,
                ),
                SizedBox(width: (isTablet ? 12 : 8) * scale),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (isTablet ? 16 : 14) * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  isActive ? Icons.toggle_on : Icons.toggle_off,
                  color: Colors.white,
                  size: (isTablet ? 28 : 24) * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickControls(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((isTablet ? 24 : 20) * scale),
      decoration: BoxDecoration(
        color: state.settings.isDarkMode 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        borderRadius: BorderRadius.circular((isTablet ? 20 : 16) * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: state.settings.isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Controls',
            style: TextStyle(
              fontSize: (isTablet ? 20 : 18) * scale,
              fontWeight: FontWeight.bold,
              color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          
          SizedBox(height: (isTablet ? 20 : 16) * scale),
          
          // Volume Controls
          Row(
            children: [
              Expanded(
                child: _buildQuickButton(
                  context,
                  state,
                  'Volume Up',
                  Icons.volume_up,
                  Colors.blue,
                  () => context.read<SlideControllerBloc>().add(VolumeUp()),
                  isTablet,
                  scale,
                ),
              ),
              
              SizedBox(width: (isTablet ? 12 : 8) * scale),
              
              Expanded(
                child: _buildQuickButton(
                  context,
                  state,
                  'Mute',
                  state.isMuted ? Icons.volume_off : Icons.volume_up,
                  state.isMuted ? Colors.red : Colors.orange,
                  () => context.read<SlideControllerBloc>().add(ToggleMute()),
                  isTablet,
                  scale,
                ),
              ),
              
              SizedBox(width: (isTablet ? 12 : 8) * scale),
              
              Expanded(
                child: _buildQuickButton(
                  context,
                  state,
                  'Volume Down',
                  Icons.volume_down,
                  Colors.blue,
                  () => context.read<SlideControllerBloc>().add(VolumeDown()),
                  isTablet,
                  scale,
                ),
              ),
            ],
          ),
          
          SizedBox(height: (isTablet ? 16 : 12) * scale),
          
          // Navigation Controls
          Row(
            children: [
              Expanded(
                child: _buildQuickButton(
                  context,
                  state,
                  'First Slide',
                  Icons.first_page,
                  Colors.purple,
                  () => context.read<SlideControllerBloc>().add(GoToFirstSlide()),
                  isTablet,
                  scale,
                ),
              ),
              
              SizedBox(width: (isTablet ? 12 : 8) * scale),
              
              Expanded(
                child: _buildQuickButton(
                  context,
                  state,
                  'Last Slide',
                  Icons.last_page,
                  Colors.purple,
                  () => context.read<SlideControllerBloc>().add(GoToLastSlide()),
                  isTablet,
                  scale,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms);
  }

  Widget _buildQuickButton(
    BuildContext context,
    SlideControllerState state,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isTablet,
    double scale,
  ) {
    return Container(
      height: (isTablet ? 60 : 50) * scale,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular((isTablet ? 12 : 10) * scale),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular((isTablet ? 12 : 10) * scale),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: (isTablet ? 20 : 18) * scale,
              ),
              SizedBox(height: (isTablet ? 4 : 2) * scale),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (isTablet ? 12 : 10) * scale,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



