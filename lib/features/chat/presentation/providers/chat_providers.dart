import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../../../../core/network/network.dart';
import '../../../../di/repository_providers.dart' show chatRepositoryProvider;
export '../../../../di/repository_providers.dart' show chatRepositoryProvider;
import '../../../auth/presentation/providers/auth_provider.dart';

class ClientMessage {
  const ClientMessage({
    required this.clientMsgId,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  final String clientMsgId;
  final String content;
  final int senderId;
  final String createdAt;
}

final conversationListProvider =
    AsyncNotifierProvider<ConversationListController, List<Conversation>>(
  ConversationListController.new,
);

class ConversationListController extends AsyncNotifier<List<Conversation>> {
  Timer? _refreshDebounce;
  Timer? _messageFlushTimer;
  final Map<int, Message> _pendingMessages = <int, Message>{};

  @override
  Future<List<Conversation>> build() async {
    final subscription = ref.watch(wsClientProvider).events.listen(_onWsEvent);
    ref.onDispose(() {
      subscription.cancel();
      _refreshDebounce?.cancel();
      _messageFlushTimer?.cancel();
    });
    return ref.read(chatRepositoryProvider).listConversations();
  }

  Future<void> refresh() async {
    await _load(() => ref.read(chatRepositoryProvider).listConversations());
  }

  Future<void> search(String keyword) async {
    await _load(
      () => ref
          .read(chatRepositoryProvider)
          .searchConversations(keyword.trim()),
    );
  }

  Future<void> _load(Future<List<Conversation>> Function() loader) async {
    final previous = state.value;
    final result = await AsyncValue.guard(loader);
    final next = result.value;
    if (next != null) {
      state = AsyncData(next);
      return;
    }
    if (previous == null) state = result;
  }

  void _onWsEvent(WsEvent event) {
    if (event.type == 'message' && _queueMessage(event)) return;
    if (event.type == 'conv_change' || event.type == 'user_change') {
      _scheduleRefresh();
    }
  }

  bool _queueMessage(WsEvent event) {
    final raw = event.payload['message'];
    if (raw is! Map) return false;
    _pendingMessages[event.convId] = Message.fromJson(
      Map<String, dynamic>.from(raw),
    );
    _messageFlushTimer ??= Timer(const Duration(milliseconds: 120), _flushMessages);
    return true;
  }

  void _flushMessages() {
    _messageFlushTimer = null;
    final pending = Map<int, Message>.of(_pendingMessages);
    _pendingMessages.clear();
    final current = state.value;
    if (current == null || pending.isEmpty) return;

    final indexes = <int, int>{};
    for (var i = 0; i < current.length; i++) {
      indexes[current[i].id] = i;
    }
    final updated = List<Conversation>.of(current);
    final myId = ref.read(authUserIdProvider);
    for (final entry in pending.entries) {
      final index = indexes[entry.key];
      if (index == null) continue;
      final conversation = current[index];
      final message = entry.value;
      updated[index] = conversation.copyWith(
        lastMessageId: message.id,
        lastMessageAt: message.createdAt,
        lastMessagePreview: message.content,
        lastMessageType: message.msgType,
        unreadCount: message.senderId == myId
            ? conversation.unreadCount
            : conversation.unreadCount + 1,
      );
    }
    state = AsyncData(updated);
  }

  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 260), () {
      if (ref.mounted) refresh();
    });
  }
}

final messageListProvider = AsyncNotifierProvider.family<
    MessageListController, List<Message>, int>(MessageListController.new);

class MessageListController extends AsyncNotifier<List<Message>> {
  MessageListController(this._conversationId);

  static const _maxPendingMessages = 64;

  final int _conversationId;
  bool _hasMore = true;
  int? _oldestId;
  final Set<int> _messageIds = <int>{};
  final Map<String, ClientMessage> _pending = {};
  final List<WsEvent> _eventQueue = <WsEvent>[];
  Timer? _eventFlushTimer;

  bool get hasMore => _hasMore;

  @override
  Future<List<Message>> build() async {
    final subscription = ref.watch(wsClientProvider).events.listen(_onWsEvent);
    ref.onDispose(() {
      subscription.cancel();
      _eventFlushTimer?.cancel();
    });
    return _load();
  }

