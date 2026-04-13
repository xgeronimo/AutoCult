part of 'expenses_bloc.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object?> get props => [];
}

class ExpensesInitial extends ExpensesState {
  const ExpensesInitial();
}

class ExpensesLoading extends ExpensesState {
  const ExpensesLoading();
}

class ExpensesLoaded extends ExpensesState {
  final List<ExpenseEntity> expenses;
  final String carId;

  const ExpensesLoaded({
    required this.expenses,
    required this.carId,
  });

  double get totalAmount => expenses.fold(0, (sum, e) => sum + e.amount);

  Map<ExpenseCategory, double> get amountByCategory {
    final map = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  @override
  List<Object?> get props => [expenses, carId];
}

class ExpensesAddSuccess extends ExpensesState {
  final ExpenseEntity expense;

  const ExpensesAddSuccess(this.expense);

  @override
  List<Object?> get props => [expense];
}

class ExpensesError extends ExpensesState {
  final String message;

  const ExpensesError(this.message);

  @override
  List<Object?> get props => [message];
}
