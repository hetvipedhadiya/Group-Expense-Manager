import 'package:grocery/Models/InsertEventModel.dart';
import 'package:grocery/database_helper.dart';

class EventApi {
  Future<List> getAllEvent() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('events');
      return result;
    } catch (error) {
      print("Error occurred: $error");
      return [];
    }
  }

  Future<List> fetchEventsByHostId() async {
    try {
      const int hostId = 1;
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('''
        SELECT e.*, IFNULL(SUM(t.amount), 0) as amount
        FROM events e
        LEFT JOIN transactions t ON e.eventID = t.eventID
        WHERE e.hostID = ?
        GROUP BY e.eventID
      ''', [hostId]);
      return result;
    } catch (error) {
      print("Error occurred: $error");
      return [];
    }
  }

  Future<List> getById(dynamic eventID) async {
    try {
      const int hostId = 1;
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'events',
        where: 'eventID = ? AND hostID = ?',
        whereArgs: [eventID, hostId],
      );
      return result;
    } catch (error) {
      print("Error occurred: $error");
      return [];
    }
  }

  Future<bool> deleteEvent(dynamic eventID) async {
    try {
      final db = await DatabaseHelper.instance.database;
      int deleted = await db.delete(
        'events',
        where: 'eventID = ?',
        whereArgs: [eventID],
      );
      return deleted > 0;
    } catch (e) {
      print('Error deleting event: $e');
      throw Exception('Error deleting event: $e');
    }
  }

  Future<bool> insertEvent(Event event) async {
    try {
      const int hostId = 1;
      event.hostID = hostId;

      final db = await DatabaseHelper.instance.database;
      int id = await db.insert('events', event.toJson());
      return id > 0;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  Future<bool> updateData(Event event, dynamic eventID) async {
    try {
      const int hostId = 1;
      event.hostID = hostId;

      final db = await DatabaseHelper.instance.database;
      int updated = await db.update(
        'events',
        event.toJson(),
        where: 'eventID = ?',
        whereArgs: [eventID],
      );
      return updated > 0;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
}
