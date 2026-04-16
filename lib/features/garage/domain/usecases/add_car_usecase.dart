import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class AddCarUseCase implements UseCase<CarEntity, CarEntity> {
  final CarRepository repository;

  AddCarUseCase(this.repository);

  @override
  Future<Either<Failure, CarEntity>> call(CarEntity car) {
    return repository.addCar(car);
  }
}
