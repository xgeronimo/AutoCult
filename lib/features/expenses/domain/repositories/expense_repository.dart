import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(String carId);
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByUserId(
      String userId);
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
}
