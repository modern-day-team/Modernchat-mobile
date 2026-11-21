import '../../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) {
    return _apiClient.post(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );
  }
}
