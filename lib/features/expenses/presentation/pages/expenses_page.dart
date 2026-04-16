import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../app/router/app_router.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/expense_entity.dart';
import '../bloc/expenses_bloc.dart';

class ExpensesPage extends StatelessWidget {
  final String carId;

  const ExpensesPage({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExpensesBloc>()..add(ExpensesLoadRequested(carId)),
      child: _ExpensesView(carId: carId),
    );
  }
}

class _ExpensesView extends StatefulWidget {
  final String carId;

  const _ExpensesView({required this.carId});

  @override
  State<_ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<_ExpensesView> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  String get carId => widget.carId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Расходы и статистика'),
            Expanded(
              child: BlocBuilder<ExpensesBloc, ExpensesState>(
                builder: (context, state) {
                  if (state is ExpensesLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is ExpensesError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48.sp, color: AppColors.error),
                            SizedBox(height: 12.h),
                            Text(
                              state.message,
                              style: TextStyle(
                                  fontSize: 14.sp, color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ExpensesLoaded) {
                    if (state.expenses.isEmpty) {
                      return _buildEmpty(context);
                    }
                    return _buildContent(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
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
              'Расходов пока нет',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Добавьте первый расход,\nчтобы начать вести статистику',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 41.h,
              child: ElevatedButton(
                onPressed: () => context.push(
                  AppRoutes.addExpense.replaceAll(':carId', carId),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Добавить расход',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExpensesLoaded state) {
    final numberFormat = NumberFormat('#,###', 'ru_RU');

    final filtered = state.expenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .toList();
    final monthTotal = filtered.fold(0.0, (sum, e) => sum + e.amount);

    final byCategory = <ExpenseCategory, double>{};
    for (final e in filtered) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _buildPeriodSelector(),
              SizedBox(height: 16.h),
              _buildTotalCard(
                  monthTotal, filtered.length, state.totalAmount, numberFormat),
              if (byCategory.isNotEmpty) ...[
                SizedBox(height: 20.h),
                _buildCategoryBreakdown(byCategory, monthTotal, numberFormat),
              ],
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 41.h,
                child: ElevatedButton(
                  onPressed: () => context.push(
                    AppRoutes.addExpense.replaceAll(':carId', carId),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Добавить расход',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
        Expanded(
          child: _buildFullHistory(context, state, numberFormat),
        ),
      ],
    );
  }

  Widget _buildFullHistory(
    BuildContext context,
    ExpensesLoaded state,
    NumberFormat numberFormat,
  ) {
    final sorted = state.expenses.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final grouped = <String, List<ExpenseEntity>>{};
    for (final e in sorted) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final monthFormat = DateFormat('LLLL yyyy', 'ru');

    final items = <Widget>[];
    items.add(
      Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.h),
        child: Text(
          'История расходов',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
    );

    for (final key in sortedKeys) {
      final expenses = grouped[key]!;
      final monthTotal = expenses.fold(0.0, (sum, e) => sum + e.amount);
      final label = monthFormat.format(expenses.first.date);
      final capitalizedLabel = label[0].toUpperCase() + label.substring(1);

      items.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  capitalizedLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${numberFormat.format(monthTotal.toInt())} ₽',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      items.add(SizedBox(height: 8.h));

      for (final expense in expenses) {
        items.add(
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 8.h),
            child: _buildExpenseItem(context, expense, numberFormat),
          ),
        );
      }
      items.add(SizedBox(height: 8.h));
    }

    items.add(SizedBox(height: 32.h));

    return ListView(
      padding: EdgeInsets.zero,
      children: items,
    );
  }

  Widget _buildPeriodSelector() {
    final monthFormat = DateFormat('LLLL yyyy', 'ru');
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    final label = monthFormat.format(_selectedMonth);
    final capitalizedLabel = label[0].toUpperCase() + label.substring(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _selectedMonth = DateTime(
              _selectedMonth.year,
              _selectedMonth.month - 1,
            );
          }),
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
          onTap: () => setState(() {
            _selectedMonth = DateTime(now.year, now.month);
          }),
          child: Text(
            capitalizedLabel,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
        GestureDetector(
          onTap: isCurrentMonth
              ? null
              : () => setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  }),
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
              color: isCurrentMonth
                  ? AppColors.divider
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(
    double monthTotal,
    int monthCount,
    double allTimeTotal,
    NumberFormat numberFormat,
  ) {
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
            'Расходы за месяц',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${numberFormat.format(monthTotal.toInt())} ₽',
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
                '$monthCount ${_pluralExpenses(monthCount)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              Text(
                'Всего: ${numberFormat.format(allTimeTotal.toInt())} ₽',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    Map<ExpenseCategory, double> byCategory,
    double total,
    NumberFormat numberFormat,
  ) {
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'По категориям',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 12.h),
        ...sorted.map((entry) {
          final percent = total > 0 ? (entry.value / total * 100) : 0.0;
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _buildCategoryRow(
              entry.key,
              entry.value,
              percent,
              numberFormat,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryRow(
    ExpenseCategory category,
    double amount,
    double percent,
    NumberFormat numberFormat,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            _categoryIcon(category),
            size: 20.sp,
            color: AppColors.textSecondaryLight,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
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
                '${numberFormat.format(amount.toInt())} ₽',
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
    );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    ExpenseEntity expense,
    NumberFormat numberFormat,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 24.sp),
      ),
      confirmDismiss: (_) => _confirmDelete(context, expense),
      onDismissed: (_) {
        context.read<ExpensesBloc>().add(ExpensesDeleteRequested(expense.id));
      },
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
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(expense.date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      if (expense.note != null && expense.note!.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            expense.note!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${numberFormat.format(expense.amount.toInt())} ₽',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context, ExpenseEntity expense) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Удалить расход?',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            content: Text(
              '${expense.category.label} — ${expense.formattedAmount}',
              style: TextStyle(
                  fontSize: 14.sp, color: AppColors.textSecondaryLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Удалить',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
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
