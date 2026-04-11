import 'package:flutter/material.dart';
import 'package:aswdc_flutter_pub/aswdc_flutter_pub.dart';
class AppDeveloperScreen extends StatelessWidget {
  const AppDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: DeveloperScreen(
          developerName: 'Hetvi Pedhadiya',
          mentorName: 'Prof. Rajkumar Gondaliya',
          exploredByName: 'ASWDC',
          isAdmissionApp: false,
          isDBUpdate: false,
          shareMessage: 'Check out the Group Expense Manager app!',
          appTitle: 'Group Expense Manager',
          appLogo: 'assets/logo4.png',
        ),
      ),
    );
  }
}

