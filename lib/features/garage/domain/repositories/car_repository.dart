import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/car_entity.dart';

abstract class CarRepository {
  Future<Either<Failure, List<CarEntity>>> getCars(String userId);

  Future<Either<Failure, CarEntity>> getCarById(String carId);

  Future<Either<Failure, CarEntity>> addCar(CarEntity car);

  Future<Either<Failure, CarEntity>> updateCar(CarEntity car);

  Future<Either<Failure, void>> deleteCar(String carId);

  Future<Either<Failure, CarEntity>> updateMileage(String carId, int mileage);

  Stream<List<CarEntity>> watchCars(String userId);
}
