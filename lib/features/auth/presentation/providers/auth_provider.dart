import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/network.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSource(apiClient),
    storage: StorageService(prefs),
    apiClient: apiClient,
  );
});

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
    SharedPreferences prefs;
    try {
      prefs = await ref.watch(sharedPreferencesProvider.future);
    } catch (_) {
      return AuthState.guest;
    }
    final token = StorageService(prefs).token;
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

  /// 与 logout 的区别：不请求服务端（令牌已被撤销），只清本地状态。
  Future<void> _forceGuest() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await StorageService(prefs).clearToken();
    ref.read(apiClientProvider).clearToken();
    ref.read(wsClientProvider).disconnect();
    if (!state.isLoading) state = const AsyncData(AuthState.guest);
  }

  Future<void> _connectWs(String token) async {
    ref.read(wsClientProvider).connect(token);
  }
}
