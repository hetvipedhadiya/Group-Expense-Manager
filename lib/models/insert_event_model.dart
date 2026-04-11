class Event {
  dynamic? eventID;
  String eventName;
  DateTime eventDate;
 int? hostID;

  Event({
    this.eventID,
    required this.eventName,
    required this.eventDate,
    this.hostID
  });

  // Convert from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventID: json['eventID'],
      eventName: json['eventName'],
      eventDate: DateTime.parse(json['eventDate']),
     hostID: json['hostID'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'hostID':hostID
    };
  }
}
