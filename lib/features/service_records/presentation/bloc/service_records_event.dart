part of 'service_records_bloc.dart';

abstract class ServiceRecordsEvent extends Equatable {
  const ServiceRecordsEvent();

  @override
  List<Object?> get props => [];
}

class ServiceRecordsLoadRequested extends ServiceRecordsEvent {
  final String carId;

  const ServiceRecordsLoadRequested(this.carId);

  @override
  List<Object?> get props => [carId];
}

class ServiceRecordsAddRequested extends ServiceRecordsEvent {
  final String carId;
  final String userId;
  final String title;
  final ServiceCategory category;
  final int mileage;
  final DateTime date;
  final double? cost;
  final String? description;
  final String? serviceStation;
  final List<String> photoPaths;

  const ServiceRecordsAddRequested({
    required this.carId,
    required this.userId,
    required this.title,
    required this.category,
    required this.mileage,
    required this.date,
    this.cost,
    this.description,
    this.serviceStation,
    this.photoPaths = const [],
  });

  @override
  List<Object?> get props => [
        carId,
        userId,
        title,
        category,
        mileage,
        date,
        cost,
        description,
        serviceStation,
        photoPaths
      ];
}

class ServiceRecordsUpdateRequested extends ServiceRecordsEvent {
  final ServiceRecordEntity record;
  final List<String> newPhotoPaths;

  const ServiceRecordsUpdateRequested({
    required this.record,
    this.newPhotoPaths = const [],
  });

  @override
  List<Object?> get props => [record, newPhotoPaths];
}

class ServiceRecordsDeleteRequested extends ServiceRecordsEvent {
  final String recordId;
  final String carId;

  const ServiceRecordsDeleteRequested({
    required this.recordId,
    required this.carId,
  });

  @override
  List<Object?> get props => [recordId, carId];
}
