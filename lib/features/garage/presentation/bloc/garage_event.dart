part of 'garage_bloc.dart';

abstract class GarageEvent extends Equatable {
  const GarageEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузить автомобили пользователя
class GarageLoadCars extends GarageEvent {
  const GarageLoadCars();
}

/// Добавить автомобиль
class GarageAddCar extends GarageEvent {
  final String brand;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final int mileage;
  final FuelType fuelType;
  final double? engineVolume;
  final TransmissionType? transmission;
  final String? color;
  final String? photoPath;
  final String? description;
  final BodyType bodyType;

  const GarageAddCar({
    required this.brand,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    required this.mileage,
    required this.fuelType,
    this.engineVolume,
    this.transmission,
    this.color,
    this.photoPath,
    this.description,
    this.bodyType = BodyType.sedan,
  });

  @override
  List<Object?> get props => [
        brand,
        model,
        year,
        vin,
        licensePlate,
        mileage,
        fuelType,
        engineVolume,
        transmission,
        color,
        photoPath,
        description,
        bodyType,
      ];
}

/// Удалить фото автомобиля
class GarageDeleteCarPhoto extends GarageEvent {
  final String carId;

  const GarageDeleteCarPhoto({required this.carId});

  @override
  List<Object?> get props => [carId];
}

/// Обновить фото автомобиля
class GarageUpdateCarPhoto extends GarageEvent {
  final String carId;
  final String photoPath;

  const GarageUpdateCarPhoto({
    required this.carId,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [carId, photoPath];
}

/// Обновить автомобиль
class GarageUpdateCar extends GarageEvent {
  final CarEntity car;

  const GarageUpdateCar({required this.car});

  @override
  List<Object?> get props => [car];
}

/// Удалить автомобиль
class GarageDeleteCar extends GarageEvent {
  final String carId;

  const GarageDeleteCar({required this.carId});

  @override
  List<Object?> get props => [carId];
}

/// Отметить автомобиль как бывший
class GarageMarkAsFormer extends GarageEvent {
  final String carId;

  const GarageMarkAsFormer({required this.carId});

  @override
  List<Object?> get props => [carId];
}

/// Выбрать текущий автомобиль
class GarageSelectCar extends GarageEvent {
  final String carId;

  const GarageSelectCar({required this.carId});

  @override
  List<Object?> get props => [carId];
}
