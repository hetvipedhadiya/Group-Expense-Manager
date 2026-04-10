import 'package:grocery/Models/InsertEventModel.dart';
import 'package:grocery/env.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EventApi {
  // Define the base URL for the API
  static const String _baseUrl = "${Env.baseUrl}/api/Event";

  //static const String _baseUrl = "http://10.20.58.148:5033/api/Event";

  Future<List> getAllEvent() async {
    try {
      print("::::Fetching Data from API::::");

      var response = await http.get(Uri.parse(_baseUrl)).timeout(Duration(seconds: 10));

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error: Failed to load data, Status Code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error occurred: $error");
      return [];
    }
  }

  Future<List> fetchEventsByHostId() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    int hostId = await sp.getInt("hostID")!;
    final response = await http.get(Uri.parse('$_baseUrl/host-events/$hostId'));
    return jsonDecode(response.body.toString());
  }

  Future<List> getById(dynamic eventID) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    int hostId = await sp.getInt("hostID")!;
    var response = await http.get(Uri.parse("$_baseUrl/event/$eventID/$hostId"));
    return jsonDecode(response.body.toString());
  }

  Future<bool> deleteEvent(dynamic eventID) async {
    try {
      final url = Uri.parse("$_baseUrl/$eventID");
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
      print('Error deleting event: $e');
      throw Exception('Error deleting event: $e');
    }
  }

  Future<bool> insertEvent(Event event) async {
    try {
      // Get hostId from SharedPreferences
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID");

      if (hostId == null) {
        print("hostID not found in SharedPreferences");
        return false;
      }

      // Add hostId to the event
      event.hostID = hostId;  // Make sure 'hostId' is a field in Event class

      print("event : ${event.toJson()}");

      // Send request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.toJson()),
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


  Future<bool> updateData(Event event, dynamic eventID) async {
    print("response is &&&&&&&&&&&&&&& ${event.toJson()} ::: $eventID");
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID");

      if (hostId == null) {
        print("hostID not found in SharedPreferences");
        return false;
      }

      // Add hostId to the event
      event.hostID = hostId;  // Make sure 'hostId' is a field in Event class

      print("event : ${event.toJson()}");
      final response = await http.put(
        Uri.parse("$_baseUrl/$eventID"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.toJson()),
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
}
