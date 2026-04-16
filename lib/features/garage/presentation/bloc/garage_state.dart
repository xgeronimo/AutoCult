part of 'garage_bloc.dart';

abstract class GarageState extends Equatable {
  const GarageState();

  @override
  List<Object?> get props => [];
}

class GarageInitial extends GarageState {
  const GarageInitial();
}

class GarageLoading extends GarageState {
  const GarageLoading();
}

class GarageLoaded extends GarageState {
  final List<CarEntity> cars;
  final CarEntity? selectedCar;

  const GarageLoaded({
    required this.cars,
    this.selectedCar,
  });

  bool get hasCars => cars.isNotEmpty;

  CarEntity? get currentCar =>
      selectedCar ?? (cars.isNotEmpty ? cars.first : null);

  GarageLoaded copyWith({
    List<CarEntity>? cars,
    CarEntity? Function()? selectedCar,
  }) {
    return GarageLoaded(
      cars: cars ?? this.cars,
      selectedCar: selectedCar != null ? selectedCar() : this.selectedCar,
    );
  }

  @override
  List<Object?> get props => [cars, selectedCar];
}

class GarageError extends GarageState {
  final String message;

  const GarageError({required this.message});

  @override
  List<Object?> get props => [message];
}
