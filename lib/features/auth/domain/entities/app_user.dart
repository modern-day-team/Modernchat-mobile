import '../../../../core/model/models.dart';

class AuthState {
  const AuthState._({
    required this.isAuthenticated,
    this.user,
    this.token,
    this.isRestoring = false,
  });

  final bool isAuthenticated;
  final User? user;
  final String? token;
  final bool isRestoring;

  static const guest = AuthState._(isAuthenticated: false);
  static const restoring = AuthState._(
    isAuthenticated: false,
    isRestoring: true,
  );

  static AuthState authenticated(User user, String token) => AuthState._(
        isAuthenticated: true,
        user: user,
        token: token,
      );

  int? get userId => user?.id;
}

class AuthResult {
  const AuthResult({
    required this.token,
    required this.user,
  });

  final String token;
  final User user;
}
