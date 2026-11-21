import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _username = TextEditingController();
  final _nickname = TextEditingController();
  final _password = TextEditingController();
  final _inviteCode = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _nickname.dispose();
    _password.dispose();
    _inviteCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty ||
        _password.text.isEmpty ||
        _nickname.text.trim().isEmpty) {
      setState(() => _error = '请填写用户名、昵称和密码');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    await ref.read(authControllerProvider.notifier).register(
          username: _username.text.trim(),
          password: _password.text,
          nickname: _nickname.text.trim(),
          inviteCode: _inviteCode.text.trim(),
        );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final error = _error ?? auth.error?.toString();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.spaceXl),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('创建账号', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppTokens.spaceXl),
              TextField(
                controller: _username,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(labelText: '用户名'),
              ),
              const SizedBox(height: AppTokens.spaceLg),
              TextField(
                controller: _nickname,
                autofillHints: const [AutofillHints.nickname],
                decoration: const InputDecoration(labelText: '昵称'),
              ),
              const SizedBox(height: AppTokens.spaceLg),
              TextField(
                controller: _password,
                autofillHints: const [AutofillHints.newPassword],
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
              ),
              const SizedBox(height: AppTokens.spaceLg),
              TextField(
                controller: _inviteCode,
                decoration: const InputDecoration(labelText: '邀请码（如需）'),
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
                    : const Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
