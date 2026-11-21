import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.color,
    this.size = 44,
    this.icon,
  });

  final String name;
  final Color? color;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = color ?? theme.colorScheme.primary;
    return Semantics(
      label: name,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: background, size: size * 0.46)
            : Text(
                name.trim().isEmpty ? '?' : name.trim().substring(0, 1),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                  color: background,
                ),
              ),
      ),
    );
  }
}
