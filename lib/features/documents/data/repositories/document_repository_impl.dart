import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DocumentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<bool> _checkConnection() async {
    try {
      return await networkInfo.isConnected;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(String carId) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      final docs = await remoteDataSource.getDocuments(carId);
      return Right(docs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> addDocument(DocumentEntity document) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      final model = DocumentModel.fromEntity(document);
      final result = await remoteDataSource.addDocument(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String documentId) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      await remoteDataSource.deleteDocument(documentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
