import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final isAuthenticated = auth.value?.isAuthenticated ?? false;

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) =>
            isAuthenticated ? const AppShell() : const LoginPage(),
      ),
    ],
    redirect: (context, state) {
      if (!isAuthenticated && state.matchedLocation != '/login') {
        return '/login';
      }
      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/';
      }
      return null;
    },
  );
});
