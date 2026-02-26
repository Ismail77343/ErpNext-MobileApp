class User {
  final String name;
  final String email;
  final List<String> roles;

  User({required this.name, required this.email, required this.roles});

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRoles = json["roles"];
    final roles = rawRoles is List
        ? rawRoles.map((e) => e.toString()).toList()
        : <String>[];

    return User(
      name: (json["user"] ?? json["full_name"] ?? json["name"] ?? "")
          .toString(),
      email: json["email"] ?? "",
      roles: roles,
    );
  }
}
