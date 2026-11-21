import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/message_time_formatter.dart';

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

  String _label(String value) => MessageTimeFormatter.date(value);
}
