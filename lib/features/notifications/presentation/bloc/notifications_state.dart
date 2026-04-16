part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<ReminderEntity> reminders;

  const NotificationsLoaded({required this.reminders});

  List<ReminderEntity> get active => reminders.where((r) => !r.isRead).toList();

  List<ReminderEntity> get overdueUnread {
    final list = active.where((r) => r.isPast).toList();
    list.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return list;
  }

  List<ReminderEntity> get upcomingUnread {
    final list = active.where((r) => r.isUpcoming).toList();
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  List<ReminderEntity> get readReminders {
    final list = reminders.where((r) => r.isRead).toList();
    list.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return list;
  }

  int get unreadCount => active.length;

  @override
  List<Object?> get props => [reminders];
}

class NotificationsCreateSuccess extends NotificationsState {
  final ReminderEntity reminder;

  const NotificationsCreateSuccess(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
