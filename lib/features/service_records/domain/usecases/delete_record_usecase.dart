import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/service_record_repository.dart';

/// UseCase для удаления записи об обслуживании
class DeleteRecordUseCase {
  final ServiceRecordRepository repository;

  DeleteRecordUseCase(this.repository);

  Future<Either<Failure, void>> call(String recordId) {
    return repository.deleteRecord(recordId);
  }
}
