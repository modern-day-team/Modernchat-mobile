import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'network_config.dart';
import 'ws_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: apiBaseUrl);
});

final wsClientProvider = Provider<WsClient>((ref) {
  final client = WsClient();
  ref.onDispose(client.dispose);
  return client;
});
