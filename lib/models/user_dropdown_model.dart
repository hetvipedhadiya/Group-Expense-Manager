class UserDropDownModel {
  int? _userID;
  String? _userName;
  int? _eventId;

  UserDropDownModel({int? userID, String? userName, int? eventId}) {
    if (userID != null) {
      this._userID = userID;
    }
    if (userName != null) {
      this._userName = userName;
    }
    if (eventId != null) {
      this._eventId = eventId;
    }
  }

  int? get userID => _userID;
  set userID(int? userID) => _userID = userID;
  String? get userName => _userName;
  set userName(String? userName) => _userName = userName;
  int? get eventId => _eventId;
  set eventId(int? eventId) => _eventId = eventId;

  UserDropDownModel.fromJson(Map<String, dynamic> json) {
    _userID = json['userID'];
    _userName = json['userName'];
    _eventId = json['eventId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this._userID;
    data['userName'] = this._userName;
    data['eventId'] = this._eventId;
    return data;
  }
}

