import 'package:intl/intl.dart';

/// Утилиты для форматирования дат
class DateFormatter {
  DateFormatter._();

  static final _fullDate = DateFormat('d MMMM yyyy', 'ru');
  static final _shortDate = DateFormat('dd.MM.yyyy', 'ru');
  static final _monthYear = DateFormat('MMMM yyyy', 'ru');
  static final _dayMonth = DateFormat('d MMMM', 'ru');
  static final _time = DateFormat('HH:mm', 'ru');
  static final _dateTime = DateFormat('d MMMM yyyy, HH:mm', 'ru');

  /// Полная дата: "15 января 2024"
  static String fullDate(DateTime date) => _fullDate.format(date);

  /// Короткая дата: "15.01.2024"
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// Месяц и год: "Январь 2024"
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// День и месяц: "15 января"
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  /// Время: "14:30"
  static String time(DateTime date) => _time.format(date);

  /// Дата и время: "15 января 2024, 14:30"
  static String dateTime(DateTime date) => _dateTime.format(date);

  /// Относительная дата: "Сегодня", "Вчера", "3 дня назад"
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

  /// Склонение слова "день"
  static String _daysWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if (days % 10 >= 2 && days % 10 <= 4 && (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }

  /// Дней до даты
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.difference(today).inDays;
  }

  /// Просрочено ли
  static bool isOverdue(DateTime date) => daysUntil(date) < 0;
}
