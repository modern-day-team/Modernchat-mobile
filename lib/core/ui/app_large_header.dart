import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

class AppLargeHeader extends StatelessWidget {
  const AppLargeHeader({
    super.key,
    required this.title,
    this.actions = const [],
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.spaceLg,
          AppTokens.spaceLg,
          AppTokens.spaceSm,
          AppTokens.spaceSm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: AppTokens.display,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03,
                ),
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
