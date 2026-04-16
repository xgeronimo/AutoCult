import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resetPassword({required String email});

  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> deleteAccount({required String password});

  Stream<UserEntity?> get authStateChanges;
}
