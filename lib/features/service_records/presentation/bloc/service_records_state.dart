part of 'service_records_bloc.dart';

/// Базовый класс состояний для записей об обслуживании
abstract class ServiceRecordsState extends Equatable {
  const ServiceRecordsState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class ServiceRecordsInitial extends ServiceRecordsState {
  const ServiceRecordsInitial();
}

/// Загрузка
class ServiceRecordsLoading extends ServiceRecordsState {
  const ServiceRecordsLoading();
}

/// Записи загружены
class ServiceRecordsLoaded extends ServiceRecordsState {
  final List<ServiceRecordEntity> records;
  final String carId;

  const ServiceRecordsLoaded({
    required this.records,
    required this.carId,
  });

  @override
  List<Object?> get props => [records, carId];
}

/// Запись успешно добавлена
class ServiceRecordsAddSuccess extends ServiceRecordsState {
  final ServiceRecordEntity record;

  const ServiceRecordsAddSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

/// Запись успешно обновлена
class ServiceRecordsUpdateSuccess extends ServiceRecordsState {
  final ServiceRecordEntity record;

  const ServiceRecordsUpdateSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

/// Ошибка
class ServiceRecordsError extends ServiceRecordsState {
  final String message;

  const ServiceRecordsError(this.message);

  @override
  List<Object?> get props => [message];
}
