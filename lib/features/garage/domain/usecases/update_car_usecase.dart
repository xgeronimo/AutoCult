import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class UpdateCarUseCase implements UseCase<CarEntity, CarEntity> {
  final CarRepository repository;

  UpdateCarUseCase(this.repository);

  @override
  Future<Either<Failure, CarEntity>> call(CarEntity car) {
    return repository.updateCar(car);
  }
}
