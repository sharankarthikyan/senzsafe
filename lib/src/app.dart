// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:senzsafe/src/pages/branches_page.dart';
import 'package:senzsafe/src/pages/controller_page.dart';
import 'package:senzsafe/src/pages/gateway_page.dart';
import 'package:senzsafe/src/pages/loops_page.dart';
import 'package:senzsafe/src/pages/users_page.dart';
import 'pages/splash_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/dashboard_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senzsafe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/signin': (context) => const SignInPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/users': (context) => const UsersPage(),
        '/branches': (context) => const BranchesPage(),
        '/gateway': (context) => const GatewayPage(),
        '/controller': (context) => const ControllerPage(),
        '/loops': (context) => const LoopsPage(),
        '/logout': (context) => const SignInPage(),
      },
    );
  }
}
