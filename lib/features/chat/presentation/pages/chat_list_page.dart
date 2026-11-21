import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../providers/chat_providers.dart';
import 'chat_room_page.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索群聊',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(conversationListProvider.notifier).refresh();
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty) {
                  ref.read(conversationListProvider.notifier).refresh();
                } else {
                  ref.read(conversationListProvider.notifier).search(value);
                }
              },
            ),
          ),
          Expanded(
            child: conversations.when(
              data: (list) => RefreshIndicator(
                onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final conversation = list[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _colorOf(conversation),
                        child: Text(conversation.displayName.substring(0, 1)),
                      ),
                      title: Text(conversation.displayName),
                      subtitle: Text(
                        conversation.lastMessagePreview ?? '暂无消息',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: conversation.unreadCount > 0
                          ? Badge(
                              label: Text('${conversation.unreadCount}'),
                              child: const Icon(Icons.chat_bubble_outline),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatRoomPage(conversation: conversation),
                        ),
                      ),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('加载失败：$error'),
                    FilledButton(
                      onPressed: () =>
                          ref.read(conversationListProvider.notifier).refresh(),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorOf(Conversation conversation) {
    if (conversation.peer != null) {
      final value = int.tryParse(
        conversation.peer!.avatarColor.replaceFirst('#', ''),
        radix: 16,
      );
      if (value != null) return Color(value);
    }
    return Colors.indigo;
  }
}
