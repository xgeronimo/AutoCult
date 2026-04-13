import 'package:equatable/equatable.dart';

/// Базовый класс ошибок приложения
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Ошибка сервера (Firebase, API)
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Ошибка сервера', super.code});
}

/// Ошибка кэша (Hive, SharedPreferences)
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Ошибка кэша', super.code});
}

/// Ошибка сети
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Нет подключения к интернету', super.code});
}

/// Ошибка авторизации
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Ошибка авторизации', super.code});
}

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Неизвестная ошибка
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Неизвестная ошибка', super.code});
}
