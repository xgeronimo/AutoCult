import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  fuel('Топливо', 'fuel'),
  parking('Парковка', 'parking'),
  fines('Штрафы', 'fines'),
  tollRoad('Платная дорога', 'toll_road'),
  wash('Мойка', 'wash'),
  carCare('Средства ухода', 'car_care'),
  accessories('Аксессуары', 'accessories'),
  taxes('Налоги', 'taxes'),
  insurance('Страховка', 'insurance'),
  other('Другое', 'other');

  final String label;
  final String iconKey;
  const ExpenseCategory(this.label, this.iconKey);
}

class ExpenseEntity extends Equatable {
  final String id;
  final String carId;
  final String userId;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.carId,
    required this.userId,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedAmount => '${amount.toStringAsFixed(0)} руб.';

  @override
  List<Object?> get props => [
        id,
        carId,
        userId,
        category,
        amount,
        date,
        note,
        createdAt,
        updatedAt,
      ];
}
