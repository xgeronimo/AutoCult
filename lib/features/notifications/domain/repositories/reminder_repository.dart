import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reminder_entity.dart';

abstract class ReminderRepository {
  Future<Either<Failure, List<ReminderEntity>>> getReminders(String userId);
  Future<Either<Failure, ReminderEntity>> createReminder(ReminderEntity reminder);
  Future<Either<Failure, void>> markAsRead(String reminderId);
  Future<Either<Failure, void>> deleteReminder(String reminderId);
}
