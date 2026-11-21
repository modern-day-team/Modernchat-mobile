import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value?.user;
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppTokens.spaceXxl),
        children: [
          AppLargeHeader(title: '设置'),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.spaceLg,
              AppTokens.spaceXs,
              AppTokens.spaceLg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _profileCard(theme, user),
                const SizedBox(height: AppTokens.spaceLg),
                _sectionTitle(theme, '外观'),
                _themeCard(theme, themeMode, ref),
                const SizedBox(height: AppTokens.spaceLg),
                _sectionTitle(theme, '账号'),
                Card(
                  child: Column(
                    children: [
                      _row(
                        icon: Icons.shield_outlined,
                        label: '账号与安全',
                        onTap: () =>
                            _showComingSoon(context, '账号与安全设置即将上线'),
                      ),
                      _row(
                        icon: Icons.notifications_none_outlined,
                        label: '通知与免打扰',
                        value: '已开启',
                        onTap: () => _showComingSoon(context, '通知偏好即将上线'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.spaceLg),
                _sectionTitle(theme, '关于'),
                Card(
                  child: _row(
                    icon: Icons.info_outline,
                    label: '关于 Modernchat',
                    value: '1.0.0',
                    onTap: () => _showAbout(context),
                  ),
                ),
                const SizedBox(height: AppTokens.spaceXl),
                FilledButton(
                  onPressed: () => _confirmLogout(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('退出登录'),
                ),
                const SizedBox(height: AppTokens.spaceLg),
                Text(
                  'Modernchat 1.0.0\n克制、清晰、移动优先',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(ThemeData theme, User? user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTokens.radiusXlBorder,
        border: Border.all(color: theme.colorScheme.outline),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.surface,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceLg),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppTokens.radiusLgBorder,
              child: Image.asset(
                'assets/branding/app_icon.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                cacheWidth: 112,
                filterQuality: FilterQuality.medium,
              ),
            ),
            const SizedBox(width: AppTokens.spaceLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? '未登录',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: AppTokens.title,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceXs),
                  Text(
                    '${user?.email ?? ''} · ID ${user?.id ?? '-'}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeCard(
    ThemeData theme,
    ThemeMode selected,
    WidgetRef ref,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('主题', style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppTokens.spaceMd),
            Row(
              children: [
                _themeOption(
                  theme,
                  ThemeMode.system,
                  Icons.monitor_outlined,
                  '跟随系统',
                  selected,
                  ref,
                ),
                const SizedBox(width: AppTokens.spaceSm),
                _themeOption(
                  theme,
                  ThemeMode.light,
                  Icons.light_mode_outlined,
                  '浅色',
                  selected,
                  ref,
                ),
                const SizedBox(width: AppTokens.spaceSm),
                _themeOption(
                  theme,
                  ThemeMode.dark,
                  Icons.dark_mode_outlined,
                  '深色',
                  selected,
                  ref,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    ThemeData theme,
    ThemeMode mode,
    IconData icon,
    String label,
    ThemeMode selected,
    WidgetRef ref,
  ) {
    final active = selected == mode;
    return Expanded(
      child: InkWell(
        borderRadius: AppTokens.radiusMdBorder,
        onTap: () => ref.read(themeModeProvider.notifier).set(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppTokens.spaceMd,
            horizontal: AppTokens.spaceXs,
          ),
          decoration: BoxDecoration(
            borderRadius: AppTokens.radiusMdBorder,
            border: Border.all(
              color: active ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            color: active
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppTokens.spaceXs),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _sectionTitle(ThemeData theme, String text) => Padding(
        padding: const EdgeInsets.only(
          left: AppTokens.spaceLg,
          bottom: AppTokens.spaceSm,
        ),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );

  Future<void> _showComingSoon(BuildContext context, String message) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceLg),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  Future<void> _showAbout(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/branding/app_icon.png',
                  width: 56,
                  height: 56,
                  cacheWidth: 112,
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Text('Modernchat', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppTokens.spaceXs),
                Text(
                  '版本 1.0.0 · 移动优先',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('退出当前账号', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTokens.spaceMd),
              Text(
                '确定要退出登录吗？',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTokens.spaceLg),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('退出登录'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}
