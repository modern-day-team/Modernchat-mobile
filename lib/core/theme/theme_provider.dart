import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../storage/storage_providers.dart';

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    try {
      final prefs = await ref.watch(sharedPreferencesProvider.future);
      return _fromName(prefs.getString(_key));
    } catch (_) {
      return ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = AsyncValue.data(mode);
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // 存储不可用时只保留本次会话的设置。
    }
  }

  ThemeMode _fromName(String? name) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}
