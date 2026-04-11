import 'package:grocery/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthDatabase{
  Future<bool> signUpUser(String email, String password, String confirmPassword, String mobileNo) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUser.isNotEmpty) {
        return false; // User already exists
      }

      int id = await db.insert('users', {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'mobileNo': mobileNo,
        'isActive': 1,
      });

      return id > 0;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isNotEmpty) {
        final data = result.first;
        final prefs = await SharedPreferences.getInstance();

        prefs.setString('userEmail', data['email'] as String);
        prefs.setInt("hostID", data['hostId'] as int);
        prefs.setBool('isLoggedIn', true);

        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
