import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class MonthlyBarChart extends StatelessWidget {
  final Map<int, double> amountByMonth;
  final int selectedMonth;

  const MonthlyBarChart({
    super.key,
    required this.amountByMonth,
    required this.selectedMonth,
  });

  static const _monthLabels = [
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ];

  @override
  Widget build(BuildContext context) {
    final maxAmount = amountByMonth.values.fold<double>(
      0,
      (max, v) => v > max ? v : max,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Расходы по месяцам',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 140.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (index) {
                final month = index + 1;
                final amount = amountByMonth[month] ?? 0;
                final fraction = maxAmount > 0 ? (amount / maxAmount) : 0.0;
                final isSelected = month == selectedMonth;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (amount > 0)
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Text(
                              _formatCompact(amount),
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          height: fraction > 0
                              ? (fraction * 90.h).clamp(4.h, 90.h)
                              : 4.h,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : amount > 0
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.divider,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          _monthLabels[index],
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
