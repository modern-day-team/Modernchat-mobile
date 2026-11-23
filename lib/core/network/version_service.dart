import 'api_client.dart';
import 'network_config.dart';

/// 服务端最低客户端版本协商：`GET /api/client/version`（公开）。
/// 只提示升级、不阻断旧端，避免离线发版时把用户锁在外面。
class VersionCheck {
  const VersionCheck({
    required this.version,
    required this.minVersion,
    required this.upgradeRequired,
    this.message,
  });

  final String version;
  final String minVersion;
  final bool upgradeRequired;
  final String? message;

  factory VersionCheck.fromJson(Map<String, dynamic> json) {
    return VersionCheck(
      version: json['version'] as String? ?? '',
      minVersion: json['minVersion'] as String? ?? '',
      upgradeRequired: json['upgradeRequired'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

class VersionService {
  const VersionService(this._api);

  final ApiClient _api;

  Future<VersionCheck> check() async {
    final data = await _api.get(
      '/client/version',
      queryParameters: ClientIdentity.wsQuery,
    );
    if (data is Map<String, dynamic>) return VersionCheck.fromJson(data);
    if (data is Map) {
      return VersionCheck.fromJson(Map<String, dynamic>.from(data));
    }
    return VersionCheck(version: '', minVersion: '', upgradeRequired: false);
  }
}
