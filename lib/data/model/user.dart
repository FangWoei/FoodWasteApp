class User {
  final String? userId;
  final String name;
  final String email;

  User({
    required this.userId,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "name": name,
      "email": email,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      userId: map["userId"],
      name: map["name"],
      email: map["email"],
    );
  }

  @override
  String toString() {
    return "User($userId, $name, $email)";
  }
}
