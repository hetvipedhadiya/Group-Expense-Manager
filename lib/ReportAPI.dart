import 'package:grocery/Models/TransactionReportModel.dart'; 
import 'package:grocery/database_helper.dart';

class ReportAPI {
  Future<Map<String, dynamic>> getAllReport(int eventID) async {
    try {
      const int hostId = 1;

      final db = await DatabaseHelper.instance.database;

      final membersRes = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM persons WHERE eventID = ? AND hostID = ?', 
        [eventID, hostId]
      );
      int totalMembers = membersRes.first['cnt'] as int? ?? 0;

      final incomeRes = await db.rawQuery(
        "SELECT SUM(amount) as s FROM transactions WHERE eventID = ? AND hostId = ? AND transactionType = 'credit'", 
        [eventID, hostId]
      );
      double totalIncome = (incomeRes.first['s'] as num?)?.toDouble() ?? 0.0;

      final expenseRes = await db.rawQuery(
        "SELECT SUM(amount) as s FROM transactions WHERE eventID = ? AND hostId = ? AND transactionType = 'debit'", 
        [eventID, hostId]
      );
      double totalExpense = (expenseRes.first['s'] as num?)?.toDouble() ?? 0.0;

      double expensePerHead = totalMembers > 0 ? (totalExpense / totalMembers) : 0.0;

      return {
        'totalMembers': totalMembers,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'expensePerHead': expensePerHead,
      };
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionodMember(int eventID) async {
    try {
      const int hostId = 1;

      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('''
        SELECT p.userName as member, 
               SUM(CASE WHEN t.transactionType = 'credit' THEN t.amount ELSE 0 END) as income,
               SUM(CASE WHEN t.transactionType = 'debit' THEN t.amount ELSE 0 END) as expense
        FROM persons p
        LEFT JOIN transactions t ON p.userID = t.userID AND t.eventID = p.eventID
        WHERE p.eventID = ? AND p.hostID = ?
        GROUP BY p.userID, p.userName
      ''', [eventID, hostId]);

      return List<Map<String, dynamic>>.from(result.map((map) => Map<String, dynamic>.from(map)));
    } catch (e) {
      print("Error fetching members: $e");
      throw Exception(e);
    }
  }
}
