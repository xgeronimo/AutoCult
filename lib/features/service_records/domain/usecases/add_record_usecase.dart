import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_record_entity.dart';
import '../repositories/service_record_repository.dart';

/// UseCase для добавления записи об обслуживании
class AddRecordUseCase {
  final ServiceRecordRepository repository;

  AddRecordUseCase(this.repository);

  Future<Either<Failure, ServiceRecordEntity>> call(ServiceRecordEntity record) {
    return repository.addRecord(record);
  }
}
