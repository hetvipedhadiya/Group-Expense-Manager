import 'package:grocery/Models/UserDropDownModel.dart';
import 'package:grocery/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grocery/Models/PersonModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
class PersonApi {
  static const String _baseUrl = "${Env.baseUrl}/api/User";

  Future<List> getPersonsByEvent(dynamic eventID) async {
    print("Fetching persons for event ID: $eventID");
    SharedPreferences sp = await SharedPreferences.getInstance();
    int hostId = await sp.getInt("hostID")!;
    final response = await http.get(Uri.parse('$_baseUrl/by-host/$hostId'));
    // var response = await http.get(Uri.parse("${Env.baseUrl}/api/Event/$eventID"));
    print("Response: ${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load users for event ID: $eventID");
    }
  }


  Future<bool> insertUser(PersonModel productModel)async{
    try {
      // Get hostId from SharedPreferences
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID");

      if (hostId == null) {
        print("hostID not found in SharedPreferences");
        return false;
      }

      // Add hostId to the event
      productModel.hostID = hostId;  // Make sure 'hostId' is a field in Event class

      print("product : ${productModel.toJson()}");

      // Send request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(productModel.toJson()),
      );

      print("response is &&&&&&&&&&&&&&& ${response.statusCode}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  Future<bool> updateUser(PersonModel personModel, dynamic userID) async {
    print("response is &&&&&&&&&&&&&&& for update user ${personModel.toJson()} ::: ${personModel.toJson()}");

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID");

      if (hostId == null) {
        print("hostID not found in SharedPreferences");
        return false;
      }

      // Add hostId to the event
      personModel.hostID = hostId;  // Make sure 'hostId' is a field in Event class

      print("person : ${personModel.toJson()}");
      final response = await http.put(
        Uri.parse("$_baseUrl/$userID"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(personModel.toJson()),
      );

      print("response is &&&&&&&&&&&&&&& for update  ${response.statusCode}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  Future<bool> deleteUser(dynamic userID) async {
    try {
      final url = Uri.parse("$_baseUrl/$userID");
      final response = await http.delete(url);

      print('DELETE Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Check for 204 (No Content) or 200 (OK)
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true; // Successfully deleted
      } else {
        // Handle unexpected status codes
        final Map<String, dynamic> errorResponse = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'error': 'Unknown error occurred'};
        throw Exception(errorResponse['error']);
      }
    } catch (e) {
      print('Error deleting person: $e');
      throw Exception('Error deleting event: $e');
    }
  }

  Future<List> fetchPersonByHostId() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    int hostId = await sp.getInt("hostID")!;
    final response = await http.get(Uri.parse('$_baseUrl/by-host/$hostId'));
    return jsonDecode(response.body.toString());
  }


// Future<bool> deleteUser(int userID) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse("$_baseUrl/$userID"),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 204) {
  //       return true;
  //     } else {
  //       print("Error: ${response.body}");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Exception: $e");
  //     return false;
  //   }
  // }
}
