import 'package:grocery/Models/TransactionModel.dart';
import 'package:grocery/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TransactionAPI {
  static const String _baseUrl = "${Env.baseUrl}/api/Transaction";

  Future<List<TransactionModel>> getAllTransaction() async {
    var response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => TransactionModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load transactions");
    }
  }
  Future<List<dynamic>> getTransactionByEvent(dynamic eventID) async {
    print("Fetching Transaction ######## for event ID: $eventID");
    SharedPreferences sp = await SharedPreferences.getInstance();
    int hostId = await sp.getInt("hostID")!;
     var response = await http.get(Uri.parse('$_baseUrl/by-event/$eventID/$hostId'));
    // var response =
    //    await http.get(Uri.parse("${Env.baseUrl}/api/transaction/$eventID"));
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Replace null values with defaults
      for (var item in data) {
        item['userName'] = item['userName'] ?? '';
        item['eventName'] = item['eventName'] ?? '';
        item['description'] = item['description'] ?? '';
        item['currency'] = item['currency'] ?? 'USD'; // or any default
      }

      return data;
    } else {
      throw Exception("Failed to load transaction for event ID: $eventID");
    }
  }

  // Future<List<dynamic>> getTransactionByEvent(dynamic eventID) async {
  //   print("Fetching Transaction ######## for event ID: $eventID");
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   int hostId = await sp.getInt("hostID")!;
  //   final response = await http.get(Uri.parse('$_baseUrl/by-host/$hostId'));
  //   // var response =
  //   //     await http.get(Uri.parse("${Env.baseUrl}/api/transaction/$eventID"));
  //   print("Response: ${response.body}");
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception("Failed to load transaction for event ID: $eventID");
  //   }
  // }

  Future<bool> insertTransaction(TransactionModel transaction) async {
    try {
      // Get hostId from SharedPreferences
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID");

      if (hostId == null) {
        print("hostID not found in SharedPreferences");
        return false;
      }

      // Add hostId to the event
      transaction.hostId = hostId;  // Make sure 'hostId' is a field in Event class

      print("transaction : ${transaction.toJson()}");

      // Send request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transaction.toJson()),
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

  Future<bool> updateTransaction(TransactionModel transaction, int expenseID) async {
    print("response is &&&&&&&&&&&&&&& ${transaction.toJson()} ::: $expenseID");
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID");

      if (hostId == null) {
        print("hostID not found in SharedPreferences");
        return false;
      }

      // Add hostId to the event
      transaction.hostId = hostId;  // Make sure 'hostId' is a field in Event class

      print("event : ${transaction.toJson()}");
      final response = await http.put(
        Uri.parse("$_baseUrl/$expenseID"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transaction.toJson()),
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

  Future<bool> deleteTransaction(int transactionID) async {
    try {
      final url = Uri.parse("$_baseUrl/$transactionID");
      final response = await http.delete(url);

      print('DELETE Response Code for transaction: ${response.statusCode}');
      print('Response Body for transaction: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Successfully deleted
      } else {
        // Handle unexpected status codes
        final Map<String, dynamic> errorResponse = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'error': 'Unknown error occurred'};
        throw Exception(errorResponse['error']);
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      throw Exception('Error deleting transaction: $e');
    }
  }

  Future<List<dynamic>> getUserDropdown(int eventID) async {
    try {
      final response = await http
          .get(Uri.parse('${Env.baseUrl}/api/User/dropdown/$eventID'));
      final List<dynamic> body = json.decode(response.body);
      print("dropdown data #############$body");
      if (response.statusCode == 200) {
        // return  body.map((dynamic json) {
        //   final map = json as Map<String, dynamic>;
        //   return  UserDropDownModel(
        //     userID: map['userID'] as int,
        //     eventId: map['eventID'] as int,
        //     userName: map['userName'] as String,
        //   );
        // }).toList();
        return body;
      }
      return [];
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }
}
