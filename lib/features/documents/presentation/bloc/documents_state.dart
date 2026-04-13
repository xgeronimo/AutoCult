part of 'documents_bloc.dart';

abstract class DocumentsState extends Equatable {
  const DocumentsState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {
  const DocumentsInitial();
}

class DocumentsLoading extends DocumentsState {
  const DocumentsLoading();
}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentEntity> documents;
  final String carId;

  const DocumentsLoaded({
    required this.documents,
    required this.carId,
  });

  DocumentEntity? getByType(DocumentType type) {
    try {
      return documents.firstWhere((d) => d.type == type);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [documents, carId];
}

class DocumentsAddSuccess extends DocumentsState {
  final DocumentEntity document;

  const DocumentsAddSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentsError extends DocumentsState {
  final String message;

  const DocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
