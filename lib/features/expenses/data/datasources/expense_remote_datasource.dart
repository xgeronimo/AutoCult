import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(String carId);
  Future<List<ExpenseModel>> getExpensesByUserId(String userId);
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpenseRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection(FirestoreCollections.expenses);

  @override
  Future<List<ExpenseModel>> getExpenses(String carId) async {
    try {
      final snapshot =
          await _expensesCollection.where('carId', isEqualTo: carId).get();

      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();

      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByUserId(String userId) async {
    try {
      final snapshot =
          await _expensesCollection.where('userId', isEqualTo: userId).get();

      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();

      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      final docRef = _expensesCollection.doc(expense.id);
      await docRef.set(expense.toJson());
      return expense;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expensesCollection.doc(expenseId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
