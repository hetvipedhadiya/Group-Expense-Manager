import 'dart:convert';
import 'package:grocery/Models/TransactionReportModel.dart'; // Import your model
import 'package:grocery/env.dart';
import 'package:http/http.dart' as http;

class ReportAPI {
  static const String _baseUrl = "${Env.baseUrl}/api/Transaction";

  Future<Map<String, dynamic>> getAllReport(int eventID) async {
    try {
      print("Fetching report for event ID: $eventID");
      var response = await http.get(Uri.parse("$_baseUrl/overall/$eventID"));
      print("Response for report table: ${response.body}");

      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body;
      }
      return {};
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }


  Future<List<Map<String, dynamic>>> getTransactionodMember(int eventID) async {
    try {
      print("Fetching persons for event ID: $eventID");
      var response = await http.get(Uri.parse("$_baseUrl/members/$eventID"));
      print("Response for member in report table: ${response.body}");
      final List<dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(body); // ✅ Convert to List of Maps
      }
      return [];
    } catch (e) {
      print("Error fetching members: $e");
      throw Exception(e);
    }
  }

}
