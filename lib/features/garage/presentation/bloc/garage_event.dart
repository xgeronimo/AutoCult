part of 'garage_bloc.dart';

abstract class GarageEvent extends Equatable {
  const GarageEvent();

  @override
  List<Object?> get props => [];
}

class GarageLoadCars extends GarageEvent {
  const GarageLoadCars();
}

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

class GarageDeleteCarPhoto extends GarageEvent {
  final String carId;

  const GarageDeleteCarPhoto({required this.carId});

  @override
  List<Object?> get props => [carId];
}

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

class GarageUpdateCar extends GarageEvent {
  final CarEntity car;

  const GarageUpdateCar({required this.car});

  @override
  List<Object?> get props => [car];
}

class GarageDeleteCar extends GarageEvent {
  final String carId;

  const GarageDeleteCar({required this.carId});

  @override
  List<Object?> get props => [carId];
}

class GarageMarkAsFormer extends GarageEvent {
  final String carId;

  const GarageMarkAsFormer({required this.carId});

  @override
  List<Object?> get props => [carId];
}

class GarageSelectCar extends GarageEvent {
  final String carId;

  const GarageSelectCar({required this.carId});

  @override
  List<Object?> get props => [carId];
}
