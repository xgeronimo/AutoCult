part of 'auth_bloc.dart';

/// Базовый класс событий авторизации
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Проверка состояния авторизации при запуске
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Запрос на вход
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Запрос на регистрацию
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Запрос на выход
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Запрос на сброс пароля
class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Изменение состояния авторизации (от Firebase)
class AuthStateChanged extends AuthEvent {
  final UserEntity? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
