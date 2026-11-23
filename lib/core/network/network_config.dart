import 'dart:io';

/// 开发环境 API 地址。Android 模拟器通过 10.0.2.2 访问宿主机。
/// 真机或生产环境请替换为实际服务地址。
const String apiBaseUrl = 'http://10.0.2.2:8080/api';

const String wsBaseUrl = 'ws://10.0.2.2:8080/ws';

/// 无 Origin 的原生客户端不受服务端 Origin 白名单限制。
const Duration wsHeartbeatInterval = Duration(seconds: 25);

/// 客户端身份：服务端据此在会话列表区分设备。
/// 与主仓库 web/src/core/network/http.ts 的 CLIENT_IDENTITY 口径一致。
class ClientIdentity {
  static const String platform = 'mobile';
  static const String appVersion = '1.0.0';

  static String get clientType =>
      Platform.isAndroid ? 'flutter-android' : 'flutter-ios';

  static Map<String, String> get headers => {
        'X-Client-Platform': platform,
        'X-Client-Type': clientType,
        'X-Client-Version': appVersion,
      };

  static Map<String, String> get wsQuery => {
        'platform': platform,
        'clientType': clientType,
        'appVersion': appVersion,
      };
}
