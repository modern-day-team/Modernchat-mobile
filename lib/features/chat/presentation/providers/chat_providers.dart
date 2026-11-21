import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../../../../core/network/network.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ChatRemoteDataSource(ref.watch(apiClientProvider)));
});

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

  @override
  Future<List<Conversation>> build() async {
    final subscription = ref.watch(wsClientProvider).events.listen(_onWsEvent);
    ref.onDispose(() {
      subscription.cancel();
      _refreshDebounce?.cancel();
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
    if (event.type == 'message' && _applyMessageEvent(event)) return;
    if (event.type != 'conv_change' &&
        event.type != 'message' &&
        event.type != 'user_change') {
      return;
    }
    _scheduleRefresh();
  }

  bool _applyMessageEvent(WsEvent event) {
    final raw = event.payload['message'];
    if (raw is! Map) return false;
    final current = state.value;
    if (current == null) return false;

    final message = Message.fromJson(Map<String, dynamic>.from(raw));
    final index = current.indexWhere((item) => item.id == message.conversationId);
    if (index < 0) return false;

    final updated = List<Conversation>.of(current);
    final conversation = current[index];
    final myId = ref.read(authUserIdProvider);
    updated[index] = conversation.copyWith(
      lastMessageId: message.id,
      lastMessageAt: message.createdAt,
      lastMessagePreview: message.content,
      lastMessageType: message.msgType,
      unreadCount: message.senderId == myId
          ? conversation.unreadCount
          : conversation.unreadCount + 1,
    );
    state = AsyncData(updated);
    return true;
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

  final int _conversationId;
  bool _hasMore = true;
  int? _oldestId;
  final Set<int> _messageIds = <int>{};
  final Map<String, ClientMessage> _pending = {};

  bool get hasMore => _hasMore;

  @override
  Future<List<Message>> build() async {
    final subscription = ref.watch(wsClientProvider).events.listen(_onWsEvent);
    ref.onDispose(subscription.cancel);
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
    final current = state.value;
    if (current == null) return;

    switch (event.type) {
      case 'message':
        final raw = event.payload['message'];
        final json = raw is Map
            ? Map<String, dynamic>.from(raw)
            : event.payload;
        final message = Message.fromJson(json);
        if (message.conversationId != _conversationId) return;
        final clientMsgId = message.clientMsgId;
        final pending = clientMsgId.isEmpty ? null : _pending.remove(clientMsgId);
        if (pending != null) {
          final optimistic = current
              .where((item) => item.clientMsgId == clientMsgId)
              .toList();
          for (final item in optimistic) {
            _messageIds.remove(item.id);
          }
          _messageIds.add(message.id);
          final replaced = current
              .map((m) => m.clientMsgId == clientMsgId ? message : m)
              .toList();
          state = AsyncData(replaced);
          return;
        }
        if (_messageIds.contains(message.id)) return;
        _messageIds.add(message.id);
        state = AsyncData([...current, message]);
      case 'recall':
        final id = (event.payload['messageId'] as num?)?.toInt() ?? 0;
        state = AsyncData(
          current.map((m) => m.id == id ? _withRecalled(m) : m).toList(),
        );
      case 'message_update':
        final id = (event.payload['id'] as num?)?.toInt() ?? 0;
        final content = asString(event.payload['content']);
        state = AsyncData(
          current.map((m) => m.id == id ? _withEdited(m, content) : m).toList(),
        );
      case 'error':
        final clientMsgId = event.payload['clientMsgId'] as String?;
        if (clientMsgId != null) _pending.remove(clientMsgId);
      default:
        break;
    }
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
