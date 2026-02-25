import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.name,
    required super.email,
    required super.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["full_name"] ?? "",
      email: json["email"] ?? "",
      roles: List<String>.from(json["roles"] ?? []),
    );
  }
}
