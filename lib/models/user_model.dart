class User {
  String? name;
  String? phoneNumber;
  String? JWT;

  User({
    required this.name,
    required this.phoneNumber,
    required this.JWT,
  });

  static User? _currentUser;

  static void setCurrentUser(User user) {
    _currentUser = user;
  }

  static User? getCurrentUser() {
    return _currentUser;
  }
}
