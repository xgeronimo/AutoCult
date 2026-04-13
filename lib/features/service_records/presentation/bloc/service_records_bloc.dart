import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../domain/entities/service_record_entity.dart';
import '../../domain/usecases/get_records_usecase.dart';
import '../../domain/usecases/add_record_usecase.dart';
import '../../domain/usecases/update_record_usecase.dart';
import '../../domain/usecases/delete_record_usecase.dart';

part 'service_records_event.dart';
part 'service_records_state.dart';

/// BLoC для управления записями об обслуживании
class ServiceRecordsBloc extends Bloc<ServiceRecordsEvent, ServiceRecordsState> {
  final GetRecordsUseCase getRecordsUseCase;
  final AddRecordUseCase addRecordUseCase;
  final UpdateRecordUseCase updateRecordUseCase;
  final DeleteRecordUseCase deleteRecordUseCase;
  final ImageStorageService imageStorageService;

  ServiceRecordsBloc({
    required this.getRecordsUseCase,
    required this.addRecordUseCase,
    required this.updateRecordUseCase,
    required this.deleteRecordUseCase,
    required this.imageStorageService,
  }) : super(const ServiceRecordsInitial()) {
    on<ServiceRecordsLoadRequested>(_onLoadRecords);
    on<ServiceRecordsAddRequested>(_onAddRecord);
    on<ServiceRecordsUpdateRequested>(_onUpdateRecord);
    on<ServiceRecordsDeleteRequested>(_onDeleteRecord);
  }

  Future<void> _onLoadRecords(
    ServiceRecordsLoadRequested event,
    Emitter<ServiceRecordsState> emit,
  ) async {
    emit(const ServiceRecordsLoading());

    final result = await getRecordsUseCase(event.carId);

    result.fold(
      (failure) => emit(ServiceRecordsError(failure.message)),
      (records) => emit(ServiceRecordsLoaded(
        records: records,
        carId: event.carId,
      )),
    );
  }

  Future<void> _onAddRecord(
    ServiceRecordsAddRequested event,
    Emitter<ServiceRecordsState> emit,
  ) async {
    final currentState = state;

    emit(const ServiceRecordsLoading());

    try {
      // Загружаем фото в Firebase Storage
      List<String> photoUrls = [];
      if (event.photoPaths.isNotEmpty) {
        photoUrls = await imageStorageService.uploadImages(
          storagePath: StoragePaths.servicePhotos,
          filePaths: event.photoPaths,
          ownerId: event.userId,
        );
      }

      final record = ServiceRecordEntity(
        id: const Uuid().v4(),
        carId: event.carId,
        userId: event.userId,
        category: event.category,
        title: event.title,
        date: event.date,
        mileage: event.mileage,
        cost: event.cost,
        description: event.description,
        serviceStation: event.serviceStation,
        photoUrls: photoUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await addRecordUseCase(record);

      result.fold(
        (failure) {
          emit(ServiceRecordsError(failure.message));
          if (currentState is ServiceRecordsLoaded) {
            emit(currentState);
          }
        },
        (addedRecord) {
          emit(ServiceRecordsAddSuccess(addedRecord));

          if (currentState is ServiceRecordsLoaded) {
            emit(ServiceRecordsLoaded(
              records: [addedRecord, ...currentState.records],
              carId: currentState.carId,
            ));
          } else {
            emit(ServiceRecordsLoaded(
              records: [addedRecord],
              carId: event.carId,
            ));
          }
        },
      );
    } catch (e) {
      emit(ServiceRecordsError(e.toString()));
      if (currentState is ServiceRecordsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateRecord(
    ServiceRecordsUpdateRequested event,
    Emitter<ServiceRecordsState> emit,
  ) async {
    final currentState = state;

    emit(const ServiceRecordsLoading());

    try {
      List<String> newPhotoUrls = [];
      if (event.newPhotoPaths.isNotEmpty) {
        newPhotoUrls = await imageStorageService.uploadImages(
          storagePath: StoragePaths.servicePhotos,
          filePaths: event.newPhotoPaths,
          ownerId: event.record.userId,
        );
      }

      final updatedRecord = ServiceRecordEntity(
        id: event.record.id,
        carId: event.record.carId,
        userId: event.record.userId,
        category: event.record.category,
        title: event.record.title,
        date: event.record.date,
        mileage: event.record.mileage,
        cost: event.record.cost,
        description: event.record.description,
        serviceStation: event.record.serviceStation,
        photoUrls: [...event.record.photoUrls, ...newPhotoUrls],
        createdAt: event.record.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await updateRecordUseCase(updatedRecord);

      result.fold(
        (failure) {
          emit(ServiceRecordsError(failure.message));
          if (currentState is ServiceRecordsLoaded) {
            emit(currentState);
          }
        },
        (record) {
          emit(ServiceRecordsUpdateSuccess(record));

          if (currentState is ServiceRecordsLoaded) {
            final updatedRecords = currentState.records
                .map((r) => r.id == record.id ? record : r)
                .toList();
            emit(ServiceRecordsLoaded(
              records: updatedRecords,
              carId: currentState.carId,
            ));
          }
        },
      );
    } catch (e) {
      emit(ServiceRecordsError(e.toString()));
      if (currentState is ServiceRecordsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteRecord(
    ServiceRecordsDeleteRequested event,
    Emitter<ServiceRecordsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ServiceRecordsLoaded) return;

    emit(const ServiceRecordsLoading());

    final result = await deleteRecordUseCase(event.recordId);

    result.fold(
      (failure) {
        emit(ServiceRecordsError(failure.message));
        emit(currentState);
      },
      (_) {
        final updatedRecords = currentState.records
            .where((r) => r.id != event.recordId)
            .toList();

        emit(ServiceRecordsLoaded(
          records: updatedRecords,
          carId: event.carId,
        ));
      },
    );
  }
}
