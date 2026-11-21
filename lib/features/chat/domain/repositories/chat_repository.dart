import '../../../../core/model/models.dart';

class MessagePage {
  const MessagePage({
    required this.messages,
    required this.hasMore,
  });

  final List<Message> messages;
  final bool hasMore;
}

abstract interface class ChatRepository {
  Future<List<Conversation>> listConversations();
  Future<List<Conversation>> searchConversations(String keyword);
  Future<Conversation> createSingle(int toUserId);
  Future<Conversation> createGroup(String name);
  Future<void> renameGroup(int conversationId, String name);
  Future<void> updatePrefs(
    int conversationId, {
    bool? pinned,
    bool? muted,
    bool? archived,
  });
  Future<void> markRead(int conversationId, int upToId);
  Future<MessagePage> fetchMessages(
    int conversationId, {
    int? beforeId,
    int? afterId,
    int limit = 30,
  });
  Future<void> deleteMessage(int conversationId, int messageId);
  Future<List<ConversationMember>> listMembers(int conversationId);
}
