import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../models/slide_command.dart';

class SlideControllerService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _lastServerIp;
  int _lastPort = 8080;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  // Stream controllers for connection events
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _slideMessageController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Getters
  bool get isConnected => _isConnected;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<Map<String, dynamic>> get slideMessageStream => _slideMessageController.stream;

  Future<bool> connect(String serverIp, {int port = 8080}) async {
    try {
      // Cancel any existing timers
      _reconnectTimer?.cancel();
      _heartbeatTimer?.cancel();
      
      // Store connection details for reconnection
      _lastServerIp = serverIp;
      _lastPort = port;
      
      final uri = Uri.parse('ws://$serverIp:$port');
      _channel = IOWebSocketChannel.connect(uri);
      
      // Test connection by waiting for the connection to be established
      await _channel!.ready;
      _isConnected = true;
      _connectionStateController.add(true);
      
      // Start heartbeat
      _startHeartbeat();
      
      // Listen for disconnections and messages
      _channel!.stream.listen(
        (data) {
          // Handle incoming messages
          _handleIncomingMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnection();
        },
      );
      
      return true;
    } catch (e) {
      print('Connection failed: $e');
      _isConnected = false;
      _connectionStateController.add(false);
      _errorController.add('Connection failed: $e');
      return false;
    }
  }
  
  Future<bool> reconnect() async {
    if (_lastServerIp != null) {
      print('Attempting to reconnect to $_lastServerIp:$_lastPort');
      return await connect(_lastServerIp!, port: _lastPort);
    }
    return false;
  }
  
  void startAutoReconnect({int maxAttempts = 3, int delaySeconds = 2}) {
    if (_reconnectTimer?.isActive == true) return;
    
    int attempts = 0;
    _reconnectTimer = Timer.periodic(Duration(seconds: delaySeconds), (timer) async {
      if (_isConnected || attempts >= maxAttempts) {
        timer.cancel();
        return;
      }
      
      attempts++;
      print('Reconnection attempt $attempts/$maxAttempts');
      
      final success = await reconnect();
      if (success) {
        timer.cancel();
      }
    });
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        // Send proper heartbeat ping, not a slide command!
        sendMessage({
          'type': 'heartbeat',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  void _handleIncomingMessage(dynamic data) {
    try {
      if (data is String) {
        final Map<String, dynamic> message = jsonDecode(data);
        
        // Handle different message types
        if (message.containsKey('type')) {
          print('Received message: ${message['type']}');
          switch (message['type']) {
            case 'slide_update':
              print('📸 Slide update received for slide ${message['slide_number']}');
              _slideMessageController.add(message);
              break;
            case 'presentation_end':
              print('🛑 Presentation ended');
              _slideMessageController.add(message);
              break;
            case 'status_update':
              // Handle status updates if needed
              break;
            case 'welcome':
              print('👋 Welcome message received');
              break;
            case 'pong':
              // Heartbeat response
              break;
            default:
              print('Unknown message type: ${message['type']}');
          }
        } else if (message.containsKey('status')) {
          // Handle command responses
          print('🎯 Command response: ${message['status']} - ${message['command'] ?? 'unknown'}');
          if (message['status'] == 'error') {
            print('❌ Command error: ${message['message']}');
          }
        } else {
          print('Unknown message format: $message');
        }
      }
    } catch (e) {
      print('Error parsing incoming message: $e');
    }
  }

  void _handleDisconnection() {
    if (_isConnected) {
      _isConnected = false;
      _connectionStateController.add(false);
      _errorController.add('Connection lost');
      _heartbeatTimer?.cancel();
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connectionStateController.add(false);
  }

  Future<bool> sendCommand(SlideCommand command, {bool isHeartbeat = false}) async {
    if (!_isConnected || _channel == null) {
      return false;
    }

    try {
      final message = jsonEncode({
        'command': command.value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'heartbeat': isHeartbeat,
      });
      
      _channel!.sink.add(message);
      return true;
    } catch (e) {
      print('Failed to send command: $e');
      _handleDisconnection();
      return false;
    }
  }

  Future<bool> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected || _channel == null) {
      return false;
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      return true;
    } catch (e) {
      print('Failed to send message: $e');
      _handleDisconnection();
      return false;
    }
  }

  Stream<String>? get stream => _channel?.stream.cast<String>();
  
  void dispose() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _connectionStateController.close();
    _errorController.close();
    _slideMessageController.close();
    disconnect();
  }
}
