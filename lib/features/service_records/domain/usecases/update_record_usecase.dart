import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_record_entity.dart';
import '../repositories/service_record_repository.dart';

class UpdateRecordUseCase {
  final ServiceRecordRepository repository;

  UpdateRecordUseCase(this.repository);

  Future<Either<Failure, ServiceRecordEntity>> call(
      ServiceRecordEntity record) {
    return repository.updateRecord(record);
  }
}
