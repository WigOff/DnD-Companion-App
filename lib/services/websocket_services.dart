import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();
  bool _isConnecting = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  String _url = 'wss://dnd-companion-app.onrender.com/ws';

  /// Stream of all incoming WebSocket messages.
  /// Listeners on this stream remain active even if the connection drops and reconnects.
  Stream<dynamic> get stream => _controller.stream;

  /// Establishes a connection to the server.
  Future<void> connect({String? url}) async {
    if (url != null) _url = url;
    if (_isConnecting) return;
    _isConnecting = true;

    _cleanup();
    print("🔌 Connecting to WebSocket: $_url");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      
      // Wait for the connection to be ready
      await _channel!.ready;
      print("✅ Connected to WebSocket");
      _isConnecting = false;
      
      // Start heartbeat to keep connection alive on Render
      _startHeartbeat();

      // Listen for incoming messages
      _channel!.stream.listen(
        (message) {
          if (!_controller.isClosed) {
            _controller.add(message);
          }
        },
        onDone: () {
          print("📡 WebSocket connection closed by server.");
          _handleDisconnect();
        },
        onError: (error) {
          print("⚠️ WebSocket error: $error");
          _handleDisconnect();
        },
      );
    } catch (e) {
      print("❌ Connection failed: $e");
      _isConnecting = false;
      _handleDisconnect();
    }
  }

  /// Handles disconnection by attempting to reconnect after a delay.
  void _handleDisconnect() {
    _cleanup();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      print("🔄 Attempting to reconnect...");
      connect();
    });
  }

  /// Sends a small ping message every 30 seconds to prevent Render from timing out.
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null) {
        send({'type': 'ping'});
      }
    });
  }

  /// Closes the current socket and stops timers.
  void _cleanup() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  /// Sends JSON-encoded data to the server.
  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (e) {
        print("❌ Error sending message: $e");
      }
    } else {
      print("🚫 Cannot send message: WebSocket is not connected.");
    }
  }

  /// Compatibility getter for original implementation.
  Future<void> get ready async {
    if (_channel != null) {
      await _channel!.ready;
    }
  }

  /// Compatibility listener for original implementation.
  void listen(Function(dynamic) onData) {
    stream.listen(onData);
  }

  /// Completely stops all connections and reconnection attempts.
  void disconnect() {
    _reconnectTimer?.cancel();
    _cleanup();
  }
}
