import 'package:grocery/models/insert_event_model.dart';
import 'package:grocery/database_helper.dart';

class EventDatabase {
  /// Fetches all events from the database globally.
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

  /// Fetches all events owned by the current active host along with their total transaction amounts.
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

  /// Fetches a specific event by its [eventID], ensuring it belongs to the active host.
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

  /// Deletes a specific event from the database based on the provided [eventID].
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

  /// Inserts a new event into the database and associates it with the active host.
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

  /// Updates an existing event's details in the database using the provided [eventID].
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


