import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

/// Use Case для получения списка автомобилей
class GetCarsUseCase implements UseCase<List<CarEntity>, String> {
  final CarRepository repository;

  GetCarsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarEntity>>> call(String userId) {
    return repository.getCars(userId);
  }
}
