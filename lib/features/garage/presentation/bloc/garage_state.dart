part of 'garage_bloc.dart';

abstract class GarageState extends Equatable {
  const GarageState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class GarageInitial extends GarageState {
  const GarageInitial();
}

/// Загрузка
class GarageLoading extends GarageState {
  const GarageLoading();
}

/// Загружено
class GarageLoaded extends GarageState {
  final List<CarEntity> cars;
  final CarEntity? selectedCar;

  const GarageLoaded({
    required this.cars,
    this.selectedCar,
  });

  /// Есть ли автомобили
  bool get hasCars => cars.isNotEmpty;

  /// Выбранный автомобиль или первый в списке
  CarEntity? get currentCar => selectedCar ?? (cars.isNotEmpty ? cars.first : null);

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

/// Ошибка
class GarageError extends GarageState {
  final String message;

  const GarageError({required this.message});

  @override
  List<Object?> get props => [message];
}
