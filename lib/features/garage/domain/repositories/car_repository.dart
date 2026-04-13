import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/car_entity.dart';

/// Интерфейс репозитория автомобилей
abstract class CarRepository {
  /// Получить все автомобили пользователя
  Future<Either<Failure, List<CarEntity>>> getCars(String userId);

  /// Получить автомобиль по ID
  Future<Either<Failure, CarEntity>> getCarById(String carId);

  /// Добавить автомобиль
  Future<Either<Failure, CarEntity>> addCar(CarEntity car);

  /// Обновить автомобиль
  Future<Either<Failure, CarEntity>> updateCar(CarEntity car);

  /// Удалить автомобиль
  Future<Either<Failure, void>> deleteCar(String carId);

  /// Обновить пробег
  Future<Either<Failure, CarEntity>> updateMileage(String carId, int mileage);

  /// Поток автомобилей пользователя
  Stream<List<CarEntity>> watchCars(String userId);
}
