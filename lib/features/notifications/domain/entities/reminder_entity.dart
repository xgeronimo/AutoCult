import 'package:equatable/equatable.dart';

enum ReminderType {
  custom('Пользовательское', 'custom'),
  service('Техобслуживание', 'service'),
  insurance('Страховка', 'insurance'),
  inspection('Техосмотр', 'inspection');

  final String label;
  final String value;
  const ReminderType(this.label, this.value);
}

class ReminderEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? body;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final bool isRead;
  final ReminderType type;
  final String? carId;

  const ReminderEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.body,
    required this.scheduledAt,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.carId,
  });

  bool get isPast => scheduledAt.isBefore(DateTime.now());
  bool get isUpcoming => !isPast;

  ReminderEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    DateTime? scheduledAt,
    DateTime? createdAt,
    bool? isRead,
    ReminderType? type,
    String? carId,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      carId: carId ?? this.carId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        scheduledAt,
        createdAt,
        isRead,
        type,
        carId,
      ];
}
