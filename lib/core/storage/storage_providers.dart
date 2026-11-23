import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// 系统安全存储：Android Keystore / iOS Keychain（令牌专用，非偏好设置）。
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  // v11 默认使用 Android Keystore / iOS Keychain，无需额外选项
  return const FlutterSecureStorage();
});

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return StorageService(ref.watch(secureStorageProvider), prefs);
});
