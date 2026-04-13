import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../garage/domain/entities/car_entity.dart';

class CarExpensesList extends StatelessWidget {
  final Map<String, double> amountByCar;
  final List<CarEntity> cars;
  final double totalAmount;

  const CarExpensesList({
    super.key,
    required this.amountByCar,
    required this.cars,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (amountByCar.isEmpty) return const SizedBox.shrink();

    final numberFormat = NumberFormat('#,###', 'ru_RU');
    final sorted = amountByCar.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
            'Расходы по автомобилям',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.h),
          ...sorted.map((entry) {
            final car =
                cars.where((c) => c.id == entry.key).firstOrNull;
            final carName = car?.fullName ?? 'Неизвестный';
            final percent =
                totalAmount > 0 ? (entry.value / totalAmount * 100) : 0.0;

            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          carName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${numberFormat.format(entry.value.toInt())} ₽',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.r),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: AppColors.divider,
                      color: AppColors.primary,
                      minHeight: 6.h,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${percent.toStringAsFixed(1)}% от общих расходов',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
