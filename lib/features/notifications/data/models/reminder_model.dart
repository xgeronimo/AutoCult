import '../../domain/entities/reminder_entity.dart';

class ReminderModel extends ReminderEntity {
  const ReminderModel({
    required super.id,
    required super.userId,
    required super.title,
    super.body,
    required super.scheduledAt,
    required super.createdAt,
    required super.isRead,
    required super.type,
    super.carId,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: ReminderType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ReminderType.custom,
      ),
      carId: json['carId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'scheduledAt': scheduledAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'carId': carId,
    };
  }

  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      body: entity.body,
      scheduledAt: entity.scheduledAt,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
      type: entity.type,
      carId: entity.carId,
    );
  }
}
