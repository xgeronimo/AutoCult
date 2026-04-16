import 'package:intl/intl.dart';

class NumberFormatter {
  NumberFormatter._();

  static final _currency =
      NumberFormat.currency(locale: 'ru', symbol: '₽', decimalDigits: 0);
  static final _currencyDecimal =
      NumberFormat.currency(locale: 'ru', symbol: '₽', decimalDigits: 2);
  static final _number = NumberFormat('#,###', 'ru');
  static final _decimal = NumberFormat('#,##0.0', 'ru');

  static String currency(num value) => _currency.format(value);

  static String currencyDecimal(num value) => _currencyDecimal.format(value);

  static String number(num value) => _number.format(value);

  static String decimal(num value) => _decimal.format(value);

  static String mileage(int value) => '${_number.format(value)} км';

  static String compact(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  static String engineVolume(double value) => '${value.toStringAsFixed(1)} л';

  static int? parseInt(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    return int.tryParse(cleaned);
  }

  static double? parseDouble(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }
}
