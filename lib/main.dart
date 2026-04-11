import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery/splash_screen.dart';
import 'package:grocery/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.instance.init();

  // Force portrait mode for consistent UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance.themeMode,
      builder: (context, mode, child) {
        // Update status bar based on theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: mode == ThemeMode.dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: mode == ThemeMode.dark ? const Color(0xFF0D0D1F) : Colors.white,
            systemNavigationBarIconBrightness: mode == ThemeMode.dark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Group Expense Manager',
          themeMode: mode,
          // DARK THEME (Current Premium Design)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D0D1F),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C3AED),
              secondary: Color(0xFF4F46E5),
              surface: Color(0xFF1A1040),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D0D1F),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          // LIGHT THEME (New Professional Design)
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C3AED),
              secondary: Color(0xFF4F46E5),
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF7C3AED),
              foregroundColor: Colors.white,
            ),
          ),
          home: const AppSplashScreen(),
        );
      },
    );
  }
}



