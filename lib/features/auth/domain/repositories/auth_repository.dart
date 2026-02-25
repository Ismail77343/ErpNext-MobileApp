import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
}