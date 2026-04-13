import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../garage/domain/entities/car_entity.dart';
import '../../../service_records/domain/entities/service_record_entity.dart';
import '../../../service_records/domain/repositories/service_record_repository.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final ExpenseRepository expenseRepository;
  final ServiceRecordRepository serviceRecordRepository;

  List<ExpenseEntity> _cachedExpenses = [];
  List<ServiceRecordEntity> _cachedServiceRecords = [];
  List<CarEntity> _cachedCars = [];

  StatisticsBloc({
    required this.expenseRepository,
    required this.serviceRecordRepository,
  }) : super(const StatisticsInitial()) {
    on<StatisticsLoadRequested>(_onLoad);
    on<StatisticsPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onLoad(
    StatisticsLoadRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final expensesResult =
        await expenseRepository.getExpensesByUserId(event.userId);
    final serviceRecordsResult =
        await serviceRecordRepository.getRecordsByUserId(event.userId);

    expensesResult.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (expenses) {
        _cachedExpenses = expenses;
        _cachedCars = event.cars;

        serviceRecordsResult.fold(
          (_) => _cachedServiceRecords = [],
          (records) => _cachedServiceRecords = records,
        );

        emit(StatisticsLoaded(
          allExpenses: expenses,
          allServiceRecords: _cachedServiceRecords,
          cars: event.cars,
          selectedMonth: DateTime.now(),
        ));
      },
    );
  }

  void _onPeriodChanged(
    StatisticsPeriodChanged event,
    Emitter<StatisticsState> emit,
  ) {
    if (state is StatisticsLoaded) {
      emit(StatisticsLoaded(
        allExpenses: _cachedExpenses,
        allServiceRecords: _cachedServiceRecords,
        cars: _cachedCars,
        selectedMonth: event.month,
      ));
    }
  }
}
