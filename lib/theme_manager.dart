import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ThemeManager instance = ThemeManager._internal();
  ThemeManager._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLight = prefs.getBool('isLightMode') ?? false;
    themeMode.value = isLight ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
      await prefs.setBool('isLightMode', true);
    } else {
      themeMode.value = ThemeMode.dark;
      await prefs.setBool('isLightMode', false);
    }
  }

  bool get isLightMode => themeMode.value == ThemeMode.light;
}
