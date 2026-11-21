import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';

class MessageDateSeparator extends StatelessWidget {
  const MessageDateSeparator({super.key, required this.iso});

  final String iso;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _label(iso);
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceLg,
        vertical: AppTokens.spaceSm,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: AppTokens.spaceXs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppTokens.pillBorder,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  String _label(String value) {
    final time = DateTime.tryParse(value)?.toLocal();
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);
    final days = today.difference(date).inDays;
    if (days == 0) return '今天';
    if (days == 1) return '昨天';
    if (date.year == now.year) return '${date.month}月${date.day}日';
    return '${date.year}年${date.month}月${date.day}日';
  }
}
