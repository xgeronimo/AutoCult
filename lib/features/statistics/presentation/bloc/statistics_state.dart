part of 'statistics_bloc.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final List<ExpenseEntity> allExpenses;
  final List<ServiceRecordEntity> allServiceRecords;
  final List<CarEntity> cars;
  final DateTime selectedMonth;

  const StatisticsLoaded({
    required this.allExpenses,
    this.allServiceRecords = const [],
    required this.cars,
    required this.selectedMonth,
  });

  List<ExpenseEntity> get filteredExpenses {
    return allExpenses.where((e) {
      return e.date.year == selectedMonth.year &&
          e.date.month == selectedMonth.month;
    }).toList();
  }

  List<ServiceRecordEntity> get filteredServiceRecords {
    return allServiceRecords.where((r) {
      return r.date.year == selectedMonth.year &&
          r.date.month == selectedMonth.month;
    }).toList();
  }

  double get totalAmount =>
      filteredExpenses.fold(0, (sum, e) => sum + e.amount);

  double get totalAllTime => allExpenses.fold(0, (sum, e) => sum + e.amount);

  double get serviceRecordsTotalAmount => filteredServiceRecords.fold(
      0.0, (sum, r) => sum + (r.cost ?? 0));

  double get serviceRecordsTotalAllTime =>
      allServiceRecords.fold(0.0, (sum, r) => sum + (r.cost ?? 0));

  double get grandTotal => totalAmount + serviceRecordsTotalAmount;

  double get grandTotalAllTime => totalAllTime + serviceRecordsTotalAllTime;

  Map<ExpenseCategory, double> get amountByCategory {
    final map = <ExpenseCategory, double>{};
    for (final expense in filteredExpenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  Map<ServiceCategory, double> get serviceAmountByCategory {
    final map = <ServiceCategory, double>{};
    for (final record in filteredServiceRecords) {
      if (record.cost != null && record.cost! > 0) {
        map[record.category] =
            (map[record.category] ?? 0) + record.cost!;
      }
    }
    return map;
  }

  Map<String, double> get amountByCar {
    final map = <String, double>{};
    for (final expense in filteredExpenses) {
      map[expense.carId] = (map[expense.carId] ?? 0) + expense.amount;
    }
    for (final record in filteredServiceRecords) {
      if (record.cost != null && record.cost! > 0) {
        map[record.carId] = (map[record.carId] ?? 0) + record.cost!;
      }
    }
    return map;
  }

  Map<int, double> get amountByMonth {
    final map = <int, double>{};
    for (final expense in allExpenses) {
      if (expense.date.year == selectedMonth.year) {
        map[expense.date.month] =
            (map[expense.date.month] ?? 0) + expense.amount;
      }
    }
    for (final record in allServiceRecords) {
      if (record.date.year == selectedMonth.year &&
          record.cost != null &&
          record.cost! > 0) {
        map[record.date.month] =
            (map[record.date.month] ?? 0) + record.cost!;
      }
    }
    return map;
  }

  String carName(String carId) {
    final car = cars.where((c) => c.id == carId).firstOrNull;
    return car?.fullName ?? 'Неизвестный';
  }

  @override
  List<Object?> get props =>
      [allExpenses, allServiceRecords, cars, selectedMonth];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
