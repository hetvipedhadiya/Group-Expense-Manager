import 'package:grocery/models/transaction_model.dart';
import 'package:grocery/database_helper.dart';

class TransactionDatabase {
  /// Retrieves all transaction records globally and parses them into TransactionModel objects.
  Future<List<TransactionModel>> getAllTransaction() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('transactions');
      return result.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to load transactions");
    }
  }

  /// Retrieves all transactions for a specific [eventID], joining person and event tables to get comprehensive details.
  Future<List<dynamic>> getTransactionByEvent(dynamic eventID) async {
    try {
      const int hostId = 1;
      
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('''
        SELECT t.*, p.userName, e.eventName 
        FROM transactions t
        LEFT JOIN persons p ON t.userID = p.userID
        LEFT JOIN events e ON t.eventID = e.eventID
        WHERE t.eventID = ? AND t.hostId = ?
      ''', [eventID, hostId]);
      
      List<Map<String, dynamic>> modifiableList = List<Map<String, dynamic>>.from(result.map((map) => Map<String, dynamic>.from(map)));

      for (var item in modifiableList) {
        item['userName'] = item['userName'] ?? '';
        item['eventName'] = item['eventName'] ?? '';
        item['description'] = item['description'] ?? '';
        item['currency'] = item['currency'] ?? 'USD'; 
      }

      return modifiableList;
    } catch (e) {
      throw Exception("Failed to load transaction for event ID: $eventID");
    }
  }

  /// Inserts a new transaction into the database under the current host.
  Future<bool> insertTransaction(TransactionModel transaction) async {
    try {
      const int hostId = 1;
      transaction.hostId = hostId;

      final db = await DatabaseHelper.instance.database;
      int id = await db.insert('transactions', transaction.toJson());
      return id > 0;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  /// Updates an existing transaction's details in the database using its [expenseID].
  Future<bool> updateTransaction(TransactionModel transaction, int expenseID) async {
    try {
      const int hostId = 1;
      transaction.hostId = hostId;

      final db = await DatabaseHelper.instance.database;
      int updated = await db.update(
        'transactions',
        transaction.toJson(),
        where: 'expenseID = ?',
        whereArgs: [expenseID],
      );
      return updated > 0;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  /// Deletes a specific transaction from the database based on its [transactionID].
  Future<bool> deleteTransaction(int transactionID) async {
    try {
      final db = await DatabaseHelper.instance.database;
      int deleted = await db.delete(
        'transactions',
        where: 'expenseID = ?',
        whereArgs: [transactionID],
      );
      return deleted > 0;
    } catch (e) {
      print('Error deleting transaction: $e');
      throw Exception('Error deleting transaction: $e');
    }
  }

  /// Retrieves a list of persons acting as a dropdown lookup source for assigning a new transaction to a member.
  Future<List<dynamic>> getUserDropdown(int eventID) async {
    try {
      const int hostId = 1;

      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'persons',
        where: 'eventID = ? AND hostID = ?',
        whereArgs: [eventID, hostId],
      );
      return result;
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }
}


