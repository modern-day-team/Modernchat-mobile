import '../../../../core/model/models.dart';
import '../../../../core/network/api_client.dart';

class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Conversation>> listConversations() async {
    final body = await _apiClient.get('/conversations');
    return _conversations(body);
  }

  Future<List<Conversation>> searchConversations(String keyword) async {
    final body = await _apiClient.get(
      '/conversations/search',
      queryParameters: {'kw': keyword},
    );
    return _conversations(body);
  }

  Future<Conversation> createSingle(int toUserId) async {
    final body = await _apiClient.post(
      '/conversations/single',
      data: {'toUserId': toUserId},
    );
    return Conversation.fromJson(body);
  }

  Future<Conversation> createGroup(String name) async {
    final body = await _apiClient.post(
      '/conversations/group',
      data: {'name': name},
    );
    return Conversation.fromJson(body);
  }

  Future<void> renameGroup(int conversationId, String name) =>
      _apiClient.patch('/conversations/$conversationId', data: {'name': name});

  Future<void> updatePrefs(
    int conversationId, {
    bool? pinned,
    bool? muted,
    bool? archived,
  }) =>
      _apiClient.patch(
        '/conversations/$conversationId/prefs',
        data: {
          'pinned': ?pinned,
          'muted': ?muted,
          'archived': ?archived,
        },
      );

  Future<void> markRead(int conversationId, int upToId) =>
      _apiClient.post(
        '/conversations/$conversationId/read',
        data: {'upToId': upToId},
      );

  Future<Map<String, dynamic>> fetchMessages(
    int conversationId, {
    int? beforeId,
    int? afterId,
    int limit = 30,
  }) async {
    final body = await _apiClient.get(
      '/conversations/$conversationId/messages',
      queryParameters: {
        'beforeId': ?beforeId,
        'afterId': ?afterId,
        'limit': limit,
      },
    );
    if (body is! Map) return {};
    return Map<String, dynamic>.from(body);
  }

  Future<void> deleteMessage(int conversationId, int messageId) =>
      _apiClient.delete('/conversations/$conversationId/messages/$messageId');

  Future<List<ConversationMember>> listMembers(int conversationId) async {
    final body = await _apiClient.get('/conversations/$conversationId/members');
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => ConversationMember.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    final map = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
    final members = map['members'];
    if (members is List) {
      return members
          .whereType<Map>()
          .map((e) => ConversationMember.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  List<Conversation> _conversations(dynamic body) {
    if (body is! List) return const [];
    return body
        .whereType<Map>()
        .map((e) => Conversation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
