import 'user.dart';

class Chat {
  final String id;
  final bool isGroup;
  final String? name;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMember>? members;
  final List<Message>? messages;

  Chat({
    required this.id,
    this.isGroup = false,
    this.name,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.members,
    this.messages,
  });

  String get displayName {
    if (isGroup && name != null) return name!;
    if (members != null && members!.isNotEmpty) {
      final other = members!.firstWhere(
        (m) => m.user != null,
        orElse: () => ChatMember(userId: '', chatId: ''),
      );
      return other.user?.fullName ?? 'Чат';
    }
    return 'Чат';
  }

  String? get displayAvatar {
    if (avatar != null) return avatar;
    if (members != null && members!.isNotEmpty) {
      final other = members!.firstWhere(
        (m) => m.user != null,
        orElse: () => ChatMember(userId: '', chatId: ''),
      );
      return other.user?.avatar;
    }
    return null;
  }

  Message? get lastMessage {
    if (messages != null && messages!.isNotEmpty) {
      return messages!.first;
    }
    return null;
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      isGroup: json['isGroup'] ?? false,
      name: json['name'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['createdAt']),
      members: json['members'] != null
          ? (json['members'] as List).map((e) => ChatMember.fromJson(e)).toList()
          : null,
      messages: json['messages'] != null
          ? (json['messages'] as List).map((e) => Message.fromJson(e)).toList()
          : null,
    );
  }
}

class ChatMember {
  final String userId;
  final String chatId;
  final bool isAdmin;
  final DateTime joinedAt;
  final User? user;

  ChatMember({
    required this.userId,
    required this.chatId,
    this.isAdmin = false,
    DateTime? joinedAt,
    this.user,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userId: json['userId'],
      chatId: json['chatId'],
      isAdmin: json['isAdmin'] ?? false,
      joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String type;
  final String? content;
  final String? fileUrl;
  final String? replyToId;
  final DateTime createdAt;
  final User? sender;
  final Message? replyTo;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.type = 'text',
    this.content,
    this.fileUrl,
    this.replyToId,
    required this.createdAt,
    this.sender,
    this.replyTo,
  });

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';
  bool get isDocument => type == 'document';
  bool get isLocation => type == 'location';

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'],
      type: json['type'] ?? 'text',
      content: json['content'],
      fileUrl: json['fileUrl'],
      replyToId: json['replyToId'],
      createdAt: DateTime.parse(json['createdAt']),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      replyTo: json['replyTo'] != null ? Message.fromJson(json['replyTo']) : null,
    );
  }
}

enum MessageStatus { sent, delivered, read }
