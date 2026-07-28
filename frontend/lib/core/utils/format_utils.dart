import 'package:intl/intl.dart';

final _timeFormat = DateFormat('HH:mm');
final _dateFormat = DateFormat('dd.MM.yyyy');
final _weekdayFormat = DateFormat('EEEE, d MMMM', 'ru');

class FormatUtils {
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String formatWeekday(DateTime dateTime) {
    return _weekdayFormat.format(dateTime);
  }

  static String formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return formatTime(dateTime);
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Вчера';
    } else {
      return formatDate(dateTime);
    }
  }

  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
