import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_record_entity.dart';
import '../repositories/service_record_repository.dart';

class GetRecordsUseCase {
  final ServiceRecordRepository repository;

  GetRecordsUseCase(this.repository);

  Future<Either<Failure, List<ServiceRecordEntity>>> call(String carId) {
    return repository.getRecords(carId);
  }
}
