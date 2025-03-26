import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'local_notification_service.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;

  BackgroundService._internal();

  late IO.Socket socket;
  final LocalNotificationService _notificationService = LocalNotificationService();

  /// Starts Foreground Service
  void startForegroundService() async {
    FlutterForegroundTask.startService(
      notificationTitle: "Sensor Monitoring Active",
      notificationText: "Listening for abnormal sensor events...",
      callback: startWebSocket,
    );
  }

  /// Stops Foreground Service
  void stopForegroundService() async {
    FlutterForegroundTask.stopService();
  }

  /// WebSocket Connection
  void startWebSocket() {
    socket = IO.io('wss://senzsafe-dev-api.demodev.in/abnormal-sensor-notifier', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to Sensor WebSocket');
    });

    socket.on('abnormal_sensor_event', (data) {
      _notificationService.showNotification("Sensor Alert!", data['message']);
    });

    socket.onDisconnect((_) => print('Disconnected from WebSocket'));
  }
}
