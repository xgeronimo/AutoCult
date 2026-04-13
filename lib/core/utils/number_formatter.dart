import 'package:intl/intl.dart';

/// Утилиты для форматирования чисел
class NumberFormatter {
  NumberFormatter._();

  static final _currency = NumberFormat.currency(locale: 'ru', symbol: '₽', decimalDigits: 0);
  static final _currencyDecimal = NumberFormat.currency(locale: 'ru', symbol: '₽', decimalDigits: 2);
  static final _number = NumberFormat('#,###', 'ru');
  static final _decimal = NumberFormat('#,##0.0', 'ru');

  /// Форматирование валюты: "15 000 ₽"
  static String currency(num value) => _currency.format(value);

  /// Форматирование валюты с копейками: "15 000,50 ₽"
  static String currencyDecimal(num value) => _currencyDecimal.format(value);

  /// Форматирование числа: "15 000"
  static String number(num value) => _number.format(value);

  /// Форматирование с десятичными: "15 000,5"
  static String decimal(num value) => _decimal.format(value);

  /// Форматирование пробега: "150 000 км"
  static String mileage(int value) => '${_number.format(value)} км';

  /// Краткое форматирование больших чисел: "1.5K", "2.3M"
  static String compact(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  /// Форматирование объёма двигателя: "2.0 л"
  static String engineVolume(double value) => '${value.toStringAsFixed(1)} л';

  /// Парсинг числа из строки с пробелами
  static int? parseInt(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    return int.tryParse(cleaned);
  }

  /// Парсинг дробного числа из строки
  static double? parseDouble(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }
}
