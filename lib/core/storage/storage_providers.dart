import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return StorageService(prefs);
});
