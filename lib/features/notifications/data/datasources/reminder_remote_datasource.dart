import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/reminder_model.dart';

abstract class ReminderRemoteDataSource {
  Future<List<ReminderModel>> getReminders(String userId);
  Future<ReminderModel> createReminder(ReminderModel reminder);
  Future<void> markAsRead(String reminderId);
  Future<void> deleteReminder(String reminderId);
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final FirebaseFirestore _firestore;

  ReminderRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.reminders);

  @override
  Future<List<ReminderModel>> getReminders(String userId) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();

      final reminders = snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();

      reminders.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      return reminders;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    try {
      await _collection.doc(reminder.id).set(reminder.toJson());
      return reminder;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(String reminderId) async {
    try {
      await _collection.doc(reminderId).update({'isRead': true});
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _collection.doc(reminderId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
