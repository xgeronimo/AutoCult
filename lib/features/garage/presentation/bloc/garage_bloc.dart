import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/usecases/get_cars_usecase.dart';
import '../../domain/usecases/add_car_usecase.dart';
import '../../domain/usecases/update_car_usecase.dart';
import '../../domain/usecases/delete_car_usecase.dart';

part 'garage_event.dart';
part 'garage_state.dart';

/// BLoC для управления гаражом
class GarageBloc extends Bloc<GarageEvent, GarageState> {
  final GetCarsUseCase getCarsUseCase;
  final AddCarUseCase addCarUseCase;
  final UpdateCarUseCase updateCarUseCase;
  final DeleteCarUseCase deleteCarUseCase;
  final ImageStorageService imageStorageService;

  String? _currentUserId;

  GarageBloc({
    required this.getCarsUseCase,
    required this.addCarUseCase,
    required this.updateCarUseCase,
    required this.deleteCarUseCase,
    required this.imageStorageService,
  }) : super(const GarageInitial()) {
    on<GarageLoadCars>(_onLoadCars);
    on<GarageAddCar>(_onAddCar);
    on<GarageUpdateCar>(_onUpdateCar);
    on<GarageDeleteCar>(_onDeleteCar);
    on<GarageMarkAsFormer>(_onMarkAsFormer);
    on<GarageSelectCar>(_onSelectCar);
    on<GarageUpdateCarPhoto>(_onUpdateCarPhoto);
    on<GarageDeleteCarPhoto>(_onDeleteCarPhoto);
  }

  /// Установить текущего пользователя
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> _onLoadCars(
    GarageLoadCars event,
    Emitter<GarageState> emit,
  ) async {
    if (_currentUserId == null) {
      emit(const GarageLoaded(cars: []));
      return;
    }

    emit(const GarageLoading());

    try {
      final result = await getCarsUseCase(_currentUserId!);
      result.fold(
        (failure) => emit(GarageError(message: failure.message)),
        (cars) => emit(GarageLoaded(
          cars: cars,
          selectedCar: cars.isNotEmpty ? cars.first : null,
        )),
      );
    } catch (e) {
      emit(GarageError(message: e.toString()));
    }
  }

