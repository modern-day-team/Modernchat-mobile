import '../../../../core/model/models.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contacts_remote_datasource.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  const ContactsRepositoryImpl(this._remote);

  final ContactsRemoteDataSource _remote;

  @override
  Future<List<FriendItem>> listFriends() => _remote.listFriends();

  @override
  Future<List<FriendRequestItem>> listRequests() => _remote.listRequests();

  @override
  Future<List<UserSummary>> searchUsers(String keyword) =>
      _remote.searchUsers(keyword);

  @override
  Future<void> applyFriend(String username) => _remote.applyFriend(username);

  @override
  Future<void> handleRequest(int requestId, bool accept) =>
      _remote.handleRequest(requestId, accept);

  @override
  Future<void> removeFriend(int friendId) => _remote.removeFriend(friendId);
}
