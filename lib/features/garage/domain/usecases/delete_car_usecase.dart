import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/car_repository.dart';

class DeleteCarUseCase implements UseCase<void, String> {
  final CarRepository repository;

  DeleteCarUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String carId) {
    return repository.deleteCar(carId);
  }
}
