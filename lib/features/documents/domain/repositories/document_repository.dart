import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(String carId);
  Future<Either<Failure, DocumentEntity>> addDocument(DocumentEntity document);
  Future<Either<Failure, void>> deleteDocument(String documentId);
}
