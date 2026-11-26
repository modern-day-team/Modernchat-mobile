// 契约金样本回归：移动端 WS 帧解析口径必须与主仓库金样本一致。
// 金样本来源：主仓库 Modernchat-new contracts/ws-frames.json 的同步副本
// （test/fixtures/contracts/ws_frames.json），CI 以 sha256 指纹校验防手改。
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modernchat_mobile/core/network/ws_client.dart';

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/contracts/ws_frames.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  group('契约金样本（test/fixtures/contracts/ws_frames.json，真源在主仓库）', () {
    final serverFrames = (fixture['serverToClient'] as Map).cast<String, dynamic>();

    test('服务端金样本全部可解析为 WsEvent 且类型保持', () {
      serverFrames.forEach((type, raw) {
        final event = WsEvent.fromJson(Map<String, dynamic>.from(raw as Map));
        expect(event.type, equals(type), reason: '服务端帧 $type 解析后类型应保持');
      });
    });

    test('message 帧字段口径与主仓库一致', () {
      final event = WsEvent.fromJson(
        Map<String, dynamic>.from(serverFrames['message'] as Map),
      );
      expect(event.payload['id'], equals(1025));
      expect(event.convId, equals(1));
      expect((event.payload['from'] as Map)['id'], equals(7));
      expect(event.payload['clientMsgId'], equals('3f2504e0-4f89-11d3-9a0c-0305e82c3301'));
      expect(event.payload['msgType'], equals('text'));
      expect(event.payload['createdAt'], equals('2026-11-26T08:00:00Z'));
    });

    test('kicked 帧保留中文 reason（登录状态失效路径）', () {
      final frame = Map<String, dynamic>.from(serverFrames['kicked'] as Map);
      expect(frame['reason'] as String, isNotEmpty);
    });

    test('error 帧带 clientMsgId（定位失败的乐观消息）与中文 reason', () {
      final frame = Map<String, dynamic>.from(serverFrames['error'] as Map);
      expect(frame['clientMsgId'] as String, isNotEmpty);
      expect(frame['reason'] as String, isNotEmpty);
    });

    test('reaction 帧字段口径一致（set / remove 双动作）', () {
      final event = WsEvent.fromJson(
        Map<String, dynamic>.from(serverFrames['reaction'] as Map),
      );
      expect(event.payload['action'], equals('set'));
      expect(event.payload['emoji'] as String, isNotEmpty);
    });

    test('上行帧契约键齐全：移动端 send* 方法消费的金样本', () {
      final clientFrames = (fixture['clientToServer'] as Map).cast<String, dynamic>();
      final required = <String, List<String>>{
        'chat': ['type', 'convId', 'clientMsgId', 'content', 'msgType', 'replyToId', 'mentions'],
        'typing': ['type', 'convId'],
        'read': ['type', 'convId', 'upToId'],
        'recall': ['type', 'messageId'],
        'edit': ['type', 'messageId', 'content'],
        'reaction': ['type', 'messageId', 'emoji', 'action'],
        'delivered': ['type', 'messageId'],
      };
      required.forEach((type, keys) {
        final golden = Map<String, dynamic>.from(clientFrames[type] as Map);
        for (final key in keys) {
          expect(golden.containsKey(key), isTrue, reason: '上行帧 $type 缺少契约键 $key');
        }
      });
    });
  });
}
