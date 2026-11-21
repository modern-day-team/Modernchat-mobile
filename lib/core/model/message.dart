import 'json_helpers.dart';

class MessageReaction {
  const MessageReaction({
    required this.userId,
    required this.emoji,
  });

  final int userId;
  final String emoji;

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: asInt(json['userId']),
      emoji: asString(json['emoji']),
    );
  }
}

class MessageReplyTo {
  const MessageReplyTo({
    required this.id,
    required this.senderId,
    required this.content,
  });

  final int id;
  final int senderId;
  final String content;

  factory MessageReplyTo.fromJson(Map<String, dynamic> json) {
    return MessageReplyTo(
      id: asInt(json['id']),
      senderId: asInt(json['senderId']),
      content: asString(json['content']),
    );
  }
}

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.clientMsgId,
    required this.msgType,
    required this.content,
    required this.createdAt,
    this.isRecalled = false,
    this.recalledAt,
    this.editedAt,
    this.replyToId,
    this.replyTo,
    this.mentions = const [],
    this.reactions = const [],
    this.adminDeletedAt,
  });

  final int id;
  final int conversationId;
  final int senderId;
  final String clientMsgId;
  final String msgType;
  final String content;
  final String createdAt;
  final bool isRecalled;
  final String? recalledAt;
  final String? editedAt;
  final int? replyToId;
  final MessageReplyTo? replyTo;
  final List<int> mentions;
  final List<MessageReaction> reactions;
  final String? adminDeletedAt;

  bool get isText => msgType == 'text';
  bool get isImage => msgType == 'image';
  bool get isMedia => const {'image', 'audio', 'video', 'sticker'}.contains(msgType);

  factory Message.fromJson(Map<String, dynamic> json) {
    final reply = json['replyTo'];
    return Message(
      id: asInt(json['id']),
      conversationId: asInt(json['conversationId']),
      senderId: asInt(json['senderId']),
      clientMsgId: asString(json['clientMsgId']),
      msgType: asString(json['msgType'], 'text'),
      content: asString(json['content']),
      createdAt: asString(json['createdAt']),
      isRecalled: asBool(json['isRecalled']),
      recalledAt: json['recalledAt'] as String?,
      editedAt: json['editedAt'] as String?,
      replyToId: asIntOrNull(json['replyToId']),
      replyTo: reply is Map
          ? MessageReplyTo.fromJson(Map<String, dynamic>.from(reply))
          : null,
      mentions: asIntList(json['mentions']),
      reactions: asList(json['reactions'], MessageReaction.fromJson),
      adminDeletedAt: json['adminDeletedAt'] as String?,
    );
  }
}
