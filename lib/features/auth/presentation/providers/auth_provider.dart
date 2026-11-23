import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../di/repository_providers.dart' show authRepositoryProvider;
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/login_usecase.dart';

final loginUseCaseProvider = FutureProvider<LoginUseCase>((ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return LoginUseCase(repository);
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // 服务端强制下线（封禁 / 重置密码 / 单设备撤销）：清本地 token 并回到登录态。
    // 必须在任何网络调用前注册，避免首帧 kicked 被漏掉。
    ref.read(wsClientProvider).setCallbacks(
      onKicked: (_) => _forceGuest(),
    );
    final storage = await ref.watch(storageServiceProvider.future);
    final token = await storage.token();
    if (token == null || token.isEmpty) return AuthState.guest;

    final repository = await ref.watch(authRepositoryProvider.future);
    try {
      final user = await repository.restoreSession(token);
      return AuthState.authenticated(user, token);
    } catch (_) {
      return AuthState.guest;
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = await ref.read(loginUseCaseProvider.future);
      final result = await useCase(
        username: username,
        password: password,
      );
      await _connectWs(result.token);
      return AuthState.authenticated(result.user, result.token);
    });
  }

  Future<void> register({
    required String username,
    required String password,
    required String nickname,
    String? inviteCode,
    String? email,
    String? emailCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(authRepositoryProvider.future);
      final result = await repository.register(
        username: username,
        password: password,
        nickname: nickname,
        inviteCode: inviteCode,
        email: email,
        emailCode: emailCode,
      );
      await _connectWs(result.token);
      return AuthState.authenticated(result.user, result.token);
    });
  }

  Future<void> logout() async {
    final repository = await ref.read(authRepositoryProvider.future);
    await repository.logout();
    ref.read(wsClientProvider).disconnect();
    state = const AsyncData(AuthState.guest);
  }

  /// 确认桌面扫码登录（不改变当前设备登录态）。
  Future<void> confirmQrLogin(String ticket) async {
    final repository = await ref.read(authRepositoryProvider.future);
    await repository.confirmQrLogin(ticket);
  }

  /// 与 logout 的区别：不请求服务端（令牌已被撤销），只清本地状态。
  Future<void> _forceGuest() async {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.clearToken();
    ref.read(apiClientProvider).clearToken();
    ref.read(wsClientProvider).disconnect();
    if (!state.isLoading) state = const AsyncData(AuthState.guest);
  }

  Future<void> _connectWs(String token) async {
    ref.read(wsClientProvider).connect(token);
  }
}
