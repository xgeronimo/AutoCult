import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final ReminderRepository repository;
  final NotificationService notificationService;

  NotificationsBloc({
    required this.repository,
    required this.notificationService,
  }) : super(const NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationsCreateRequested>(_onCreate);
    on<NotificationsMarkAsReadRequested>(_onMarkAsRead);
    on<NotificationsDeleteRequested>(_onDelete);
    on<NotificationsMarkAllAsReadRequested>(_onMarkAllAsRead);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());

    final result = await repository.getReminders(event.userId);

    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (reminders) => emit(NotificationsLoaded(reminders: reminders)),
    );
  }

  Future<void> _onCreate(
    NotificationsCreateRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    emit(const NotificationsLoading());

    final reminder = ReminderEntity(
      id: const Uuid().v4(),
      userId: event.userId,
      title: event.title,
      body: event.body,
      scheduledAt: event.scheduledAt,
      createdAt: DateTime.now(),
      isRead: false,
      type: event.type,
      carId: event.carId,
    );

    final result = await repository.createReminder(reminder);

    result.fold(
      (failure) {
        emit(NotificationsError(failure.message));
        if (currentState is NotificationsLoaded) emit(currentState);
      },
      (created) {
        if (created.scheduledAt.isAfter(DateTime.now())) {
          notificationService.scheduleNotification(
            id: created.id,
            title: created.title,
            body: created.body ?? '',
            scheduledAt: created.scheduledAt,
          );
        }

        emit(NotificationsCreateSuccess(created));

        if (currentState is NotificationsLoaded) {
          final updated = [created, ...currentState.reminders];
          updated.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          emit(NotificationsLoaded(reminders: updated));
        } else {
          emit(NotificationsLoaded(reminders: [created]));
        }
      },
    );
  }

  Future<void> _onMarkAsRead(
    NotificationsMarkAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final updatedReminders = currentState.reminders.map((r) {
      if (r.id == event.reminderId) return r.copyWith(isRead: true);
      return r;
    }).toList();
    emit(NotificationsLoaded(reminders: updatedReminders));

    final result = await repository.markAsRead(event.reminderId);

    result.fold(
      (failure) {
        emit(NotificationsError(failure.message));
        emit(currentState);
      },
      (_) {},
    );
  }

  Future<void> _onMarkAllAsRead(
    NotificationsMarkAllAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final unread = currentState.reminders.where((r) => !r.isRead).toList();
    if (unread.isEmpty) return;

    final updatedReminders =
        currentState.reminders.map((r) => r.copyWith(isRead: true)).toList();
    emit(NotificationsLoaded(reminders: updatedReminders));

    for (final reminder in unread) {
      await repository.markAsRead(reminder.id);
    }
  }

  Future<void> _onDelete(
    NotificationsDeleteRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    notificationService.cancelNotification(event.reminderId);

    final optimistic =
        currentState.reminders.where((r) => r.id != event.reminderId).toList();
    emit(NotificationsLoaded(reminders: optimistic));

    final result = await repository.deleteReminder(event.reminderId);

    result.fold(
      (failure) {
        emit(NotificationsError(failure.message));
        emit(currentState);
      },
      (_) {},
    );
  }
}
