// splash_page.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Check if user is signed in (token in SharedPreferences)
    bool signedIn = await AuthService.isSignedIn();
    await Future.delayed(const Duration(seconds: 2)); // just to show splash

    if (signedIn) {
      // If already signed in, go straight to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Otherwise, navigate to sign in
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/logo.png', width: 150),
      ),
    );
  }
}
