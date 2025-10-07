import 'package:equatable/equatable.dart';
import '../models/slide_command.dart';
import '../models/app_settings.dart';

abstract class SlideControllerEvent extends Equatable {
  const SlideControllerEvent();

  @override
  List<Object?> get props => [];
}

class ConnectToServer extends SlideControllerEvent {
  final String serverIp;

  const ConnectToServer(this.serverIp);

  @override
  List<Object?> get props => [serverIp];
}

class DisconnectFromServer extends SlideControllerEvent {}

class SendSlideCommand extends SlideControllerEvent {
  final SlideCommand command;

  const SendSlideCommand(this.command);

  @override
  List<Object?> get props => [command];
}

class NextSlide extends SlideControllerEvent {}

class PreviousSlide extends SlideControllerEvent {}

class StartPresentation extends SlideControllerEvent {}

class EndPresentation extends SlideControllerEvent {}

// Advanced Features Events
class ToggleLaserPointer extends SlideControllerEvent {}

class SendLaserPointerMove extends SlideControllerEvent {
  final double xPercent;
  final double yPercent;

  const SendLaserPointerMove(this.xPercent, this.yPercent);

  @override
  List<Object?> get props => [xPercent, yPercent];
}

class SendLaserPointerClick extends SlideControllerEvent {
  final double xPercent;
  final double yPercent;

  const SendLaserPointerClick(this.xPercent, this.yPercent);

  @override
  List<Object?> get props => [xPercent, yPercent];
}

class ToggleBlackScreen extends SlideControllerEvent {}

class ToggleWhiteScreen extends SlideControllerEvent {}

class TogglePresentationView extends SlideControllerEvent {}

class VolumeUp extends SlideControllerEvent {}

class VolumeDown extends SlideControllerEvent {}

class ToggleMute extends SlideControllerEvent {}

class GoToFirstSlide extends SlideControllerEvent {}

class GoToLastSlide extends SlideControllerEvent {}

class StartTimer extends SlideControllerEvent {}

class StopTimer extends SlideControllerEvent {}

class ResetTimer extends SlideControllerEvent {}

class UpdateTimer extends SlideControllerEvent {
  final int seconds;

  const UpdateTimer(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

// Settings Events
class LoadSettings extends SlideControllerEvent {}

class UpdateSettings extends SlideControllerEvent {
  final AppSettings settings;

  const UpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleTheme extends SlideControllerEvent {}

class AttemptReconnect extends SlideControllerEvent {}

class LoadConnectionHistory extends SlideControllerEvent {}

// Slide Image Events
class UpdateSlideImage extends SlideControllerEvent {
  final String? imageData;
  final int? slideNumber;

  const UpdateSlideImage(this.imageData, this.slideNumber);

  @override
  List<Object?> get props => [imageData, slideNumber];
}

class ClearSlideImage extends SlideControllerEvent {}

// Gyroscope Pointer Events
class StartPointer extends SlideControllerEvent {
  const StartPointer();

  @override
  List<Object?> get props => [];
}

class StopPointer extends SlideControllerEvent {
  const StopPointer();

  @override
  List<Object?> get props => [];
}

class MovePointer extends SlideControllerEvent {
  final double x;
  final double y;

  const MovePointer({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}

class TogglePointerMode extends SlideControllerEvent {}

// Internal error event
class HandleConnectionError extends SlideControllerEvent {
  final String error;

  const HandleConnectionError(this.error);

  @override
  List<Object?> get props => [error];
}
