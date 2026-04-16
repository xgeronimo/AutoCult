import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/car_model.dart';

abstract class CarRemoteDataSource {
  Future<List<CarModel>> getCars(String userId);

  Future<CarModel> getCarById(String carId);

  Future<CarModel> addCar(CarModel car);

  Future<CarModel> updateCar(CarModel car);

  Future<void> deleteCar(String carId);

  Future<CarModel> updateMileage(String carId, int mileage);

  Stream<List<CarModel>> watchCars(String userId);
}

class CarRemoteDataSourceImpl implements CarRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CarRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference<Map<String, dynamic>> get _carsCollection =>
      _firestore.collection(FirestoreCollections.cars);

  @override
  Future<List<CarModel>> getCars(String userId) async {
    try {
      final snapshot =
          await _carsCollection.where('userId', isEqualTo: userId).get();

      final cars =
          snapshot.docs.map((doc) => CarModel.fromJson(doc.data())).toList();

      cars.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return cars;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CarModel> getCarById(String carId) async {
    try {
      final doc = await _carsCollection.doc(carId).get();

      if (!doc.exists || doc.data() == null) {
        throw const ServerException(message: 'Автомобиль не найден');
      }

      return CarModel.fromJson(doc.data()!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CarModel> addCar(CarModel car) async {
    try {
      final docRef = _carsCollection.doc(car.id);
      await docRef.set(car.toJson());
      return car;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CarModel> updateCar(CarModel car) async {
    try {
      await _carsCollection.doc(car.id).update(car.toJson());
      return car;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteCar(String carId) async {
    try {
      final photoUrlsToDelete = <String>[];

      final carDoc = await _carsCollection.doc(carId).get();
      if (carDoc.exists) {
        final carPhotoUrl = carDoc.data()?['photoUrl'] as String?;
        if (carPhotoUrl != null && carPhotoUrl.isNotEmpty) {
          photoUrlsToDelete.add(carPhotoUrl);
        }
      }

      final serviceRecords = await _firestore
          .collection(FirestoreCollections.serviceRecords)
          .where('carId', isEqualTo: carId)
          .get();
      for (final doc in serviceRecords.docs) {
        final urls = (doc.data()['photoUrls'] as List<dynamic>?)
            ?.map((e) => e as String)
            .where((url) => url.isNotEmpty)
            .toList();
        if (urls != null) {
          photoUrlsToDelete.addAll(urls);
        }
      }

      final documents = await _firestore
          .collection(FirestoreCollections.documents)
          .where('carId', isEqualTo: carId)
          .get();
      for (final doc in documents.docs) {
        final url = doc.data()['photoUrl'] as String?;
        if (url != null && url.isNotEmpty) {
          photoUrlsToDelete.add(url);
        }
      }

      final expenses = await _firestore
          .collection(FirestoreCollections.expenses)
          .where('carId', isEqualTo: carId)
          .get();

      final reminders = await _firestore
          .collection(FirestoreCollections.reminders)
          .where('carId', isEqualTo: carId)
          .get();

      final batch = _firestore.batch();
      for (final doc in serviceRecords.docs) {
        batch.delete(doc.reference);
      }
      for (final doc in documents.docs) {
        batch.delete(doc.reference);
      }
      for (final doc in expenses.docs) {
        batch.delete(doc.reference);
      }
      for (final doc in reminders.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_carsCollection.doc(carId));
      await batch.commit();

      for (final url in photoUrlsToDelete) {
        try {
          await _storage.refFromURL(url).delete();
        } on FirebaseException catch (_) {}
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CarModel> updateMileage(String carId, int mileage) async {
    try {
      await _carsCollection.doc(carId).update({
        'mileage': mileage,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return await getCarById(carId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<CarModel>> watchCars(String userId) {
    return _carsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final cars =
          snapshot.docs.map((doc) => CarModel.fromJson(doc.data())).toList();
      cars.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return cars;
    });
  }
}
