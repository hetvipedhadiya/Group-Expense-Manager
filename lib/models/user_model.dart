class UserModel {
  int? hostId;
  String email;
  String password;
  String confirmPassword;
  String mobileNo;
  String? createAt;   // Optional: used only if returned by API
  bool? isActive;     // Optional: used only if returned by API

  UserModel({
    this.hostId,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.mobileNo,
    this.createAt,
    this.isActive,
  });

  // From API response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      hostId: json['hostId'],
      email: json['email'],
      password: json['password'],
      confirmPassword: json['confirmPassword'] ?? '',
      mobileNo: json['mobileNo'],
      createAt: json['createAt'],
      isActive: json['isActive'] == 1 || json['isActive'] == true,
    );
  }

  // For sending to API (SignUpScreen)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'mobileNo': mobileNo,
    };
  }
}

