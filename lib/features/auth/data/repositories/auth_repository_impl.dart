import '../../../../core/model/models.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_body.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remote,
    required this.storage,
    required this.apiClient,
  });

  final AuthRemoteDataSource remote;
  final StorageService storage;
  final ApiClient apiClient;

  @override
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final result = await remote.login(username, password);
    await _persist(result);
    return result;
  }

  @override
  Future<AuthResult> register({
    required String username,
    required String password,
    required String nickname,
    String? inviteCode,
    String? email,
    String? emailCode,
  }) async {
    final result = await remote.register(RegisterBody(
      username: username,
      password: password,
      nickname: nickname,
      inviteCode: inviteCode,
      email: email,
      emailCode: emailCode,
    ));
    await _persist(result);
    return result;
  }

  @override
  Future<User> currentUser() => remote.currentUser();

  @override
  Future<void> logout() async {
    try {
      await remote.logout();
    } finally {
      await storage.clearToken();
      apiClient.clearToken();
    }
  }

  @override
  Future<void> confirmQrLogin(String ticket) => remote.confirmQrLogin(ticket);

  @override
  Future<User> restoreSession(String token) async {
    apiClient.setToken(token);
    try {
      return await remote.currentUser();
    } catch (_) {
      await storage.clearToken();
      apiClient.clearToken();
      rethrow;
    }
  }

  Future<void> _persist(AuthResult result) async {
    apiClient.setToken(result.token);
    await storage.saveToken(result.token);
  }
}
