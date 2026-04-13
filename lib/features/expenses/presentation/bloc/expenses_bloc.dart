import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';

part 'expenses_event.dart';
part 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final ExpenseRepository repository;

  ExpensesBloc({required this.repository}) : super(const ExpensesInitial()) {
    on<ExpensesLoadRequested>(_onLoad);
    on<ExpensesAddRequested>(_onAdd);
    on<ExpensesDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    ExpensesLoadRequested event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(const ExpensesLoading());

    final result = await repository.getExpenses(event.carId);

    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (expenses) => emit(ExpensesLoaded(
        expenses: expenses,
        carId: event.carId,
      )),
    );
  }

  Future<void> _onAdd(
    ExpensesAddRequested event,
    Emitter<ExpensesState> emit,
  ) async {
    final currentState = state;
    emit(const ExpensesLoading());

    final expense = ExpenseEntity(
      id: const Uuid().v4(),
      carId: event.carId,
      userId: event.userId,
      category: event.category,
      amount: event.amount,
      date: event.date,
      note: event.note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await repository.addExpense(expense);

    result.fold(
      (failure) {
        emit(ExpensesError(failure.message));
        if (currentState is ExpensesLoaded) emit(currentState);
      },
      (addedExpense) {
        emit(ExpensesAddSuccess(addedExpense));
        if (currentState is ExpensesLoaded) {
          emit(ExpensesLoaded(
            expenses: [addedExpense, ...currentState.expenses],
            carId: currentState.carId,
          ));
        } else {
          emit(ExpensesLoaded(
            expenses: [addedExpense],
            carId: event.carId,
          ));
        }
      },
    );
  }

  Future<void> _onDelete(
    ExpensesDeleteRequested event,
    Emitter<ExpensesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ExpensesLoaded) return;

    emit(const ExpensesLoading());

    final result = await repository.deleteExpense(event.expenseId);

    result.fold(
      (failure) {
        emit(ExpensesError(failure.message));
        emit(currentState);
      },
      (_) {
        final updated = currentState.expenses
            .where((e) => e.id != event.expenseId)
            .toList();
        emit(ExpensesLoaded(
          expenses: updated,
          carId: currentState.carId,
        ));
      },
    );
  }
}
