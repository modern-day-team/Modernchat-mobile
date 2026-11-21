import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chat/presentation/pages/chat_room_page.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../providers/contacts_providers.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联系人'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '好友'),
            Tab(text: '申请'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriend,
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _friendList(ref),
          _requestList(ref),
        ],
      ),
    );
  }

  Widget _friendList(WidgetRef ref) {
    final friends = ref.watch(friendListProvider);
    return friends.when(
      data: (list) => RefreshIndicator(
        onRefresh: () => ref.read(friendListProvider.notifier).refresh(),
        child: list.isEmpty
            ? const Center(child: Text('暂无好友'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final friend = list[index].friend;
                  return ListTile(
                    leading: CircleAvatar(child: Text(friend.displayName.substring(0, 1))),
                    title: Text(friend.displayName),
                    subtitle: Text('@${friend.username}'),
                    onTap: () => _showStartChat(context, friend.id),
                  );
                },
              ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败：$error')),
    );
  }

  Widget _requestList(WidgetRef ref) {
    final requests = ref.watch(friendRequestProvider);
    return requests.when(
      data: (list) => RefreshIndicator(
        onRefresh: () => ref.read(friendRequestProvider.notifier).refresh(),
        child: list.isEmpty
            ? const Center(child: Text('暂无好友申请'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final request = list[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(request.friend.displayName.substring(0, 1)),
                    ),
                    title: Text(request.friend.displayName),
                    subtitle: Text('@${request.friend.username}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => ref
                              .read(friendRequestProvider.notifier)
                              .handle(request.id, true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => ref
                              .read(friendRequestProvider.notifier)
                              .handle(request.id, false),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败：$error')),
    );
  }

  Future<void> _showAddFriend() async {
    final username = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('添加好友'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '对方用户名'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('发送申请'),
            ),
          ],
        );
      },
    );
    if (username == null || username.isEmpty || !mounted) return;
    try {
      await ref.read(contactsRepositoryProvider).applyFriend(username);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('申请已发送')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败：$e')),
        );
      }
    }
  }

  Future<void> _showStartChat(BuildContext context, int userId) async {
    try {
      final conversation = await ref
          .read(chatRepositoryProvider)
          .createSingle(userId);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(conversation: conversation),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发起会话失败：$e')),
        );
      }
    }
  }
}
