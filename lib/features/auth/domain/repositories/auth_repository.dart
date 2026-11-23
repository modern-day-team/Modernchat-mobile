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

  /// 确认桌面端扫码登录票据（需当前设备已登录）。
  Future<void> confirmQrLogin(String ticket);

  Future<User> restoreSession(String token);
}
