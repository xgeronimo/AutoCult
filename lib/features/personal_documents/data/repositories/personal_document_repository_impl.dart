import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/personal_document_entity.dart';
import '../../domain/repositories/personal_document_repository.dart';
import '../datasources/personal_document_remote_datasource.dart';
import '../models/personal_document_model.dart';

class PersonalDocumentRepositoryImpl implements PersonalDocumentRepository {
  final PersonalDocumentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PersonalDocumentRepositoryImpl({
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
  Future<Either<Failure, List<PersonalDocumentEntity>>> getDocuments(
      String userId) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      final docs = await remoteDataSource.getDocuments(userId);
      return Right(docs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonalDocumentEntity>> addDocument(
      PersonalDocumentEntity document) async {
    try {
      if (!await _checkConnection()) return const Left(NetworkFailure());
      final model = PersonalDocumentModel.fromEntity(document);
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
