import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../domain/entities/personal_document_entity.dart';
import '../../domain/repositories/personal_document_repository.dart';

part 'personal_documents_event.dart';
part 'personal_documents_state.dart';

class PersonalDocumentsBloc extends Bloc<PersonalDocumentsEvent, PersonalDocumentsState> {
  final PersonalDocumentRepository repository;
  final ImageStorageService imageStorageService;

  PersonalDocumentsBloc({
    required this.repository,
    required this.imageStorageService,
  }) : super(const PersonalDocumentsInitial()) {
    on<PersonalDocumentsLoadRequested>(_onLoad);
    on<PersonalDocumentsAddRequested>(_onAdd);
    on<PersonalDocumentsDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    PersonalDocumentsLoadRequested event,
    Emitter<PersonalDocumentsState> emit,
  ) async {
    emit(const PersonalDocumentsLoading());

    final result = await repository.getDocuments(event.userId);

    result.fold(
      (failure) => emit(PersonalDocumentsError(failure.message)),
      (documents) => emit(PersonalDocumentsLoaded(
        documents: documents,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onAdd(
    PersonalDocumentsAddRequested event,
    Emitter<PersonalDocumentsState> emit,
  ) async {
    final currentState = state;
    emit(const PersonalDocumentsLoading());

    try {
      final photoUrl = await imageStorageService.uploadImage(
        storagePath: StoragePaths.documents,
        filePath: event.photoPath,
        ownerId: event.userId,
      );

      final document = PersonalDocumentEntity(
        id: const Uuid().v4(),
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
          emit(PersonalDocumentsError(failure.message));
          if (currentState is PersonalDocumentsLoaded) emit(currentState);
        },
        (addedDoc) {
          emit(PersonalDocumentsAddSuccess(addedDoc));
          if (currentState is PersonalDocumentsLoaded) {
            emit(PersonalDocumentsLoaded(
              documents: [...currentState.documents, addedDoc],
              userId: currentState.userId,
            ));
          } else {
            emit(PersonalDocumentsLoaded(
              documents: [addedDoc],
              userId: event.userId,
            ));
          }
        },
      );
    } catch (e) {
      emit(PersonalDocumentsError(e.toString()));
      if (currentState is PersonalDocumentsLoaded) emit(currentState);
    }
  }

  Future<void> _onDelete(
    PersonalDocumentsDeleteRequested event,
    Emitter<PersonalDocumentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PersonalDocumentsLoaded) return;

    emit(const PersonalDocumentsLoading());

    try {
      final doc = currentState.documents
          .where((d) => d.id == event.documentId)
          .firstOrNull;
      if (doc == null) {
        emit(const PersonalDocumentsError('Документ не найден'));
        emit(currentState);
        return;
      }
      await imageStorageService.deleteImage(doc.photoUrl);

      final result = await repository.deleteDocument(event.documentId);

      result.fold(
        (failure) {
          emit(PersonalDocumentsError(failure.message));
          emit(currentState);
        },
        (_) {
          final updated = currentState.documents
              .where((d) => d.id != event.documentId)
              .toList();
          emit(PersonalDocumentsLoaded(
            documents: updated,
            userId: currentState.userId,
          ));
        },
      );
    } catch (e) {
      emit(PersonalDocumentsError(e.toString()));
      emit(currentState);
    }
  }
}
