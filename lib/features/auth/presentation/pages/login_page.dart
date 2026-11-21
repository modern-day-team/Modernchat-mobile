import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _register = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = '请输入账号和密码');
      return;
    }
    if (_register && _nicknameController.text.trim().isEmpty) {
      setState(() => _error = '请填写昵称');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    final controller = ref.read(authControllerProvider.notifier);
    if (_register) {
      await controller.register(
        username: username,
        password: password,
        nickname: _nicknameController.text.trim(),
      );
    } else {
      await controller.login(username: username, password: password);
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final error = _error ?? auth.error?.toString();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTokens.spaceXl),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      padding: const EdgeInsets.all(AppTokens.spaceSm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppTokens.radiusXlBorder,
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: ClipRRect(
                        borderRadius: AppTokens.radiusLgBorder,
                        child: Image.asset(
                          'assets/branding/app_icon.png',
                          fit: BoxFit.contain,
                          cacheWidth: 208,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTokens.spaceLg),
                    Text(
                      'Modernchat',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: AppTokens.heading,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.02,
                      ),
                    ),
                    const SizedBox(height: AppTokens.spaceXs),
                    Text(
                      '克制、清晰、移动优先的沟通方式',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.spaceXl),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTokens.spaceXl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Text('登录'),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text('注册'),
                                ),
                              ],
                              selected: {_register},
                              onSelectionChanged: (value) {
                                setState(() {
                                  _register = value.first;
                                  _error = null;
                                });
                              },
                            ),
                            const SizedBox(height: AppTokens.spaceXl),
                            if (_register) ...[
                              TextField(
                                controller: _nicknameController,
                                autofillHints: const [AutofillHints.nickname],
                                decoration: const InputDecoration(
                                  labelText: '昵称',
                                  hintText: '给自己起个名字',
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: AppTokens.spaceLg),
                            ],
                            TextField(
                              controller: _usernameController,
                              autofillHints: const [AutofillHints.username],
                              decoration: const InputDecoration(
                                labelText: '账号',
                                hintText: '用户名',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppTokens.spaceLg),
                            TextField(
                              controller: _passwordController,
                              autofillHints: [
                                if (_register)
                                  AutofillHints.newPassword
                                else
                                  AutofillHints.password
                              ],
                              decoration: const InputDecoration(
                                labelText: '密码',
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
                            const SizedBox(height: AppTokens.spaceXl),
                            FilledButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child:
                                          CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(_register ? '创建账号' : '登录'),
                            ),
                            const SizedBox(height: AppTokens.spaceMd),
                            Text(
                              '继续即表示同意《用户协议》与《隐私政策》',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppTokens.caption,
                                color: primary.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
