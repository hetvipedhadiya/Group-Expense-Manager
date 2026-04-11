import 'package:grocery/models/person_model.dart';
import 'package:grocery/database_helper.dart';

class PersonDatabase {
  Future<List> getPersonsByEvent(dynamic eventID) async {
    try {
      const int hostId = 1;
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'persons',
        where: 'eventID = ? AND hostID = ?',
        whereArgs: [eventID, hostId],
      );
      return result;
    } catch (error) {
      print("Error occurred: $error");
      return [];
    }
  }

  Future<bool> insertUser(PersonModel productModel) async {
    try {
      const int hostId = 1;
      productModel.hostID = hostId;

      final db = await DatabaseHelper.instance.database;
      int id = await db.insert('persons', productModel.toJson());
      return id > 0;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  Future<bool> updateUser(PersonModel personModel, dynamic userID) async {
    try {
      const int hostId = 1;
      personModel.hostID = hostId;

      final db = await DatabaseHelper.instance.database;
      int updated = await db.update(
        'persons',
        personModel.toJson(),
        where: 'userID = ?',
        whereArgs: [userID],
      );
      return updated > 0;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  Future<bool> deleteUser(dynamic userID) async {
    try {
      final db = await DatabaseHelper.instance.database;
      int deleted = await db.delete(
        'persons',
        where: 'userID = ?',
        whereArgs: [userID],
      );
      return deleted > 0;
    } catch (e) {
      print('Error deleting person: $e');
      throw Exception('Error deleting event: $e');
    }
  }

  Future<List> fetchPersonByHostId() async {
    try {
      const int hostId = 1;
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'persons',
        where: 'hostID = ?',
        whereArgs: [hostId],
      );
      return result;
    } catch (error) {
      print("Error occurred: $error");
      return [];
    }
  }
}


