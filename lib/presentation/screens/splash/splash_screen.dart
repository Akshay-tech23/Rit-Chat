import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 6));

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('onboarding_complete') ?? false;

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // User already logged in → Go to Home
      Navigator.pushReplacementNamed(context, '/home');
    } else if (seenOnboarding) {
      // Onboarding done but not logged in → Go to Login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // First time → Go to Onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Lottie.asset(
          isDark
              ? 'lib/assets/RIT chat Dark.json'
              : 'lib/assets/New splash.json',
          repeat: false,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
