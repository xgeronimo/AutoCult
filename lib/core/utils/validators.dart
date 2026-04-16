import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Некорректный email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Подтвердите пароль';
      }
      if (value != password) {
        return 'Пароли не совпадают';
      }
      return null;
    };
  }

  static String? required(String? value, [String fieldName = 'поле']) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните $fieldName';
    }
    return null;
  }

  static String? vin(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length != AppConstants.vinLength) {
      return 'VIN должен содержать ${AppConstants.vinLength} символов';
    }
    if (value.contains(RegExp(r'[IOQioq]'))) {
      return 'VIN не может содержать буквы I, O, Q';
    }
    return null;
  }

  static String? licensePlate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!AppConstants.licensePlateRegex.hasMatch(value.toUpperCase())) {
      return 'Некорректный формат гос. номера';
    }
    return null;
  }

  static String? year(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите год выпуска';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Некорректный год';
    }
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Год должен быть от 1900 до ${currentYear + 1}';
    }
    return null;
  }

  static String? mileage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пробег';
    }
    final mileage = int.tryParse(value.replaceAll(RegExp(r'\s'), ''));
    if (mileage == null || mileage < 0) {
      return 'Некорректный пробег';
    }
    if (mileage > 10000000) {
      return 'Слишком большой пробег';
    }
    return null;
  }

  static String? cost(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final cost = double.tryParse(value.replaceAll(RegExp(r'[\s,]'), ''));
    if (cost == null || cost < 0) {
      return 'Некорректная стоимость';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Некорректный номер телефона';
    }
    return null;
  }
}
