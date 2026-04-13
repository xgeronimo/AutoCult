import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/personal_document_entity.dart';

abstract class PersonalDocumentRepository {
  Future<Either<Failure, List<PersonalDocumentEntity>>> getDocuments(String userId);
  Future<Either<Failure, PersonalDocumentEntity>> addDocument(PersonalDocumentEntity document);
  Future<Either<Failure, void>> deleteDocument(String documentId);
}
