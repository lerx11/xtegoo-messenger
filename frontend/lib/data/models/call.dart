import 'user.dart';

class Call {
  final String id;
  final String callerId;
  final String receiverId;
  final String type;
  final String status;
  final int duration;
  final String? roomName;
  final DateTime createdAt;
  final User? caller;
  final User? receiver;

  Call({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    this.duration = 0,
    this.roomName,
    required this.createdAt,
    this.caller,
    this.receiver,
  });

  bool get isAudio => type == 'audio';
  bool get isVideo => type == 'video';

  bool get isIncoming => status == 'incoming';
  bool get isAnswered => status == 'answered';
  bool get isEnded => status == 'ended';
  bool get isMissed => status == 'missed';

  User? otherUser(String currentUserId) {
    return callerId == currentUserId ? receiver : caller;
  }

  bool wasIncoming(String currentUserId) {
    return receiverId == currentUserId;
  }

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'],
      callerId: json['callerId'],
      receiverId: json['receiverId'],
      type: json['type'],
      status: json['status'],
      duration: json['duration'] ?? 0,
      roomName: json['roomName'],
      createdAt: DateTime.parse(json['createdAt']),
      caller: json['caller'] != null ? User.fromJson(json['caller']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
    );
  }
}
