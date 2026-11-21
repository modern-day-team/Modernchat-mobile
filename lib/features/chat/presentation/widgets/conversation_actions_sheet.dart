import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';

enum ConversationAction { pin, mute, rename, close }

class ConversationActionsSheet extends StatelessWidget {
  const ConversationActionsSheet({
    super.key,
    required this.title,
    required this.isGroup,
    required this.pinned,
    required this.muted,
  });

  final String title;
  final bool isGroup;
  final bool pinned;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.spaceLg,
          AppTokens.spaceMd,
          AppTokens.spaceLg,
          AppTokens.spaceLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: AppTokens.pillBorder,
                ),
              ),
            ),
            const SizedBox(height: AppTokens.spaceLg),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spaceLg),
            _ActionTile(
              icon: pinned ? Icons.push_pin : Icons.push_pin_outlined,
              label: pinned ? '取消置顶' : '置顶会话',
              onTap: () => Navigator.pop(context, ConversationAction.pin),
            ),
            _ActionTile(
              icon: muted ? Icons.notifications_none : Icons.notifications_off_outlined,
              label: muted ? '取消免打扰' : '免打扰',
              onTap: () => Navigator.pop(context, ConversationAction.mute),
            ),
            if (isGroup)
              _ActionTile(
                icon: Icons.edit_outlined,
                label: '修改群名',
                onTap: () => Navigator.pop(context, ConversationAction.rename),
              ),
            const SizedBox(height: AppTokens.spaceSm),
            TextButton(
              onPressed: () => Navigator.pop(context, ConversationAction.close),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      minLeadingWidth: 32,
      onTap: onTap,
    );
  }
}
