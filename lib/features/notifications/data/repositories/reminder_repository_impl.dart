import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_remote_datasource.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReminderRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<bool> _checkConnection() async {
    try {
      return await networkInfo.isConnected;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getReminders(
      String userId) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      final reminders = await remoteDataSource.getReminders(userId);
      return Right(reminders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> createReminder(
      ReminderEntity reminder) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      final model = ReminderModel.fromEntity(reminder);
      final result = await remoteDataSource.createReminder(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String reminderId) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      await remoteDataSource.markAsRead(reminderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String reminderId) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      await remoteDataSource.deleteReminder(reminderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
