import 'package:intl/intl.dart';

import '../entities/service_record_entity.dart';

class MileageConsistencyValidator {
  const MileageConsistencyValidator._();

  /// Проверяет, что пробег новой/изменяемой записи не нарушает хронологию:
  /// записи с более ранней датой не должны иметь пробег больше, чем записи
  /// с более поздней датой (пробег с течением времени не уменьшается).
  ///
  /// Возвращает `null`, если конфликтов нет, иначе — сообщение об ошибке.
  static String? validate({
    required DateTime date,
    required int mileage,
    required List<ServiceRecordEntity> existingRecords,
    String? excludeRecordId,
  }) {
    final selectedDay = DateTime(date.year, date.month, date.day);

    ServiceRecordEntity? previousConflict;
    ServiceRecordEntity? nextConflict;

    for (final record in existingRecords) {
      if (excludeRecordId != null && record.id == excludeRecordId) continue;

      final recordDay =
          DateTime(record.date.year, record.date.month, record.date.day);

      if (recordDay.isBefore(selectedDay)) {
        if (record.mileage > mileage) {
          if (previousConflict == null ||
              record.mileage > previousConflict.mileage) {
            previousConflict = record;
          }
        }
      } else if (recordDay.isAfter(selectedDay)) {
        if (record.mileage < mileage) {
          if (nextConflict == null ||
              record.mileage < nextConflict.mileage) {
            nextConflict = record;
          }
        }
      }
    }

    final dateFormat = DateFormat('dd.MM.yyyy');

    if (previousConflict != null) {
      return 'Пробег не может быть меньше, чем в записи от '
          '${dateFormat.format(previousConflict.date)} '
          '(${previousConflict.mileage} км)';
    }

    if (nextConflict != null) {
      return 'Пробег не может быть больше, чем в записи от '
          '${dateFormat.format(nextConflict.date)} '
          '(${nextConflict.mileage} км)';
    }

    return null;
  }
}
