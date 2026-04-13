import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';

part 'documents_event.dart';
part 'documents_state.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  final DocumentRepository repository;
  final ImageStorageService imageStorageService;

  DocumentsBloc({
    required this.repository,
    required this.imageStorageService,
  }) : super(const DocumentsInitial()) {
    on<DocumentsLoadRequested>(_onLoad);
    on<DocumentsAddRequested>(_onAdd);
    on<DocumentsDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    DocumentsLoadRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(const DocumentsLoading());

    final result = await repository.getDocuments(event.carId);

    result.fold(
      (failure) => emit(DocumentsError(failure.message)),
      (documents) => emit(DocumentsLoaded(
        documents: documents,
        carId: event.carId,
      )),
    );
  }

  Future<void> _onAdd(
    DocumentsAddRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    final currentState = state;
    emit(const DocumentsLoading());

    try {
      final photoUrl = await imageStorageService.uploadImage(
        storagePath: StoragePaths.documents,
        filePath: event.photoPath,
        ownerId: event.userId,
      );

      final document = DocumentEntity(
        id: const Uuid().v4(),
        carId: event.carId,
        userId: event.userId,
        type: event.type,
        label: event.label,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.addDocument(document);

      result.fold(
        (failure) {
          emit(DocumentsError(failure.message));
          if (currentState is DocumentsLoaded) emit(currentState);
        },
        (addedDoc) {
          emit(DocumentsAddSuccess(addedDoc));
          if (currentState is DocumentsLoaded) {
            emit(DocumentsLoaded(
              documents: [...currentState.documents, addedDoc],
              carId: currentState.carId,
            ));
          } else {
            emit(DocumentsLoaded(
              documents: [addedDoc],
              carId: event.carId,
            ));
          }
        },
      );
    } catch (e) {
      emit(DocumentsError(e.toString()));
      if (currentState is DocumentsLoaded) emit(currentState);
    }
  }

  Future<void> _onDelete(
    DocumentsDeleteRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DocumentsLoaded) return;

    emit(const DocumentsLoading());

    try {
      // Delete photo from storage
      final doc = currentState.documents
          .where((d) => d.id == event.documentId)
          .firstOrNull;
      if (doc == null) {
        emit(const DocumentsError('Документ не найден'));
        emit(currentState);
        return;
      }
      await imageStorageService.deleteImage(doc.photoUrl);

      final result = await repository.deleteDocument(event.documentId);

      result.fold(
        (failure) {
          emit(DocumentsError(failure.message));
          emit(currentState);
        },
        (_) {
          final updated = currentState.documents
              .where((d) => d.id != event.documentId)
              .toList();
          emit(DocumentsLoaded(
            documents: updated,
            carId: currentState.carId,
          ));
        },
      );
    } catch (e) {
      emit(DocumentsError(e.toString()));
      emit(currentState);
    }
  }
}
