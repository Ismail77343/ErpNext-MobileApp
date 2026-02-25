class User {
  final String name;
  final String email;
  final List<String> roles;

  User({required this.name, required this.email, required this.roles});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json["full_name"] ?? "",
      email: json["email"] ?? "",
      roles: List<String>.from(json["roles"] ?? []),
    );
  }
}