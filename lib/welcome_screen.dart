import 'package:flutter/material.dart';
import 'package:grocery/home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  top: 30, bottom: 20, left: 20, right: 20),
              width: 200,
              child: Image.asset('assets/firstimg.png'), // Ensure this image path is correct
            ),
            SizedBox(height: 10),
            Text(
              "Group Expense Manager",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              "Easy to Manage",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigating to HomeScreen with a default eventName
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen()
                  ),
                );
              },
              child: Text(
                "Let's go!",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.brown[500],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


