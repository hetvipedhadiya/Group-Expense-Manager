
import 'package:flutter/material.dart';
import 'package:grocery/LoginPage.dart';
import 'package:grocery/SpalshScreenPage.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Group Expense Manager',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.white)
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1E2A78)),


        useMaterial3: true,
      ),
      home: SplashScreenPage(),
      //home:LoginScreen()
     // home: PieChartPage(),

    );

  }
}