  Future<void> _onAddCar(
    GarageAddCar event,
    Emitter<GarageState> emit,
  ) async {
    if (_currentUserId == null) return;

    final currentState = state;

    emit(const GarageLoading());

    try {
      // Загружаем фото в Firebase Storage, если есть
      String? photoUrl;
      if (event.photoPath != null) {
        photoUrl = await imageStorageService.uploadImage(
          storagePath: StoragePaths.carPhotos,
          filePath: event.photoPath!,
          ownerId: _currentUserId!,
        );
      }

      final newCar = CarEntity(
        id: '',
        userId: _currentUserId!,
        brand: event.brand,
        model: event.model,
        year: event.year,
        vin: event.vin,
        licensePlate: event.licensePlate,
        mileage: event.mileage,
        fuelType: event.fuelType,
        engineVolume: event.engineVolume,
        transmission: event.transmission,
        color: event.color,
        photoUrl: photoUrl,
        description: event.description,
        bodyType: event.bodyType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await addCarUseCase(newCar);

      result.fold(
        (failure) {
          emit(GarageError(message: failure.message));
          if (currentState is GarageLoaded) {
            emit(currentState);
          }
        },
        (car) {
          if (currentState is GarageLoaded) {
            emit(GarageLoaded(
              cars: [...currentState.cars, car],
              selectedCar: car,
            ));
          } else {
            emit(GarageLoaded(
              cars: [car],
              selectedCar: car,
            ));
          }
        },
      );
    } catch (e) {
      emit(GarageError(message: e.toString()));
      if (currentState is GarageLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateCar(
    GarageUpdateCar event,
    Emitter<GarageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GarageLoaded) return;

    try {
      final updatedEntity = event.car.copyWith(updatedAt: DateTime.now());

      final result = await updateCarUseCase(updatedEntity);

      result.fold(
        (failure) => emit(GarageError(message: failure.message)),
        (updatedCar) {
          final updatedCars = currentState.cars
              .map((c) => c.id == updatedCar.id ? updatedCar : c)
              .toList();
          emit(GarageLoaded(
            cars: updatedCars,
            selectedCar: updatedCar,
          ));
        },
      );
    } catch (e) {
      emit(GarageError(message: e.toString()));
    }
  }

  Future<void> _onMarkAsFormer(
    GarageMarkAsFormer event,
    Emitter<GarageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GarageLoaded) return;

    try {
      final car = currentState.cars.firstWhere((c) => c.id == event.carId);
      final formerCar = car.copyWith(isFormer: true, updatedAt: DateTime.now());

      final result = await updateCarUseCase(formerCar);

      result.fold(
        (failure) => emit(GarageError(message: failure.message)),
        (updatedCar) {
          final updatedCars = currentState.cars
              .map((c) => c.id == updatedCar.id ? updatedCar : c)
              .toList();
          emit(GarageLoaded(
            cars: updatedCars,
            selectedCar: updatedCar,
          ));
        },
      );
    } catch (e) {
      emit(GarageError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCar(
    GarageDeleteCar event,
    Emitter<GarageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GarageLoaded) return;

    emit(const GarageLoading());

    try {
      final result = await deleteCarUseCase(event.carId);

      result.fold(
        (failure) {
          emit(GarageError(message: failure.message));
          emit(currentState);
        },
        (_) {
          final updatedCars = currentState.cars
              .where((car) => car.id != event.carId)
              .toList();

          emit(GarageLoaded(
            cars: updatedCars,
            selectedCar: updatedCars.isNotEmpty ? updatedCars.first : null,
          ));
        },
      );
    } catch (e) {
      emit(GarageError(message: e.toString()));
      emit(currentState);
    }
  }

  void _onSelectCar(
    GarageSelectCar event,
    Emitter<GarageState> emit,
  ) {
    final currentState = state;
    if (currentState is! GarageLoaded) return;

    final selectedCar = currentState.cars
        .where((car) => car.id == event.carId)
        .firstOrNull ?? currentState.cars.firstOrNull;

    emit(currentState.copyWith(selectedCar: () => selectedCar));
  }

  Future<void> _onDeleteCarPhoto(
    GarageDeleteCarPhoto event,
    Emitter<GarageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GarageLoaded) return;

    try {
      final car = currentState.cars.firstWhere((c) => c.id == event.carId);

      if (car.photoUrl != null && car.photoUrl!.isNotEmpty) {
        await imageStorageService.deleteImage(car.photoUrl!);
      }

      final updatedCar = car.copyWith(
        photoUrl: () => null,
        updatedAt: DateTime.now(),
      );

      final result = await updateCarUseCase(updatedCar);

      result.fold(
        (failure) => emit(GarageError(message: failure.message)),
        (updated) {
          final updatedCars = currentState.cars
              .map((c) => c.id == updated.id ? updated : c)
              .toList();
          emit(GarageLoaded(
            cars: updatedCars,
            selectedCar: updated,
          ));
        },
      );
    } catch (e) {
      emit(GarageError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCarPhoto(
    GarageUpdateCarPhoto event,
    Emitter<GarageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GarageLoaded || _currentUserId == null) return;

    try {
      final car = currentState.cars.firstWhere((c) => c.id == event.carId);

      // Удаляем старое фото, если было
      if (car.photoUrl != null && car.photoUrl!.isNotEmpty) {
        await imageStorageService.deleteImage(car.photoUrl!);
      }

      // Загружаем новое
      final photoUrl = await imageStorageService.uploadImage(
        storagePath: StoragePaths.carPhotos,
        filePath: event.photoPath,
        ownerId: _currentUserId!,
      );

      final updatedCar = car.copyWith(
        photoUrl: () => photoUrl,
        updatedAt: DateTime.now(),
      );

      final result = await updateCarUseCase(updatedCar);

      result.fold(
        (failure) => emit(GarageError(message: failure.message)),
        (updated) {
          final updatedCars = currentState.cars
              .map((c) => c.id == updated.id ? updated : c)
              .toList();
          emit(GarageLoaded(
            cars: updatedCars,
            selectedCar: updated,
          ));
        },
      );
    } catch (e) {
      emit(GarageError(message: e.toString()));
    }
  }
}
