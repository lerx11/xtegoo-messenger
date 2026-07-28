class CalendarEvent {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime date;
  final String? time;
  final String? color;
  final String? reminder;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
    this.time,
    this.color,
    this.reminder,
    required this.createdAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      color: json['color'],
      reminder: json['reminder'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'color': color,
      'reminder': reminder,
    };
  }
}
