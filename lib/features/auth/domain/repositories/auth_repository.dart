import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Интерфейс репозитория авторизации
abstract class AuthRepository {
  /// Текущий пользователь
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Вход по email и паролю
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Регистрация по email и паролю
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Выход
  Future<Either<Failure, void>> signOut();

  /// Сброс пароля
  Future<Either<Failure, void>> resetPassword({required String email});

  /// Обновление профиля
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Смена пароля
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Удаление аккаунта
  Future<Either<Failure, void>> deleteAccount({required String password});

  /// Поток состояния авторизации
  Stream<UserEntity?> get authStateChanges;
}
