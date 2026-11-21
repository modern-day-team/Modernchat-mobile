import 'package:material_ui/material_ui.dart';

import '../../../../core/model/models.dart';
import '../../../../core/theme/app_tokens.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground =
        isMine ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final content = message.isRecalled
        ? '消息已撤回'
        : message.isText
            ? message.content
            : '[${message.msgType}] ${message.content}';

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceLg,
          vertical: AppTokens.spaceXs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.spaceMd,
                  vertical: AppTokens.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTokens.radiusLg),
                    topRight: Radius.circular(AppTokens.radiusLg),
                    bottomLeft: Radius.circular(
                      isMine ? AppTokens.radiusLg : AppTokens.radiusSm,
                    ),
                    bottomRight: Radius.circular(
                      isMine ? AppTokens.radiusSm : AppTokens.radiusLg,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.replyTo != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppTokens.spaceXs),
                        padding: const EdgeInsets.only(
                          left: AppTokens.spaceSm,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '${message.replyTo!.senderId}: ${message.replyTo!.content}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    Text(
                      content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontStyle:
                            message.isRecalled ? FontStyle.italic : null,
                      ),
                    ),
                    const SizedBox(height: AppTokens.spaceXs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.editedAt != null)
                          const Padding(
                            padding: EdgeInsets.only(right: AppTokens.spaceXs),
                            child: Text('已编辑', style: TextStyle(fontSize: AppTokens.caption)),
                          ),
                        Text(
                          _timeLabel(message.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(String iso) {
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
