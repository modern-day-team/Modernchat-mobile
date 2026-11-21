import '../../../../core/model/models.dart';
import '../../../../core/network/api_client.dart';

class ContactsRemoteDataSource {
  const ContactsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<FriendItem>> listFriends() async {
    final body = await _apiClient.get('/friends');
    return _list(body, FriendItem.fromJson);
  }

  Future<List<FriendRequestItem>> listRequests() async {
    final body = await _apiClient.get('/friends/requests');
    return _list(body, FriendRequestItem.fromJson);
  }

  Future<List<UserSummary>> searchUsers(String keyword) async {
    final body = await _apiClient.get(
      '/users/search',
      queryParameters: {'kw': keyword},
    );
    return _list(body, UserSummary.fromJson);
  }

  Future<void> applyFriend(String username) =>
      _apiClient.post('/friends/apply', data: {'toUsername': username});

  Future<void> handleRequest(int requestId, bool accept) => _apiClient.post(
        '/friends/handle',
        data: {'requestId': requestId, 'accept': accept},
      );

  Future<void> removeFriend(int friendId) =>
      _apiClient.delete('/friends/$friendId');

  List<T> _list<T>(dynamic body, T Function(Map<String, dynamic>) mapper) {
    if (body is! List) return const [];
    return body
        .whereType<Map>()
        .map((e) => mapper(Map<String, dynamic>.from(e)))
        .toList();
  }
}
