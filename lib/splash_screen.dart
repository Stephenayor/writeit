import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/core/utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _displayedText = "";
  final String _fullText = "WriteIT";
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        // Wait a bit before navigating to the main screen
        Future.delayed(const Duration(seconds: 1), () {
          if (FirebaseAuth.instance.currentUser != null) {
            context.go(Routes.home);
          } else {
            context.go(Routes.signIn);
          }
        });
        // context.go(Routes.signIn);
      }
    });
  }

  void _navigateAfterSplash() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      if (user != null) {
        // 👇 go to home if signed in
        context.go(Routes.home);
      } else {
        context.go(Routes.signUp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/publisher.png', width: 100, height: 100),
            const SizedBox(height: 34),

            Text(
              _displayedText,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // blinking cursor
            AnimatedOpacity(
              opacity: _currentIndex == _fullText.length ? 0 : 1,
              duration: const Duration(milliseconds: 400),
              child: const Text(
                "|",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
