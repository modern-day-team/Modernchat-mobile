import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../../../../core/theme/app_tokens.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final canSend = _controller.text.trim().isNotEmpty;
      if (canSend != _canSend) setState(() => _canSend = canSend);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageListProvider(widget.conversation.id));
    final myId = ref.watch(authUserIdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversation.displayName),
            if (widget.conversation.isGroup)
              Text(
                '${widget.conversation.memberCount} 位成员',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: messages.when(
                data: (list) => ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final message = list[list.length - 1 - index];
                    return MessageBubble(
                      key: ValueKey(message.id),
                      message: message,
                      isMine: message.senderId == myId,
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('加载失败：$error')),
              ),
            ),
          ),
          _composer(theme),
        ],
      ),
    );
  }

  Widget _composer(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppTokens.spaceLg,
          AppTokens.spaceSm,
          AppTokens.spaceMd,
          AppTokens.spaceSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: '输入消息',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spaceMd,
                    vertical: AppTokens.spaceSm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppTokens.radiusLgBorder,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: AppTokens.spaceSm),
            SizedBox(
              width: 44,
              height: 44,
              child: FilledButton(
                onPressed: _canSend ? _send : null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTokens.pillBorder,
                  ),
                ),
                child: const Icon(Icons.arrow_upward, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    ref
        .read(messageListProvider(widget.conversation.id).notifier)
        .sendText(content);
    _controller.clear();
  }
}
