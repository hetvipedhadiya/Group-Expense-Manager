import 'package:grocery/models/person_model.dart';
import 'package:grocery/database_helper.dart';

class PersonDatabase {
  /// Retrieves a list of all persons/members associated with a specific [eventID].
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

  /// Inserts a new person into the database under the current host.
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

  /// Updates an existing person's details in the database using their [userID].
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

  /// Deletes a specific person from the database based on the provided [userID].
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

  /// Fetches all persons associated with the currently active host globally.
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


