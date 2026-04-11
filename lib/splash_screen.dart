import 'package:flutter/material.dart';
import 'package:aswdc_flutter_pub/aswdc_flutter_pub.dart';
import 'package:grocery/home_screen.dart';
import 'package:grocery/theme_manager.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  void initState() {
    super.initState();
    // After 3 seconds, move to HomeScreen
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade300, // Light Blue
              Colors.purple.shade100, // Light Purple
              Colors.pink.shade100, // Light Pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            primaryColor: const Color(0xFF3B82F6), // Professional blue
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF3B82F6),
            ),
          ),
          child: SplashScreen(
            appLogo: 'assets/logo4.png',
            appName: 'Group Expense Manager',
            appVersion: '1.9.0',
          ),
        ),
      ),
    );
  }
}
