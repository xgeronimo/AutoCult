part of 'personal_documents_bloc.dart';

abstract class PersonalDocumentsEvent extends Equatable {
  const PersonalDocumentsEvent();

  @override
  List<Object?> get props => [];
}

class PersonalDocumentsLoadRequested extends PersonalDocumentsEvent {
  final String userId;

  const PersonalDocumentsLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class PersonalDocumentsAddRequested extends PersonalDocumentsEvent {
  final String userId;
  final PersonalDocumentType type;
  final String? label;
  final String photoPath;

  const PersonalDocumentsAddRequested({
    required this.userId,
    required this.type,
    this.label,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [userId, type, label, photoPath];
}

class PersonalDocumentsDeleteRequested extends PersonalDocumentsEvent {
  final String documentId;

  const PersonalDocumentsDeleteRequested(this.documentId);

  @override
  List<Object?> get props => [documentId];
}
