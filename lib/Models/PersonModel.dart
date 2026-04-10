class PersonModel {
  int? eventID;
  dynamic? userID;
  String userName;
  String? userImage;
  int? hostID;

  PersonModel({
    required this.eventID,
    this.userID,
    required this.userName,
    this.userImage,
    this.hostID,
  });

  // Convert from JSON
  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      userID: json['userID'],
      eventID: json['eventID'],
      userName: json['userName'] ?? '',
      userImage: json['userImage'],
      hostID: json['hostId'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'userName': userName,
      'userImage': userImage,
      'eventID': eventID,
      'hostId': hostID,
    };

    if (userID != null) {
      json['userID'] = userID;
    }
    return json;
  }
}
