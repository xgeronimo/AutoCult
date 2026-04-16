part of 'service_records_bloc.dart';

abstract class ServiceRecordsState extends Equatable {
  const ServiceRecordsState();

  @override
  List<Object?> get props => [];
}

class ServiceRecordsInitial extends ServiceRecordsState {
  const ServiceRecordsInitial();
}

class ServiceRecordsLoading extends ServiceRecordsState {
  const ServiceRecordsLoading();
}

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

class ServiceRecordsAddSuccess extends ServiceRecordsState {
  final ServiceRecordEntity record;

  const ServiceRecordsAddSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class ServiceRecordsUpdateSuccess extends ServiceRecordsState {
  final ServiceRecordEntity record;

  const ServiceRecordsUpdateSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class ServiceRecordsError extends ServiceRecordsState {
  final String message;

  const ServiceRecordsError(this.message);

  @override
  List<Object?> get props => [message];
}
