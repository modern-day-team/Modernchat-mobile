import '../../../../core/model/models.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/app_user.dart';
import '../models/auth_body.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResult> login(String username, String password) async {
    final body = await _apiClient.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return _parseAuthResult(body);
  }

  Future<AuthResult> register(RegisterBody input) async {
    final body = await _apiClient.post(
      '/auth/register',
      data: input.toJson(),
    );
    return _parseAuthResult(body);
  }

  Future<User> currentUser() async {
    final body = await _apiClient.get('/me');
    if (body is! Map) {
      throw StateError('当前用户响应格式错误');
    }
    return User.fromJson(Map<String, dynamic>.from(body));
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }

  /// 手机端确认桌面扫码登录（需当前设备 JWT）。
  Future<void> confirmQrLogin(String ticket) async {
    await _apiClient.post('/auth/qr/confirm', data: {'token': ticket});
  }

  AuthResult _parseAuthResult(Map<String, dynamic> body) {
    final userJson = body['user'];
    if (userJson is! Map) {
      return AuthResult(
        token: '',
        user: User(
          id: 0,
          username: '',
          nickname: '',
          avatarColor: '#0052d9',
        ),
      );
    }
    return AuthResult(
      token: asString(body['token']),
      user: User.fromJson(Map<String, dynamic>.from(userJson)),
    );
  }
}
