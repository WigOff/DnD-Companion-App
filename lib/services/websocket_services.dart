import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  late Stream<dynamic> _broadcastStream;

  void connect({int port = 8000}) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://dnd-companion-app.onrender.com/ws'),
      // Uri.parse('ws://192.168.137.1:8000/ws'),
    );
    // Cache once — all listeners share this single broadcast stream
    _broadcastStream = _channel.stream.asBroadcastStream();
  }

  /// Completes when the WebSocket handshake is done.
  Future<void> get ready => _channel.ready;

  void send(Map<String, dynamic> data) {
    _channel.sink.add(jsonEncode(data));
  }

  Stream<dynamic> get stream => _broadcastStream;

  void listen(Function(dynamic) onData) {
    _broadcastStream.listen(onData);
  }

  void disconnect() {
    _channel.sink.close();
  }
}
