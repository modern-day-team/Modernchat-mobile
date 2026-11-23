import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/chat/data/datasources/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/contacts/data/datasources/contacts_remote_datasource.dart';
import '../features/contacts/data/repositories/contacts_repository_impl.dart';
import '../features/contacts/domain/repositories/contacts_repository.dart';
import '../core/network/network.dart';
import '../core/storage/storage_providers.dart';

/// 依赖注入组合根：唯一知道 data 具体实现的地方。
/// presentation 只 import 本文件与 domain 抽象，不直接 new 任何 RepositoryImpl / RemoteDataSource。
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSource(apiClient),
    storage: await ref.watch(storageServiceProvider.future),
    apiClient: apiClient,
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ChatRemoteDataSource(ref.watch(apiClientProvider)));
});

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepositoryImpl(
    ContactsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});
