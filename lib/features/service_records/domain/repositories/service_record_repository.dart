import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_record_entity.dart';

abstract class ServiceRecordRepository {
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecords(String carId);

  Future<Either<Failure, List<ServiceRecordEntity>>> getRecordsByUserId(
      String userId);

  Future<Either<Failure, ServiceRecordEntity>> getRecordById(String recordId);

  Future<Either<Failure, ServiceRecordEntity>> addRecord(
      ServiceRecordEntity record);

  Future<Either<Failure, ServiceRecordEntity>> updateRecord(
      ServiceRecordEntity record);

  Future<Either<Failure, void>> deleteRecord(String recordId);

  Future<Either<Failure, List<ServiceRecordEntity>>> getRecordsByCategory(
    String carId,
    ServiceCategory category,
  );

  Future<Either<Failure, List<ServiceRecordEntity>>> getRecentRecords(
    String userId, {
    int limit = 10,
  });

  Future<Either<Failure, Map<ServiceCategory, double>>> getExpensesByCategory(
    String carId, {
    DateTime? from,
    DateTime? to,
  });

  Stream<List<ServiceRecordEntity>> watchRecords(String carId);
}
