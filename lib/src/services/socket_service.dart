import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  final Map<String, IO.Socket> _sockets = {}; // Map to manage multiple connections

  SocketService._internal();

  factory SocketService() => _instance;

  /// Connect to a specific endpoint
  void connect(String endpoint) {
    if (!_sockets.containsKey(endpoint)) {
      final socket = IO.io(
        endpoint,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Use WebSocket transport
            .setReconnectionAttempts(5) // Number of reconnection attempts
            .setReconnectionDelay(500) // Delay between reconnection attempts
            .build(),
      );

      socket.onConnect((_) {
        print('Socket connected to $endpoint');
      });

      socket.onDisconnect((_) {
        print('Socket disconnected from $endpoint');
      });

      _sockets[endpoint] = socket;
    }
  }

  /// Emit an event on a specific endpoint
  void emit(String endpoint, String event, dynamic data) {
    final socket = _sockets[endpoint];
    if (socket != null) {
      socket.emit(event, data);
    } else {
      print('Socket for $endpoint is not connected');
    }
  }

  /// Listen for an event on a specific endpoint
  void on(String endpoint, String event, Function(dynamic) callback) {
    final socket = _sockets[endpoint];
    if (socket != null) {
      socket.on(event, callback);
    } else {
      print('Socket for $endpoint is not connected');
    }
  }

  /// Disconnect from a specific endpoint
  void disconnect(String endpoint) {
    final socket = _sockets[endpoint];
    if (socket != null) {
      socket.disconnect();
      _sockets.remove(endpoint);
      print('Disconnected from $endpoint');
    }
  }

  /// Disconnect all sockets
  void disconnectAll() {
    for (var socket in _sockets.values) {
      socket.disconnect();
    }
    _sockets.clear();
    print('Disconnected all sockets');
  }
}
