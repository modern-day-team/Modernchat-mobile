/// 开发环境 API 地址。Android 模拟器通过 10.0.2.2 访问宿主机。
/// 真机或生产环境请替换为实际服务地址。
const String apiBaseUrl = 'http://10.0.2.2:8080/api';

const String wsBaseUrl = 'ws://10.0.2.2:8080/ws';

/// 无 Origin 的原生客户端不受服务端 Origin 白名单限制。
const Duration wsHeartbeatInterval = Duration(seconds: 25);
