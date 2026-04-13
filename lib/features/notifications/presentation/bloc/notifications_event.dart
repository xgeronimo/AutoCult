part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationsEvent {
  final String userId;

  const NotificationsLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class NotificationsCreateRequested extends NotificationsEvent {
  final String userId;
  final String title;
  final String? body;
  final DateTime scheduledAt;
  final ReminderType type;
  final String? carId;

  const NotificationsCreateRequested({
    required this.userId,
    required this.title,
    this.body,
    required this.scheduledAt,
    this.type = ReminderType.custom,
    this.carId,
  });

  @override
  List<Object?> get props => [userId, title, body, scheduledAt, type, carId];
}

class NotificationsMarkAsReadRequested extends NotificationsEvent {
  final String reminderId;

  const NotificationsMarkAsReadRequested(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class NotificationsMarkAllAsReadRequested extends NotificationsEvent {
  const NotificationsMarkAllAsReadRequested();
}

class NotificationsDeleteRequested extends NotificationsEvent {
  final String reminderId;

  const NotificationsDeleteRequested(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}
