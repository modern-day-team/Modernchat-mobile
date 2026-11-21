import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = '请输入用户名和密码');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    await ref.read(authControllerProvider.notifier).login(
          username: username,
          password: password,
        );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final error = _error ?? auth.error?.toString();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.spaceXxl),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.spaceXxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: AppTokens.radiusLgBorder,
                        ),
                        child: ClipRRect(
                          borderRadius: AppTokens.radiusMdBorder,
                          child: Image.asset(
                            'assets/branding/app_icon.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            cacheWidth: 128,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceLg),
                      Text(
                        '登录 ModernChat',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppTokens.spaceXs),
                      Text(
                        '连接团队，随时沟通',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceXxl),
                      TextField(
                        controller: _usernameController,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: '用户名',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppTokens.spaceLg),
                      TextField(
                        controller: _passwordController,
                        autofillHints: const [AutofillHints.password],
                        decoration: const InputDecoration(
                          labelText: '密码',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                        ),
                        obscureText: true,
                        onSubmitted: (_) => _submit(),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: AppTokens.spaceMd),
                        Text(
                          error,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTokens.spaceXxl),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('登录'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        ),
                        child: const Text('没有账号？注册'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
