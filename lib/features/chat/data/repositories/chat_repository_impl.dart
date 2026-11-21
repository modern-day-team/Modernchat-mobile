import '../../../../core/model/models.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  Future<List<Conversation>> listConversations() => _remote.listConversations();

  @override
  Future<List<Conversation>> searchConversations(String keyword) =>
      _remote.searchConversations(keyword);

  @override
  Future<Conversation> createSingle(int toUserId) =>
      _remote.createSingle(toUserId);

  @override
  Future<Conversation> createGroup(String name) => _remote.createGroup(name);

  @override
  Future<void> renameGroup(int conversationId, String name) =>
      _remote.renameGroup(conversationId, name);

  @override
  Future<void> updatePrefs(
    int conversationId, {
    bool? pinned,
    bool? muted,
    bool? archived,
  }) =>
      _remote.updatePrefs(
        conversationId,
        pinned: pinned,
        muted: muted,
        archived: archived,
      );

  @override
  Future<void> markRead(int conversationId, int upToId) =>
      _remote.markRead(conversationId, upToId);

  @override
  Future<MessagePage> fetchMessages(
    int conversationId, {
    int? beforeId,
    int? afterId,
    int limit = 30,
  }) async {
    final body = await _remote.fetchMessages(
      conversationId,
      beforeId: beforeId,
      afterId: afterId,
      limit: limit,
    );
    final rawMessages = body['messages'];
    final messages = rawMessages is List
        ? rawMessages
            .whereType<Map>()
            .map((e) => Message.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <Message>[];
    return MessagePage(
      messages: messages,
      hasMore: asBool(body['hasMore']),
    );
  }

  @override
  Future<void> deleteMessage(int conversationId, int messageId) =>
      _remote.deleteMessage(conversationId, messageId);

  @override
  Future<List<ConversationMember>> listMembers(int conversationId) =>
      _remote.listMembers(conversationId);
}
