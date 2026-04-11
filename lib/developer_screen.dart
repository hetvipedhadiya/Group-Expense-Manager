import 'package:flutter/material.dart';
import 'package:aswdc_flutter_pub/aswdc_flutter_pub.dart';
import 'package:grocery/theme_manager.dart';

class AppDeveloperScreen extends StatelessWidget {
  const AppDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeManager.instance.isLightMode;
    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF0D0D1F),
      body: Column(
        children: [
          // MATCHING HEADER FROM HOME SCREEN

          // DEVELOPER SCREEN CONTENT
          Expanded(
            child: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: const Color(0xFF1E293B),
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF1E293B),
            secondary: const Color(0xFF0F172A),
          ),
        ),
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
          ),
        ],
      ),
    );
  }
}

