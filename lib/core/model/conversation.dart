import 'json_helpers.dart';
import 'user.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.type,
    required this.name,
    required this.ownerId,
    required this.memberCount,
    required this.unreadCount,
    required this.pinned,
    required this.muted,
    required this.archived,
    required this.muteAll,
    required this.mentionUnread,
    this.avatar,
    this.peer,
    this.lastMessageId,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.lastMessageType,
    this.lastReadMessageId,
    this.announcement,
    this.announcementAt,
    this.announcementBy,
  });

  final int id;
  final int type;
  final String name;
  final String? avatar;
  final UserSummary? peer;
  final int ownerId;
  final int memberCount;
  final int? lastMessageId;
  final String? lastMessageAt;
  final String? lastMessagePreview;
  final String? lastMessageType;
  final int? lastReadMessageId;
  final int unreadCount;
  final bool pinned;
  final bool muted;
  final bool archived;
  final bool muteAll;
  final int mentionUnread;
  final String? announcement;
  final String? announcementAt;
  final int? announcementBy;

  bool get isGroup => type == 2;
  bool get isSingle => type == 1;
  bool get isSystem => type == 3;

  String get displayName => name.isNotEmpty ? name : (peer?.displayName ?? '会话');

  Conversation copyWith({
    String? name,
    String? avatar,
    UserSummary? peer,
    int? ownerId,
    int? memberCount,
    int? lastMessageId,
    String? lastMessageAt,
    String? lastMessagePreview,
    String? lastMessageType,
    int? lastReadMessageId,
    int? unreadCount,
    bool? pinned,
    bool? muted,
    bool? archived,
    bool? muteAll,
    int? mentionUnread,
    String? announcement,
    String? announcementAt,
    int? announcementBy,
  }) {
    return Conversation(
      id: id,
      type: type,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      peer: peer ?? this.peer,
      ownerId: ownerId ?? this.ownerId,
      memberCount: memberCount ?? this.memberCount,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      unreadCount: unreadCount ?? this.unreadCount,
      pinned: pinned ?? this.pinned,
      muted: muted ?? this.muted,
      archived: archived ?? this.archived,
      muteAll: muteAll ?? this.muteAll,
      mentionUnread: mentionUnread ?? this.mentionUnread,
      announcement: announcement ?? this.announcement,
      announcementAt: announcementAt ?? this.announcementAt,
      announcementBy: announcementBy ?? this.announcementBy,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final peer = json['peer'];
    return Conversation(
      id: asInt(json['id']),
      type: asInt(json['type'], 1),
      name: asString(json['name']),
      avatar: json['avatar'] as String?,
      peer: peer is Map ? UserSummary.fromJson(Map<String, dynamic>.from(peer)) : null,
      ownerId: asInt(json['ownerId']),
      memberCount: asInt(json['memberCount'], 1),
      lastMessageId: asIntOrNull(json['lastMessageId']),
      lastMessageAt: json['lastMessageAt'] as String?,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageType: json['lastMessageType'] as String?,
      lastReadMessageId: asIntOrNull(json['lastReadMessageId']),
      unreadCount: asInt(json['unreadCount']),
      pinned: asBool(json['pinned']),
      muted: asBool(json['muted']),
      archived: asBool(json['archived']),
      muteAll: asBool(json['muteAll']),
      mentionUnread: asInt(json['mentionUnread']),
      announcement: json['announcement'] as String?,
      announcementAt: json['announcementAt'] as String?,
      announcementBy: asIntOrNull(json['announcementBy']),
    );
  }
}

class ConversationMember {
  const ConversationMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.user,
    this.mutedUntil,
  });

  final int userId;
  final String role;
  final String? mutedUntil;
  final String joinedAt;
  final UserSummary user;

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';

  factory ConversationMember.fromJson(Map<String, dynamic> json) {
    return ConversationMember(
      userId: asInt(json['userId']),
      role: asString(json['role'], 'member'),
      mutedUntil: json['mutedUntil'] as String?,
      joinedAt: asString(json['joinedAt']),
      user: json['user'] is Map
          ? UserSummary.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : UserSummary(id: asInt(json['userId']), username: '', nickname: '', avatarColor: '#0052d9'),
    );
  }
}
