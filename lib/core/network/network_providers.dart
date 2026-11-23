import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'network_config.dart';
import 'version_service.dart';
import 'ws_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: apiBaseUrl);
});

final wsClientProvider = Provider<WsClient>((ref) {
  final client = WsClient();
  ref.onDispose(client.dispose);
  return client;
});

/// 服务端最低版本探测（公开接口，失败按"无需升级"处理，不影响启动）。
final versionCheckProvider = FutureProvider<VersionCheck>((ref) async {
  final service = VersionService(ref.watch(apiClientProvider));
  try {
    return await service.check();
  } catch (_) {
    return const VersionCheck(version: '', minVersion: '', upgradeRequired: false);
  }
});
