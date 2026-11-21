import 'json_helpers.dart';

class UserSummary {
  static final Map<String, int?> _avatarColorCache = <String, int?>{};

  const UserSummary({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatarColor,
    this.avatar,
  });

  final int id;
  final String username;
  final String nickname;
  final String avatarColor;
  final String? avatar;

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: asInt(json['id']),
      username: asString(json['username']),
      nickname: asString(json['nickname']),
      avatarColor: asString(json['avatarColor'], '#0052d9'),
      avatar: json['avatar'] as String?,
    );
  }

  String get displayName => nickname.isNotEmpty ? nickname : username;

  int? get avatarColorValue {
    if (_avatarColorCache.containsKey(avatarColor)) {
      return _avatarColorCache[avatarColor];
    }
    if (_avatarColorCache.length >= 256) _avatarColorCache.clear();
    final value = int.tryParse(
      avatarColor.startsWith('#') ? avatarColor.substring(1) : avatarColor,
      radix: 16,
    );
    _avatarColorCache[avatarColor] = value;
    return value;
  }
}

class User extends UserSummary {
  User({
    required super.id,
    required super.username,
    required super.nickname,
    required super.avatarColor,
    super.avatar,
    this.email,
    this.emailVerified = false,
    this.role = 'user',
    this.bannedUntil,
    this.banReason,
  });

  final String? email;
  final bool emailVerified;
  final String role;
  final String? bannedUntil;
  final String? banReason;

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: asInt(json['id']),
      username: asString(json['username']),
      nickname: asString(json['nickname']),
      avatarColor: asString(json['avatarColor'], '#0052d9'),
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      emailVerified: asBool(json['emailVerified']),
      role: asString(json['role'], 'user'),
      bannedUntil: json['bannedUntil'] as String?,
      banReason: json['banReason'] as String?,
    );
  }

  UserSummary toSummary() => UserSummary(
        id: id,
        username: username,
        nickname: nickname,
        avatarColor: avatarColor,
        avatar: avatar,
      );
}
