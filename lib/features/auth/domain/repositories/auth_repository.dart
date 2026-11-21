import '../../../../core/model/models.dart';
import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Future<AuthResult> login({
    required String username,
    required String password,
  });

  Future<AuthResult> register({
    required String username,
    required String password,
    required String nickname,
    String? inviteCode,
    String? email,
    String? emailCode,
  });

  Future<User> currentUser();

  Future<void> logout();

  Future<User> restoreSession(String token);
}
