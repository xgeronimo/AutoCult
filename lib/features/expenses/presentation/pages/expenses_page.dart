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

class _ExpensesView extends StatelessWidget {
  final String carId;

  const _ExpensesView({required this.carId});

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
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is ExpensesError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                            SizedBox(height: 12.h),
                            Text(
                              state.message,
                              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
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
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Общая сумма
          _buildTotalCard(state, numberFormat),
          SizedBox(height: 20.h),

          // По категориям
          _buildCategoryBreakdown(state, numberFormat),
          SizedBox(height: 20.h),

          // Кнопка добавить
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
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Список расходов
          Text(
            'История расходов',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.h),

          ...state.expenses.map(
            (expense) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _buildExpenseItem(context, expense, numberFormat),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildTotalCard(ExpensesLoaded state, NumberFormat numberFormat) {
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
            'Всего расходов',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${numberFormat.format(state.totalAmount.toInt())} ₽',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${state.expenses.length} ${_pluralExpenses(state.expenses.length)}',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ExpensesLoaded state, NumberFormat numberFormat) {
    final byCategory = state.amountByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();

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
          final percent = state.totalAmount > 0
              ? (entry.value / state.totalAmount * 100)
              : 0.0;
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
          Text(
            _categoryEmoji(category),
            style: TextStyle(fontSize: 20.sp),
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
                child: Text(
                  _categoryEmoji(expense.category),
                  style: TextStyle(fontSize: 18.sp),
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

  Future<bool> _confirmDelete(BuildContext context, ExpenseEntity expense) async {
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
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
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

  String _categoryEmoji(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.fuel => '⛽',
      ExpenseCategory.parking => '🅿️',
      ExpenseCategory.fines => '🚦',
      ExpenseCategory.tollRoad => '🛣',
      ExpenseCategory.wash => '💧',
      ExpenseCategory.carCare => '🧽',
      ExpenseCategory.accessories => '🔧',
      ExpenseCategory.taxes => '🏛',
      ExpenseCategory.insurance => '📋',
      ExpenseCategory.other => '📝',
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
