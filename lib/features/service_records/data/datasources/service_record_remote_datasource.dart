import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/service_record_entity.dart';
import '../models/service_record_model.dart';

abstract class ServiceRecordRemoteDataSource {
  Future<List<ServiceRecordModel>> getRecords(String carId);
  Future<List<ServiceRecordModel>> getRecordsByUserId(String userId);
  Future<ServiceRecordModel> getRecordById(String recordId);
  Future<ServiceRecordModel> addRecord(ServiceRecordModel record);
  Future<ServiceRecordModel> updateRecord(ServiceRecordModel record);
  Future<void> deleteRecord(String recordId);
  Future<List<ServiceRecordModel>> getRecordsByCategory(
      String carId, ServiceCategory category);
  Future<List<ServiceRecordModel>> getRecentRecords(String userId,
      {int limit = 10});
  Stream<List<ServiceRecordModel>> watchRecords(String carId);
}

class ServiceRecordRemoteDataSourceImpl
    implements ServiceRecordRemoteDataSource {
  final FirebaseFirestore _firestore;

  ServiceRecordRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _recordsCollection =>
      _firestore.collection(FirestoreCollections.serviceRecords);

  @override
  Future<List<ServiceRecordModel>> getRecords(String carId) async {
    try {
      final snapshot =
          await _recordsCollection.where('carId', isEqualTo: carId).get();

      final records = snapshot.docs
          .map((doc) => ServiceRecordModel.fromJson(doc.data()))
          .toList();

      records.sort((a, b) => b.date.compareTo(a.date));

      return records;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ServiceRecordModel>> getRecordsByUserId(String userId) async {
    try {
      final snapshot =
          await _recordsCollection.where('userId', isEqualTo: userId).get();

      final records = snapshot.docs
          .map((doc) => ServiceRecordModel.fromJson(doc.data()))
          .toList();

      records.sort((a, b) => b.date.compareTo(a.date));

      return records;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ServiceRecordModel> getRecordById(String recordId) async {
    try {
      final doc = await _recordsCollection.doc(recordId).get();

      if (!doc.exists || doc.data() == null) {
        throw const ServerException(message: 'Запись не найдена');
      }

      return ServiceRecordModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ServiceRecordModel> addRecord(ServiceRecordModel record) async {
    try {
      final docRef = _recordsCollection.doc(record.id);
      await docRef.set(record.toJson());
      return record;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ServiceRecordModel> updateRecord(ServiceRecordModel record) async {
    try {
      await _recordsCollection.doc(record.id).update(record.toJson());
      return record;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteRecord(String recordId) async {
    try {
      await _recordsCollection.doc(recordId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ServiceRecordModel>> getRecordsByCategory(
    String carId,
    ServiceCategory category,
  ) async {
    try {
      final snapshot = await _recordsCollection
          .where('carId', isEqualTo: carId)
          .where('category', isEqualTo: category.name)
          .get();

      final records = snapshot.docs
          .map((doc) => ServiceRecordModel.fromJson(doc.data()))
          .toList();

      records.sort((a, b) => b.date.compareTo(a.date));

      return records;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ServiceRecordModel>> getRecentRecords(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final snapshot =
          await _recordsCollection.where('userId', isEqualTo: userId).get();

      final records = snapshot.docs
          .map((doc) => ServiceRecordModel.fromJson(doc.data()))
          .toList();

      records.sort((a, b) => b.date.compareTo(a.date));

      return records.take(limit).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<ServiceRecordModel>> watchRecords(String carId) {
    return _recordsCollection
        .where('carId', isEqualTo: carId)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => ServiceRecordModel.fromJson(doc.data()))
          .toList();

      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    });
  }
}
