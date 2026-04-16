import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/document_model.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentModel>> getDocuments(String carId);
  Future<DocumentModel> addDocument(DocumentModel document);
  Future<void> deleteDocument(String documentId);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final FirebaseFirestore _firestore;

  DocumentRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _documentsCollection =>
      _firestore.collection(FirestoreCollections.documents);

  @override
  Future<List<DocumentModel>> getDocuments(String carId) async {
    try {
      final snapshot =
          await _documentsCollection.where('carId', isEqualTo: carId).get();

      final docs = snapshot.docs
          .map((doc) => DocumentModel.fromJson(doc.data()))
          .toList();

      docs.sort((a, b) => a.type.index.compareTo(b.type.index));
      return docs;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<DocumentModel> addDocument(DocumentModel document) async {
    try {
      final docRef = _documentsCollection.doc(document.id);
      await docRef.set(document.toJson());
      return document;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _documentsCollection.doc(documentId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
