import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_record_entity.dart';

/// Интерфейс репозитория записей ТО
abstract class ServiceRecordRepository {
  /// Получить все записи ТО для автомобиля
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecords(String carId);

  /// Получить все записи ТО пользователя
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecordsByUserId(String userId);

  /// Получить запись по ID
  Future<Either<Failure, ServiceRecordEntity>> getRecordById(String recordId);

  /// Добавить запись
  Future<Either<Failure, ServiceRecordEntity>> addRecord(ServiceRecordEntity record);

  /// Обновить запись
  Future<Either<Failure, ServiceRecordEntity>> updateRecord(ServiceRecordEntity record);

  /// Удалить запись
  Future<Either<Failure, void>> deleteRecord(String recordId);

  /// Получить записи по категории
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecordsByCategory(
    String carId,
    ServiceCategory category,
  );

  /// Получить последние записи
  Future<Either<Failure, List<ServiceRecordEntity>>> getRecentRecords(
    String userId, {
    int limit = 10,
  });

  /// Получить статистику расходов
  Future<Either<Failure, Map<ServiceCategory, double>>> getExpensesByCategory(
    String carId, {
    DateTime? from,
    DateTime? to,
  });

  /// Поток записей ТО для автомобиля
  Stream<List<ServiceRecordEntity>> watchRecords(String carId);
}
