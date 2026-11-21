import 'package:material_ui/material_ui.dart';

import '../../../../core/model/models.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onLongPress,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = conversation.lastMessagePreview ?? '暂无消息';
    final time = _timeLabel(conversation.lastMessageAt);

    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceLg,
            vertical: AppTokens.spaceMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppAvatar(
                name: conversation.displayName,
                color: _colorOf(context),
                icon: conversation.isGroup ? Icons.group_outlined : null,
              ),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (conversation.pinned)
                          const Icon(
                            Icons.push_pin,
                            size: 12,
                            color: AppTokens.brand,
                          ),
                        Flexible(
                          child: Text(
                            conversation.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.spaceXs),
                    Row(
                      children: [
                        if (conversation.muted)
                          const Padding(
                            padding: EdgeInsets.only(right: AppTokens.spaceXs),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 12,
                              color: AppTokens.inkFaint,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            conversation.isGroup &&
                                    preview.isNotEmpty &&
                                    !preview.startsWith('@')
                                ? preview
                                : preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.spaceSm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(time, style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppTokens.spaceSm),
                  if (conversation.unreadCount > 0)
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppTokens.danger,
                        borderRadius: AppTokens.pillBorder,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        conversation.unreadCount > 99
                            ? '99+'
                            : '${conversation.unreadCount}',
                        style: const TextStyle(
                          fontSize: AppTokens.caption,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorOf(BuildContext context) {
    final value = int.tryParse(
      conversation.peer?.avatarColor.replaceFirst('#', '') ?? '',
      radix: 16,
    );
    if (value == null) {
      return Theme.of(context).colorScheme.primary;
    }
    return Color(value);
  }

  String _timeLabel(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return '';
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}/${date.day}';
  }
}
