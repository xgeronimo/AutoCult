import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _fullDate = DateFormat('d MMMM yyyy', 'ru');
  static final _shortDate = DateFormat('dd.MM.yyyy', 'ru');
  static final _monthYear = DateFormat('MMMM yyyy', 'ru');
  static final _dayMonth = DateFormat('d MMMM', 'ru');
  static final _time = DateFormat('HH:mm', 'ru');
  static final _dateTime = DateFormat('d MMMM yyyy, HH:mm', 'ru');

  static String fullDate(DateTime date) => _fullDate.format(date);

  static String shortDate(DateTime date) => _shortDate.format(date);

  static String monthYear(DateTime date) => _monthYear.format(date);

  static String dayMonth(DateTime date) => _dayMonth.format(date);

  static String time(DateTime date) => _time.format(date);

  static String dateTime(DateTime date) => _dateTime.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Сегодня';
    } else if (difference == 1) {
      return 'Вчера';
    } else if (difference < 7) {
      return '$difference ${_daysWord(difference)} назад';
    } else {
      return shortDate(date);
    }
  }

  static String _daysWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if (days % 10 >= 2 &&
        days % 10 <= 4 &&
        (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.difference(today).inDays;
  }

  static bool isOverdue(DateTime date) => daysUntil(date) < 0;
}
