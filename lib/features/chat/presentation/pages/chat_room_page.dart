import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/message_time_formatter.dart';
import '../providers/chat_providers.dart';
import '../widgets/conversation_actions_sheet.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_date_separator.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late Conversation _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageListProvider(_conversation.id));
    final myId = ref.watch(authUserIdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          _header(theme),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: messages.when(
                data: (list) => list.isEmpty
                    ? AppEmptyState(
                        icon: Icons.chat_bubble_outline,
                        title: '还没有消息',
                        subtitle: '发送第一条消息开始聊天',
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final message = list[list.length - 1 - index];
                          final older = index + 1 < list.length
                              ? list[list.length - 2 - index]
                              : null;
                          final showDate = older == null ||
                              !_sameDay(older.createdAt, message.createdAt);
                          return Column(
                            key: ValueKey(message.id),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showDate)
                                MessageDateSeparator(iso: message.createdAt),
                              MessageBubble(
                                message: message,
                                isMine: message.senderId == myId,
                              ),
                            ],
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => AppErrorState(error: error),
              ),
            ),
          ),
          _composer(theme),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme) {
    final status = _conversation.muted
        ? '已开启免打扰'
        : _conversation.isGroup
            ? '${_conversation.memberCount} 位成员'
            : '在线';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceSm,
            vertical: AppTokens.spaceSm,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: '返回',
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              AppAvatar(
                name: _conversation.displayName,
                size: 32,
                color: _colorOf(theme),
                icon: _conversation.isGroup ? Icons.group_outlined : null,
              ),
              const SizedBox(width: AppTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _conversation.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '会话设置',
                icon: const Icon(Icons.more_horiz),
                onPressed: _showActions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorOf(ThemeData theme) {
    final value = _conversation.peer?.avatarColorValue;
    if (value == null) return theme.colorScheme.primary;
    return Color(value);
  }

  bool _sameDay(String a, String b) => MessageTimeFormatter.sameDay(a, b);

  Widget _composer(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppTokens.spaceLg,
          AppTokens.spaceSm,
          AppTokens.spaceMd,
          AppTokens.spaceSm,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.spaceMd,
            AppTokens.spaceXs,
            AppTokens.spaceXs,
            AppTokens.spaceXs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppTokens.radiusLgBorder,
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 2000,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: '输入消息…',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: AppTokens.spaceSm),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => SizedBox(
                  width: 44,
                  height: 44,
                  child: FilledButton(
                    onPressed: value.text.trim().isEmpty ? null : _send,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.radiusMdBorder,
                      ),
                    ),
                    child: const Icon(Icons.send, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _send() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    ref
        .read(messageListProvider(_conversation.id).notifier)
        .sendText(content);
    _controller.clear();
  }

  Future<void> _showActions() async {
    final action = await showModalBottomSheet<ConversationAction>(
      context: context,
      builder: (_) => ConversationActionsSheet(
        title: _conversation.displayName,
        isGroup: _conversation.isGroup,
        pinned: _conversation.pinned,
        muted: _conversation.muted,
      ),
    );
    if (action == null || !mounted) return;
    final repository = ref.read(chatRepositoryProvider);
    try {
      switch (action) {
        case ConversationAction.pin:
          final pinned = !_conversation.pinned;
          await repository.updatePrefs(_conversation.id, pinned: pinned);
          setState(() => _conversation = _conversation.copyWith(pinned: pinned));
        case ConversationAction.mute:
          final muted = !_conversation.muted;
          await repository.updatePrefs(_conversation.id, muted: muted);
          setState(() => _conversation = _conversation.copyWith(muted: muted));
        case ConversationAction.rename:
          final name = await _promptGroupName(_conversation.displayName);
          if (name == null || name.trim().isEmpty) return;
          await repository.renameGroup(_conversation.id, name.trim());
          setState(
            () => _conversation = _conversation.copyWith(name: name.trim()),
          );
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
}
