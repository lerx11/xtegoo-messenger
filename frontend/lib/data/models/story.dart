import 'user.dart';

class Story {
  final String id;
  final String userId;
  final String mediaUrl;
  final String type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final User? user;

  Story({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.user,
  });

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['userId'],
      mediaUrl: json['mediaUrl'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class StoryGroup {
  final User user;
  final List<Story> stories;

  StoryGroup({required this.user, required this.stories});
}
