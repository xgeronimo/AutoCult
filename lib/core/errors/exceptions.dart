abstract class AppException implements Exception {
  final String message;
  final int? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  const ServerException({super.message = 'Ошибка сервера', super.code});
}

class CacheException extends AppException {
  const CacheException({super.message = 'Ошибка кэша', super.code});
}

class NetworkException extends AppException {
  const NetworkException(
      {super.message = 'Нет подключения к интернету', super.code});
}

class AuthException extends AppException {
  const AuthException({super.message = 'Ошибка авторизации', super.code});
}
