import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/service_record_entity.dart';
import '../../domain/repositories/service_record_repository.dart';
import '../datasources/service_record_remote_datasource.dart';
import '../models/service_record_model.dart';

class ServiceRecordRepositoryImpl implements ServiceRecordRepository {
  final ServiceRecordRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ServiceRecordRepositoryImpl({
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
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecords(
      String carId) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      final records = await remoteDataSource.getRecords(carId);
      return Right(records);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecordsByUserId(
      String userId) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      final records = await remoteDataSource.getRecordsByUserId(userId);
      return Right(records);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceRecordEntity>> getRecordById(
      String recordId) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      final record = await remoteDataSource.getRecordById(recordId);
      return Right(record);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceRecordEntity>> addRecord(
      ServiceRecordEntity record) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      final recordModel = ServiceRecordModel.fromEntity(record);
      final result = await remoteDataSource.addRecord(recordModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceRecordEntity>> updateRecord(
      ServiceRecordEntity record) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      final recordModel = ServiceRecordModel.fromEntity(record);
      final result = await remoteDataSource.updateRecord(recordModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(String recordId) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteRecord(recordId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecordsByCategory(
    String carId,
    ServiceCategory category,
  ) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      final records =
          await remoteDataSource.getRecordsByCategory(carId, category);
      return Right(records);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecentRecords(
    String userId, {
    int limit = 10,
  }) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      final records =
          await remoteDataSource.getRecentRecords(userId, limit: limit);
      return Right(records);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<ServiceCategory, double>>> getExpensesByCategory(
    String carId, {
    DateTime? from,
    DateTime? to,
  }) async {
    if (!await _checkConnection()) {
      return const Left(NetworkFailure());
    }

    try {
      final records = await remoteDataSource.getRecords(carId);

      final filteredRecords = records.where((record) {
        if (from != null && record.date.isBefore(from)) return false;
        if (to != null && record.date.isAfter(to)) return false;
        return true;
      });

      final expenses = <ServiceCategory, double>{};
      for (final record in filteredRecords) {
        if (record.cost != null) {
          expenses[record.category] =
              (expenses[record.category] ?? 0) + record.cost!;
        }
      }

      return Right(expenses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ServiceRecordEntity>> watchRecords(String carId) {
    return remoteDataSource.watchRecords(carId);
  }
}
