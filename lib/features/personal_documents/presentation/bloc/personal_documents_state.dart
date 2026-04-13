part of 'personal_documents_bloc.dart';

abstract class PersonalDocumentsState extends Equatable {
  const PersonalDocumentsState();

  @override
  List<Object?> get props => [];
}

class PersonalDocumentsInitial extends PersonalDocumentsState {
  const PersonalDocumentsInitial();
}

class PersonalDocumentsLoading extends PersonalDocumentsState {
  const PersonalDocumentsLoading();
}

class PersonalDocumentsLoaded extends PersonalDocumentsState {
  final List<PersonalDocumentEntity> documents;
  final String userId;

  const PersonalDocumentsLoaded({
    required this.documents,
    required this.userId,
  });

  @override
  List<Object?> get props => [documents, userId];
}

class PersonalDocumentsAddSuccess extends PersonalDocumentsState {
  final PersonalDocumentEntity document;

  const PersonalDocumentsAddSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class PersonalDocumentsError extends PersonalDocumentsState {
  final String message;

  const PersonalDocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
