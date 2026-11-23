import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'network_config.dart';

class WsEvent {
  const WsEvent({
    required this.type,
    required this.payload,
  });

  final String type;
  final Map<String, dynamic> payload;

  factory WsEvent.fromJson(Map<String, dynamic> json) {
    return WsEvent(
      type: json['type'] as String? ?? '',
      payload: json,
    );
  }

  int get convId => (payload['convId'] as num?)?.toInt() ?? 0;
}

class WsClient {
  WsClient();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeat;
  final StreamController<WsEvent> _events =
      StreamController<WsEvent>.broadcast();
  void Function()? _onConnected;
  void Function(Object error)? _onError;
  void Function(String reason)? _onKicked;

  Stream<WsEvent> get events => _events.stream;

  bool get isConnected => _channel != null;

  void setCallbacks({
    void Function()? onConnected,
    void Function(Object error)? onError,
    void Function(String reason)? onKicked,
  }) {
    _onConnected = onConnected;
    _onError = onError;
    _onKicked = onKicked;
  }

  void connect(String token) {
    disconnect();
    final query = <String, String>{
      'token': token,
      ...ClientIdentity.wsQuery,
    };
    final uri = Uri.parse('$wsBaseUrl?${Uri(queryParameters: query)}');
    try {
      _channel = WebSocketChannel.connect(uri);
      _onConnected?.call();
      _subscription = _channel!.stream.listen(
        (raw) => _handleRaw(raw),
        onError: (error) {
          _onError?.call(error);
        },
        onDone: disconnect,
      );
      _heartbeat?.cancel();
      _heartbeat = Timer.periodic(wsHeartbeatInterval, (_) => send({'type': 'ping'}));
    } catch (e) {
      _onError?.call(e);
    }
  }

  void _handleRaw(dynamic raw) {
    if (raw is! String) return;
    try {
      // dart:convert 避免顶层 import 冲突，使用 StrictMap 解析。
      final decoded = _decodeJson(raw);
      if (decoded != null) {
        if (decoded['type'] == 'kicked') {
          final reason = decoded['reason'] as String? ?? '登录状态已失效';
          disconnect();
          _onKicked?.call(reason);
          return;
        }
        _events.add(WsEvent.fromJson(decoded));
      }
    } catch (_) {
      // 忽略无法解析的帧，避免单条异常断开连接。
    }
  }

  Map<String, dynamic>? _decodeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  void send(Map<String, dynamic> frame) {
    final channel = _channel;
    if (channel == null) return;
    channel.sink.add(jsonEncode(frame));
  }

  void sendChat({
    required int convId,
    required String clientMsgId,
    required String content,
    String msgType = 'text',
    int? replyToId,
    List<int>? mentions,
    Object? forwarded,
  }) {
    send({
      'type': 'chat',
      'convId': convId,
      'clientMsgId': clientMsgId,
      'content': content,
      'msgType': msgType,
      'replyToId': ?replyToId,
      'mentions': ?mentions,
      'forwarded': ?forwarded,
    });
  }

  void sendTyping(int convId) => send({'type': 'typing', 'convId': convId});

  void sendRead(int convId, int upToId) =>
      send({'type': 'read', 'convId': convId, 'upToId': upToId});

  void sendRecall(int messageId) =>
      send({'type': 'recall', 'messageId': messageId});

  void sendEdit(int messageId, String content) =>
      send({'type': 'edit', 'messageId': messageId, 'content': content});

  void sendReaction(int messageId, String emoji, bool set) => send({
        'type': 'reaction',
        'messageId': messageId,
        'emoji': emoji,
        'action': set ? 'set' : 'remove',
      });

  void sendDelivered(int messageId) =>
      send({'type': 'delivered', 'messageId': messageId});

  void disconnect() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _events.close();
  }
}