  Future<List<Message>> _load() async {
    final page = await ref.read(chatRepositoryProvider).fetchMessages(
          _conversationId,
          limit: 30,
        );
    _hasMore = page.hasMore;
    final messages = List<Message>.of(page.messages);
    _messageIds
      ..clear()
      ..addAll(messages.map((message) => message.id));
    if (messages.isNotEmpty) _oldestId = messages.first.id;
    return messages..sort((a, b) => a.id.compareTo(b.id));
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _oldestId == null) return;
    final page = await ref.read(chatRepositoryProvider).fetchMessages(
          _conversationId,
          beforeId: _oldestId,
          limit: 30,
        );
    _hasMore = page.hasMore;
    final loaded = List<Message>.of(page.messages);
    if (loaded.isNotEmpty) _oldestId = loaded.first.id;
    _messageIds.addAll(loaded.map((message) => message.id));
    final merged = <Message>[...loaded, ...state.value ?? const <Message>[]];
    final ids = <int>{};
    state = AsyncData(
      merged.where((m) => ids.add(m.id)).toList()
        ..sort((a, b) => a.id.compareTo(b.id)),
    );
  }

  void _onWsEvent(WsEvent event) {
    if (event.convId != _conversationId) return;
    if (state.value == null) return;
    _eventQueue.add(event);
    _eventFlushTimer ??= Timer(const Duration(milliseconds: 80), _flushEvents);
  }

  void _flushEvents() {
    _eventFlushTimer = null;
    if (_eventQueue.isEmpty) return;
    final events = List<WsEvent>.of(_eventQueue);
    _eventQueue.clear();

    final current = state.value;
    if (current == null) return;
    var working = List<Message>.of(current);
    var changed = false;

    for (final event in events) {
      switch (event.type) {
        case 'message':
          if (_applyIncomingMessage(event, working)) {
            changed = true;
          }
        case 'recall':
          final id = (event.payload['messageId'] as num?)?.toInt() ?? 0;
          for (var i = 0; i < working.length; i++) {
            if (working[i].id == id) {
              working[i] = _withRecalled(working[i]);
              changed = true;
            }
          }
        case 'message_update':
          final id = (event.payload['id'] as num?)?.toInt() ?? 0;
          final content = asString(event.payload['content']);
          for (var i = 0; i < working.length; i++) {
            if (working[i].id == id) {
              working[i] = _withEdited(working[i], content);
              changed = true;
            }
          }
        case 'error':
          final clientMsgId = event.payload['clientMsgId'] as String?;
          if (clientMsgId != null) _pending.remove(clientMsgId);
        default:
          break;
      }
    }
    if (changed) state = AsyncData(working);
  }

  bool _applyIncomingMessage(WsEvent event, List<Message> working) {
    final raw = event.payload['message'];
    final json = raw is Map ? Map<String, dynamic>.from(raw) : event.payload;
    final message = Message.fromJson(json);
    if (message.conversationId != _conversationId) return false;

    final clientMsgId = message.clientMsgId;
    final pending = clientMsgId.isEmpty ? null : _pending.remove(clientMsgId);
    if (pending != null) {
      for (var i = 0; i < working.length; i++) {
        if (working[i].clientMsgId == clientMsgId) {
          _messageIds.remove(working[i].id);
          working[i] = message;
        }
      }
      _messageIds.add(message.id);
      return true;
    }
    if (_messageIds.contains(message.id)) return false;
    _messageIds.add(message.id);
    working.add(message);
    return true;
  }

  Message _withRecalled(Message m) => Message(
        id: m.id,
        conversationId: m.conversationId,
        senderId: m.senderId,
        clientMsgId: m.clientMsgId,
        msgType: m.msgType,
        content: m.content,
        createdAt: m.createdAt,
        isRecalled: true,
        recalledAt: DateTime.now().toUtc().toIso8601String(),
        editedAt: m.editedAt,
        replyToId: m.replyToId,
        replyTo: m.replyTo,
        mentions: m.mentions,
        reactions: m.reactions,
        adminDeletedAt: m.adminDeletedAt,
      );

  Message _withEdited(Message m, String content) => Message(
        id: m.id,
        conversationId: m.conversationId,
        senderId: m.senderId,
        clientMsgId: m.clientMsgId,
        msgType: m.msgType,
        content: content,
        createdAt: m.createdAt,
        isRecalled: m.isRecalled,
        recalledAt: m.recalledAt,
        editedAt: DateTime.now().toUtc().toIso8601String(),
        replyToId: m.replyToId,
        replyTo: m.replyTo,
        mentions: m.mentions,
        reactions: m.reactions,
        adminDeletedAt: m.adminDeletedAt,
      );

  void sendText(String content) {
    final clientMsgId = DateTime.now().microsecondsSinceEpoch.toString();
    final current = state.value ?? const <Message>[];
    final myId = ref.read(authUserIdProvider);
    final optimistic = Message(
      id: -current.length - 1,
      conversationId: _conversationId,
      senderId: myId ?? 0,
      clientMsgId: clientMsgId,
      msgType: 'text',
      content: content,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    if (_pending.length >= _maxPendingMessages) {
      _pending.remove(_pending.keys.first);
    }
    _pending[clientMsgId] = ClientMessage(
      clientMsgId: clientMsgId,
      content: content,
      senderId: myId ?? 0,
      createdAt: optimistic.createdAt,
    );
    _messageIds.add(optimistic.id);
    state = AsyncData([...current, optimistic]);
    ref.read(wsClientProvider).sendChat(
          convId: _conversationId,
          clientMsgId: clientMsgId,
          content: content,
        );
  }
}

final authUserIdProvider = Provider<int?>((ref) {
  return ref.watch(authControllerProvider).value?.userId;
});
