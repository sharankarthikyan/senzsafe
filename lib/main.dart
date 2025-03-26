import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:senzsafe/src/app.dart';
import 'package:senzsafe/src/services/background_service.dart';
import 'package:senzsafe/src/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final notificationService = LocalNotificationService();
  notificationService.initialize();

  final backgroundService = BackgroundService();
  backgroundService.startForegroundService();

  runApp(const MyApp());
}