import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
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
  String _keyword = '';

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
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _friendList(),
                _requestList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spaceLg,
        AppTokens.spaceSm,
        AppTokens.spaceLg,
        AppTokens.spaceSm,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索好友',
          prefixIcon: const Icon(Icons.search, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
          ),
          suffixIcon: _keyword.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _keyword = '');
                  },
                ),
        ),
        onChanged: (value) => setState(() => _keyword = value.trim()),
      ),
    );
  }

  Widget _friendList() {
    final friends = ref.watch(friendListProvider);
    return friends.when(
      data: (list) {
        final filtered = _keyword.isEmpty
            ? list
            : list
                .where((item) =>
                    item.friend.displayName.contains(_keyword) ||
                    item.friend.username.contains(_keyword))
                .toList();
        if (filtered.isEmpty) {
          return _empty('暂无好友', '点击右下角 + 添加好友');
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(friendListProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final friend = filtered[index].friend;
              return RepaintBoundary(
                child: ListTile(
                  leading: AppAvatar(name: friend.displayName),
                  title: Text(friend.displayName),
                  subtitle: Text('@${friend.username}'),
                  trailing: const Icon(Icons.chat_bubble_outline, size: 20),
                  onTap: () => _showStartChat(context, friend.id),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _error(error),
    );
  }

  Widget _requestList() {
    final requests = ref.watch(friendRequestProvider);
    return requests.when(
      data: (list) {
        if (list.isEmpty) return _empty('暂无好友申请', '有新的申请会显示在这里');
        return RefreshIndicator(
          onRefresh: () => ref.read(friendRequestProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final request = list[index];
              return RepaintBoundary(
                child: ListTile(
                  leading: AppAvatar(name: request.friend.displayName),
                  title: Text(request.friend.displayName),
                  subtitle: Text('@${request.friend.username}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          tooltip: '接受',
                          icon: const Icon(Icons.check, color: AppTokens.success),
                          onPressed: () => ref
                              .read(friendRequestProvider.notifier)
                              .handle(request.id, true),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          tooltip: '拒绝',
                          icon: const Icon(Icons.close, color: AppTokens.danger),
                          onPressed: () => ref
                              .read(friendRequestProvider.notifier)
                              .handle(request.id, false),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _error(error),
    );
  }

  Widget _empty(String title, String subtitle) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 96),
          const Icon(Icons.people_outline, size: 48, color: AppTokens.inkFaint),
          const SizedBox(height: AppTokens.spaceLg),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: AppTokens.emphasis)),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTokens.sm,
              color: AppTokens.inkFaint,
            ),
          ),
        ],
      );

  Widget _error(Object error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceXxl),
          child: Text('加载失败：$error'),
        ),
      );

  Future<void> _showAddFriend() async {
    final username = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final controller = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '添加好友',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTokens.spaceLg),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: '对方用户名',
                      hintText: '例如：alice',
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceLg),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, controller.text.trim()),
                    child: const Text('发送申请'),
                  ),
                ],
              ),
            ),
          ),
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
