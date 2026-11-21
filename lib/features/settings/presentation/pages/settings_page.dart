import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/model/models.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value?.user;
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppTokens.spaceXxl),
        children: [
          _profileCard(theme, user),
          const SizedBox(height: AppTokens.spaceLg),
          _sectionTitle(theme, '外观'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spaceMd),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('跟随系统'),
                  ),
                  ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
                ],
                selected: {themeMode},
                onSelectionChanged: (value) {
                  if (value.isNotEmpty) {
                    ref.read(themeModeProvider.notifier).set(value.first);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          _sectionTitle(theme, '账号'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person_outline, size: 20),
                  title: Text('个人资料'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, size: 20),
                  title: const Text('退出登录'),
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          AboutListTile(applicationName: 'ModernChat'),
        ],
      ),
    );
  }

  Widget _profileCard(ThemeData theme, User? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceLg),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppTokens.radiusMdBorder,
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
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTokens.spaceXs),
                  Text(
                    user?.email ?? '@${user?.username ?? ''}',
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
              Text('退出登录', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTokens.spaceMd),
              Text(
                '确定要退出当前账号吗？',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTokens.spaceLg),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('退出'),
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
