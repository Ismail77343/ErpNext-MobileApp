import '../../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSource(this.client);

  Future<UserModel> login(String email, String password) async {
    await client.login(email, password);
    return UserModel(name: "", email: email, roles: const []);
  }
}
