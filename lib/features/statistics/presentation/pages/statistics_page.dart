import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../garage/presentation/bloc/garage_bloc.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../bloc/statistics_bloc.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/car_expenses_list.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    final authState = context.read<AuthBloc>().state;
    final garageState = context.read<GarageBloc>().state;

    if (authState is AuthAuthenticated && garageState is GarageLoaded) {
      context.read<StatisticsBloc>().add(StatisticsLoadRequested(
            userId: authState.user.id,
            cars: garageState.cars,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, state) {
                if (state is StatisticsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is StatisticsError) {
                  return _buildError(state.message);
                }

                if (state is StatisticsLoaded) {
                  if (state.allExpenses.isEmpty &&
                      state.allServiceRecords.isEmpty) {
                    return _buildEmpty();
                  }
                  return _buildContent(state);
                }

                return _buildEmpty();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
      child: Row(
        children: [
          Text(
            'Статистика',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const Spacer(),
          BlocBuilder<StatisticsBloc, StatisticsState>(
            builder: (context, state) {
              if (state is StatisticsLoaded) {
                return GestureDetector(
                  onTap: _loadStatistics,
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 24.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 64.sp,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              'Нет данных для отображения',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Добавьте расходы или записи обслуживания,\nчтобы увидеть статистику',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadStatistics,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(StatisticsLoaded state) {
    final numberFormat = NumberFormat('#,###', 'ru_RU');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildPeriodSelector(state),
          SizedBox(height: 16.h),
          _buildTotalCard(state, numberFormat),
          SizedBox(height: 16.h),
          if (state.amountByCategory.isNotEmpty) ...[
            CategoryPieChart(
              amountByCategory: state.amountByCategory,
              totalAmount: state.totalAmount,
            ),
            SizedBox(height: 16.h),
          ],
          _buildCategoryDetails(state, numberFormat),
          SizedBox(height: 16.h),
          if (state.serviceAmountByCategory.isNotEmpty) ...[
            _buildServiceCategoryDetails(state, numberFormat),
            SizedBox(height: 16.h),
          ],
          MonthlyBarChart(
            amountByMonth: state.amountByMonth,
            selectedMonth: state.selectedMonth.month,
          ),
          SizedBox(height: 16.h),
          if (state.cars.length > 1 && state.amountByCar.isNotEmpty) ...[
            CarExpensesList(
              amountByCar: state.amountByCar,
              cars: state.cars,
              totalAmount: state.grandTotal,
            ),
            SizedBox(height: 16.h),
          ],
          _buildRecentExpenses(state, numberFormat),
          SizedBox(height: LiquidGlassNavBar.totalHeight(context) + 16.h),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(StatisticsLoaded state) {
    final monthFormat = DateFormat('LLLL yyyy', 'ru');
    final now = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            final prev = DateTime(
              state.selectedMonth.year,
              state.selectedMonth.month - 1,
            );
            context.read<StatisticsBloc>().add(StatisticsPeriodChanged(prev));
          },
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              size: 24.sp,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            context.read<StatisticsBloc>().add(
                  StatisticsPeriodChanged(DateTime(now.year, now.month)),
                );
          },
          child: Text(
            _capitalize(monthFormat.format(state.selectedMonth)),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            final next = DateTime(
              state.selectedMonth.year,
              state.selectedMonth.month + 1,
            );
            if (!next.isAfter(DateTime(now.year, now.month + 1))) {
              context.read<StatisticsBloc>().add(StatisticsPeriodChanged(next));
            }
          },
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 24.sp,
              color: state.selectedMonth.year == now.year &&
                      state.selectedMonth.month == now.month
                  ? AppColors.divider
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(StatisticsLoaded state, NumberFormat numberFormat) {
    final count =
        state.filteredExpenses.length + state.filteredServiceRecords.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Все расходы за месяц',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${numberFormat.format(state.grandTotal.toInt())} ₽',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count ${_pluralExpenses(count)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              Text(
                'Всего: ${numberFormat.format(state.grandTotalAllTime.toInt())} ₽',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          if (state.serviceRecordsTotalAmount > 0) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.build_rounded,
                    size: 16.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Обслуживание',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  Text(
                    '${numberFormat.format(state.serviceRecordsTotalAmount.toInt())} ₽',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryDetails(
      StatisticsLoaded state, NumberFormat numberFormat) {
    final byCategory = state.amountByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();

    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sorted.map((entry) {
        final percent = state.totalAmount > 0
            ? (entry.value / state.totalAmount * 100)
            : 0.0;
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  _categoryIcon(entry.key),
                  size: 20.sp,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: AppColors.divider,
                          color: AppColors.primary,
                          minHeight: 4.h,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${numberFormat.format(entry.value.toInt())} ₽',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceCategoryDetails(
      StatisticsLoaded state, NumberFormat numberFormat) {
    final byCategory = state.serviceAmountByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();

    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Обслуживание',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 12.h),
        ...sorted.map((entry) {
          final percent = state.serviceRecordsTotalAmount > 0
              ? (entry.value / state.serviceRecordsTotalAmount * 100)
              : 0.0;
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    entry.key.icon,
                    size: 20.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2.r),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: AppColors.divider,
                            color: AppColors.primary,
                            minHeight: 4.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${numberFormat.format(entry.value.toInt())} ₽',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentExpenses(
      StatisticsLoaded state, NumberFormat numberFormat) {
    final expenses = state.filteredExpenses;
    if (expenses.isEmpty) return const SizedBox.shrink();

    final dateFormat = DateFormat('dd.MM.yyyy');
    final displayExpenses = expenses.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Последние расходы',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 12.h),
        ...displayExpenses.map((expense) {
          final carName = state.carName(expense.carId);
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Icon(
                        _categoryIcon(expense.category),
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.category.label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$carName · ${dateFormat.format(expense.date)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${numberFormat.format(expense.amount.toInt())} ₽',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  IconData _categoryIcon(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.fuel => Icons.local_gas_station_rounded,
      ExpenseCategory.parking => Icons.local_parking_rounded,
      ExpenseCategory.fines => Icons.traffic_rounded,
      ExpenseCategory.tollRoad => Icons.toll_rounded,
      ExpenseCategory.wash => Icons.water_drop_rounded,
      ExpenseCategory.carCare => Icons.cleaning_services_rounded,
      ExpenseCategory.accessories => Icons.build_rounded,
      ExpenseCategory.taxes => Icons.account_balance_rounded,
      ExpenseCategory.insurance => Icons.description_rounded,
      ExpenseCategory.other => Icons.edit_note_rounded,
    };
  }

  String _pluralExpenses(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'запись';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'записи';
    }
    return 'записей';
  }
}
