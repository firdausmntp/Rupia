import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _fullFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _shortFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _dayFormat = DateFormat('EEEE', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');

  static String formatFull(DateTime date) {
    return _fullFormat.format(date);
  }

  static String formatShort(DateTime date) {
    return _shortFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatDay(DateTime date) {
    return _dayFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    } else {
      return formatShort(date);
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}
