import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grocery/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSignUpApi{
  static const String _baseUrl = "${Env.baseUrl}/api/Account";

  Future<bool> signUpUser(String email, String password, String confirmPassword, String mobileNo) async {
    final url = Uri.parse("$_baseUrl/register");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'mobileNo': mobileNo,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> loginUser(String email, String password) async {
    final url = Uri.parse("$_baseUrl/Login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,  // ✅ Corrected key
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final prefs = await SharedPreferences.getInstance();

      prefs.setString('userEmail', data['email']);
      prefs.setInt("hostID", data['hostId']);
      prefs.setBool('isLoggedIn', true);

      return true;
    } else {
      return false;
    }
  }


}