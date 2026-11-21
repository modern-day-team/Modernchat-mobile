import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

const String apiBaseUrl = 'http://10.0.2.2:8080';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: apiBaseUrl);
});
