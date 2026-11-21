import '../../../../core/model/models.dart';

abstract interface class ContactsRepository {
  Future<List<FriendItem>> listFriends();
  Future<List<FriendRequestItem>> listRequests();
  Future<List<UserSummary>> searchUsers(String keyword);
  Future<void> applyFriend(String username);
  Future<void> handleRequest(int requestId, bool accept);
  Future<void> removeFriend(int friendId);
}
