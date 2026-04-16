import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/repositories/car_repository.dart';
import '../datasources/car_remote_datasource.dart';
import '../models/car_model.dart';

class CarRepositoryImpl implements CarRepository {
  final CarRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CarRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<bool> _checkConnection() async {
    try {
      return await networkInfo.isConnected;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<Either<Failure, List<CarEntity>>> getCars(String userId) async {
    try {
      if (!await _checkConnection()) {
        return const Left(NetworkFailure());
      }
      final cars = await remoteDataSource.getCars(userId);
      return Right(cars);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> getCarById(String carId) async {
    try {
      if (!await _checkConnection()) {
        return const Left(NetworkFailure());
      }
      final car = await remoteDataSource.getCarById(carId);
      return Right(car);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> addCar(CarEntity car) async {
    try {
      if (!await _checkConnection()) {
        return const Left(NetworkFailure());
      }
      final carId = car.id.isEmpty ? const Uuid().v4() : car.id;
      final carModel = CarModel.fromEntity(car).copyWith(id: carId);
      final result = await remoteDataSource.addCar(carModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> updateCar(CarEntity car) async {
    try {
      if (!await _checkConnection()) {
        return const Left(NetworkFailure());
      }
      final carModel = CarModel.fromEntity(car);
      final result = await remoteDataSource.updateCar(carModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar(String carId) async {
    try {
      if (!await _checkConnection()) {
        return const Left(NetworkFailure());
      }
      await remoteDataSource.deleteCar(carId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> updateMileage(
      String carId, int mileage) async {
    try {
      if (!await _checkConnection()) {
        return const Left(NetworkFailure());
      }
      final result = await remoteDataSource.updateMileage(carId, mileage);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<CarEntity>> watchCars(String userId) {
    return remoteDataSource.watchCars(userId);
  }
}
