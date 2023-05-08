class User {
  final String phoneNumber;
  final String fullName;

  User({required this.phoneNumber, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'],
    );
  }
}