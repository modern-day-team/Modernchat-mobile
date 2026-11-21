import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../providers/chat_providers.dart';
import 'chat_room_page.dart';
import '../widgets/conversation_actions_sheet.dart';
import '../widgets/conversation_tile.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_searchController.text.isNotEmpty &&
          !_scrollController.position.isScrollingNotifier.value) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          AppLargeHeader(
            title: '消息',
            actions: [
              IconButton(
                tooltip: '新建会话',
                icon: const Icon(Icons.add_comment_outlined),
                onPressed: _showNewConversationSheet,
              ),
            ],
          ),
          _searchBar(theme),
          Expanded(
            child: conversations.when(
              data: (list) => _conversationList(theme, list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppErrorState(
                error: error,
                onRetry: () =>
                    ref.read(conversationListProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversationList(ThemeData theme, List<Conversation> list) {
    if (list.isEmpty) {
      return AppEmptyState(
        icon: Icons.chat_bubble_outline,
        title: _searching ? '没有找到相关会话' : '还没有会话',
        subtitle: _searching ? '换个关键词试试，或发起一个新的会话' : '点击右上角 + 发起新会话',
      );
    }

    final pinned = list.where((item) => item.pinned).toList();
    final recent = list.where((item) => !item.pinned).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (pinned.isNotEmpty) ...[
            _sectionHeader(theme, '置顶'),
            SliverList.builder(
              itemCount: pinned.length,
              itemBuilder: (context, index) {
                final conversation = pinned[index];
                return ConversationTile(
                  key: ValueKey(conversation.id),
                  conversation: conversation,
                  onTap: () => _openRoom(conversation),
                  onLongPress: () => _showActions(conversation),
                );
              },
            ),
          ],
          if (recent.isNotEmpty) ...[
            _sectionHeader(theme, '最近'),
            SliverList.builder(
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final conversation = recent[index];
                return ConversationTile(
                  key: ValueKey(conversation.id),
                  conversation: conversation,
                  onTap: () => _openRoom(conversation),
                  onLongPress: () => _showActions(conversation),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String text) => SliverPersistentHeader(
        pinned: true,
        delegate: _SectionHeaderDelegate(text, theme),
      );

  Widget _searchBar(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spaceLg,
        AppTokens.spaceSm,
        AppTokens.spaceLg,
        AppTokens.spaceSm,
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '搜索会话或联系人',
          filled: true,
          fillColor: theme.colorScheme.surface,
          prefixIcon: const Icon(Icons.search, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searching = false);
                  FocusScope.of(context).unfocus();
                  ref.read(conversationListProvider.notifier).refresh();
                },
              );
            },
          ),
        ),
        onSubmitted: (value) {
          final keyword = value.trim();
          setState(() => _searching = keyword.isNotEmpty);
          if (keyword.isEmpty) {
            ref.read(conversationListProvider.notifier).refresh();
          } else {
            ref.read(conversationListProvider.notifier).search(keyword);
          }
        },
      ),
    );
  }

  void _openRoom(Conversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(conversation: conversation),
      ),
    );
  }

  Future<void> _showActions(Conversation conversation) async {
    final action = await showModalBottomSheet<ConversationAction>(
      context: context,
      builder: (_) => ConversationActionsSheet(
        title: conversation.displayName,
        isGroup: conversation.isGroup,
        pinned: conversation.pinned,
        muted: conversation.muted,
      ),
    );
    if (action == null || !mounted) return;
    final repository = ref.read(chatRepositoryProvider);
    try {
      switch (action) {
        case ConversationAction.pin:
          await repository.updatePrefs(
            conversation.id,
            pinned: !conversation.pinned,
          );
        case ConversationAction.mute:
          await repository.updatePrefs(
            conversation.id,
            muted: !conversation.muted,
          );
        case ConversationAction.rename:
          final name = await _promptGroupName(conversation.displayName);
          if (name == null || name.trim().isEmpty) return;
          await repository.renameGroup(conversation.id, name.trim());
        case ConversationAction.close:
          return;
      }
      await ref.read(conversationListProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败：$e')),
        );
      }
    }
  }

  Future<String?> _promptGroupName(String current) async {
    final controller = TextEditingController(text: current);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: '群名称'),
                ),
                const SizedBox(height: AppTokens.spaceLg),
                FilledButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNewConversationSheet() async {
    final name = await showModalBottomSheet<String>(
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
                  Text('创建群聊', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppTokens.spaceLg),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '群名称',
                      hintText: '例如：项目组',
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceLg),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: const Text('创建并进入'),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  const Text(
                    '添加好友请到「联系人」页，点击右下角 +',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTokens.sm,
                      color: AppTokens.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      final conversation = await ref
          .read(chatRepositoryProvider)
          .createGroup(name.trim());
      await ref.read(conversationListProvider.notifier).refresh();
      if (!mounted) return;
      _openRoom(conversation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败：$e')),
        );
      }
    }
  }
}

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SectionHeaderDelegate(this.text, this.theme);

  final String text;
  final ThemeData theme;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spaceLg,
        AppTokens.spaceSm,
        AppTokens.spaceLg,
        AppTokens.spaceXs,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return text != oldDelegate.text || theme != oldDelegate.theme;
  }
}
