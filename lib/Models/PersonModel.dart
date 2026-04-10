class PersonModel {
  int? eventID;
  dynamic? userID;
  String userName;
  int? hostID;
  //String UserImage;

  PersonModel({
    required this.eventID,
    this.userID,
    required this.userName,
    this.hostID
    //required this.UserImage
  });

  // Convert from JSON
  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return json['userID'] == null
        ? PersonModel(
            eventID: json['eventID'],
            userName: json['userName'],
            hostID: json['hostId']
            //UserImage:json['UserImage']
          )
        : PersonModel(
            userID: json['userID'],
            eventID: json['eventID'],
            userName: json['userName'],
            hostID: json['hostId']
            //UserImage: json['UserImage']
          );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'userName': userName,
      //'UserImage':UserImage,
      'eventID': eventID,
      'hostId':hostID
    };

    if (userID != null) {
      json['userID'] = userID;
    }
    return json;
  }
}
