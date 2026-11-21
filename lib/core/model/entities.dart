import 'json_helpers.dart';
import 'user.dart';

class FriendItem {
  const FriendItem({
    required this.id,
    required this.friend,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final UserSummary friend;
  final int status;
  final String createdAt;

  bool get accepted => status == 1;

  factory FriendItem.fromJson(Map<String, dynamic> json) {
    final friend = json['friend'];
    return FriendItem(
      id: asInt(json['id']),
      friend: friend is Map
          ? UserSummary.fromJson(Map<String, dynamic>.from(friend))
          : UserSummary(id: 0, username: '', nickname: '', avatarColor: '#0052d9'),
      status: asInt(json['status']),
      createdAt: asString(json['createdAt']),
    );
  }
}

class FriendRequestItem extends FriendItem {
  FriendRequestItem({
    required super.id,
    required super.friend,
    required super.status,
    required super.createdAt,
  });

  factory FriendRequestItem.fromJson(Map<String, dynamic> json) {
    final from = json['from'] ?? json['user'] ?? json['friend'];
    return FriendRequestItem(
      id: asInt(json['id'] ?? json['requestId']),
      friend: from is Map
          ? UserSummary.fromJson(Map<String, dynamic>.from(from))
          : UserSummary(id: 0, username: '', nickname: '', avatarColor: '#0052d9'),
      status: asInt(json['status']),
      createdAt: asString(json['createdAt']),
    );
  }
}

class SiteConfig {
  const SiteConfig({
    required this.name,
    required this.allowRegister,
    required this.maintenanceMode,
    required this.requireInviteCode,
    required this.requireEmailVerify,
    this.maintenanceMessage,
    this.maxMessageLength = 2000,
    this.recallMinutes = 2,
    this.maxGroupMembers = 200,
  });

  final String name;
  final bool allowRegister;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final bool requireInviteCode;
  final bool requireEmailVerify;
  final int maxMessageLength;
  final int recallMinutes;
  final int maxGroupMembers;

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    return SiteConfig(
      name: asString(json['name'], 'ModernChat'),
      allowRegister: asBool(json['allowRegister']),
      maintenanceMode: asBool(json['maintenanceMode']),
      maintenanceMessage: json['maintenanceMessage'] as String?,
      requireInviteCode: asBool(json['requireInviteCode']),
      requireEmailVerify: asBool(json['requireEmailVerify']),
      maxMessageLength: asInt(json['maxMessageLength'], 2000),
      recallMinutes: asInt(json['recallMinutes'], 2),
      maxGroupMembers: asInt(json['maxGroupMembers'], 200),
    );
  }
}

class SearchHit {
  const SearchHit({
    required this.messageId,
    required this.conversationId,
    required this.convType,
    required this.convName,
    required this.senderId,
    required this.senderNickname,
    required this.msgType,
    required this.content,
    required this.createdAt,
  });

  final int messageId;
  final int conversationId;
  final int convType;
  final String convName;
  final int senderId;
  final String senderNickname;
  final String msgType;
  final String content;
  final String createdAt;

  factory SearchHit.fromJson(Map<String, dynamic> json) {
    return SearchHit(
      messageId: asInt(json['messageId']),
      conversationId: asInt(json['conversationId']),
      convType: asInt(json['convType']),
      convName: asString(json['convName']),
      senderId: asInt(json['senderId']),
      senderNickname: asString(json['senderNickname']),
      msgType: asString(json['msgType']),
      content: asString(json['content']),
      createdAt: asString(json['createdAt']),
    );
  }
}
