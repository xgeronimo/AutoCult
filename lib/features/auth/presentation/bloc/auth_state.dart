part of 'auth_bloc.dart';

/// Базовый класс состояний авторизации
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class AuthInitial extends AuthState {}

/// Загрузка
class AuthLoading extends AuthState {}

/// Пользователь авторизован
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Пользователь не авторизован
class AuthUnauthenticated extends AuthState {}

/// Письмо для сброса пароля отправлено
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object> get props => [email];
}

/// Ошибка авторизации
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
