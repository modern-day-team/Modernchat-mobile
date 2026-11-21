import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../../../../core/network/network.dart';
import '../../data/datasources/contacts_remote_datasource.dart';
import '../../data/repositories/contacts_repository_impl.dart';
import '../../domain/repositories/contacts_repository.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepositoryImpl(
    ContactsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final friendListProvider =
    AsyncNotifierProvider<FriendListController, List<FriendItem>>(
  FriendListController.new,
);

class FriendListController extends AsyncNotifier<List<FriendItem>> {
  @override
  Future<List<FriendItem>> build() =>
      ref.read(contactsRepositoryProvider).listFriends();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(contactsRepositoryProvider).listFriends(),
    );
  }
}

final friendRequestProvider =
    AsyncNotifierProvider<FriendRequestController, List<FriendRequestItem>>(
  FriendRequestController.new,
);

class FriendRequestController extends AsyncNotifier<List<FriendRequestItem>> {
  @override
  Future<List<FriendRequestItem>> build() =>
      ref.read(contactsRepositoryProvider).listRequests();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(contactsRepositoryProvider).listRequests(),
    );
  }

  Future<void> handle(int requestId, bool accept) async {
    await ref.read(contactsRepositoryProvider).handleRequest(requestId, accept);
    await refresh();
  }
}
