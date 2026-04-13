part of 'statistics_bloc.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class StatisticsLoadRequested extends StatisticsEvent {
  final String userId;
  final List<CarEntity> cars;

  const StatisticsLoadRequested({
    required this.userId,
    required this.cars,
  });

  @override
  List<Object?> get props => [userId, cars];
}

class StatisticsPeriodChanged extends StatisticsEvent {
  final DateTime month;

  const StatisticsPeriodChanged(this.month);

  @override
  List<Object?> get props => [month];
}
