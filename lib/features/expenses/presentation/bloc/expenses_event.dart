part of 'expenses_bloc.dart';

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

class ExpensesLoadRequested extends ExpensesEvent {
  final String carId;

  const ExpensesLoadRequested(this.carId);

  @override
  List<Object?> get props => [carId];
}

class ExpensesAddRequested extends ExpensesEvent {
  final String carId;
  final String userId;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String? note;

  const ExpensesAddRequested({
    required this.carId,
    required this.userId,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [carId, userId, category, amount, date, note];
}

class ExpensesDeleteRequested extends ExpensesEvent {
  final String expenseId;

  const ExpensesDeleteRequested(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}
