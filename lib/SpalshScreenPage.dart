import 'package:aswdc_flutter_pub/aswdc_flutter_pub.dart';
import 'package:flutter/material.dart';
import 'package:grocery/LoginPage.dart';
import 'package:grocery/NewScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> {
  @override
  void initState() {

    super.initState();
    _checkLoginStatus();

  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash duration

    final prefs = await SharedPreferences.getInstance();
    final hostID = prefs.getInt('hostID');

    if (hostID != null) {
      // HostID exists, go to NewScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NewScreen()),
      );
    } else {
      // No hostID found, go to LoginScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Future<void> _navigateToHome() async {
  //   await Future.delayed(const Duration(milliseconds: 5000));
  //   Navigator.of(context).pushReplacement(MaterialPageRoute(
  //     builder: (context) => LoginScreen(),
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade100, // Light Blue
              Colors.purple.shade100, // Light Purple
              Colors.pink.shade100, // Light Pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: const SplashScreen(
          appLogo: "assets/logo4.png",
          appName: "Group Expense Manager",
          appVersion: "1.9",
        ),
      ),
    );
  }
}
