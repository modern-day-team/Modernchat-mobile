import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AppUser> login({
    required String username,
    required String password,
  }) async {
    final data = await _remoteDataSource.login(
      username: username,
      password: password,
    );
    return AppUser(
      id: data['id'] as String? ?? '',
      username: data['username'] as String? ?? username,
      displayName: data['displayName'] as String?,
    );
  }

  @override
  Future<void> logout() async {
    // Token 清理由 core/storage 负责，此处保留领域契约。
  }
}
