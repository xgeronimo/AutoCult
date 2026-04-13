import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/personal_document_model.dart';

abstract class PersonalDocumentRemoteDataSource {
  Future<List<PersonalDocumentModel>> getDocuments(String userId);
  Future<PersonalDocumentModel> addDocument(PersonalDocumentModel document);
  Future<void> deleteDocument(String documentId);
}

class PersonalDocumentRemoteDataSourceImpl implements PersonalDocumentRemoteDataSource {
  final FirebaseFirestore _firestore;

  PersonalDocumentRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.personalDocuments);

  @override
  Future<List<PersonalDocumentModel>> getDocuments(String userId) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();

      final docs = snapshot.docs
          .map((doc) => PersonalDocumentModel.fromJson(doc.data()))
          .toList();

      docs.sort((a, b) => a.type.index.compareTo(b.type.index));
      return docs;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PersonalDocumentModel> addDocument(PersonalDocumentModel document) async {
    try {
      final docRef = _collection.doc(document.id);
      await docRef.set(document.toJson());
      return document;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _collection.doc(documentId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
