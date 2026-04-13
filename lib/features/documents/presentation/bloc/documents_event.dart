part of 'documents_bloc.dart';

abstract class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => [];
}

class DocumentsLoadRequested extends DocumentsEvent {
  final String carId;

  const DocumentsLoadRequested(this.carId);

  @override
  List<Object?> get props => [carId];
}

class DocumentsAddRequested extends DocumentsEvent {
  final String carId;
  final String userId;
  final DocumentType type;
  final String? label;
  final String photoPath;

  const DocumentsAddRequested({
    required this.carId,
    required this.userId,
    required this.type,
    this.label,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [carId, userId, type, label, photoPath];
}

class DocumentsDeleteRequested extends DocumentsEvent {
  final String documentId;

  const DocumentsDeleteRequested(this.documentId);

  @override
  List<Object?> get props => [documentId];
}
