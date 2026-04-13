import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/domain/entities/expense_entity.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<ExpenseCategory, double> amountByCategory;
  final double totalAmount;

  const CategoryPieChart({
    super.key,
    required this.amountByCategory,
    required this.totalAmount,
  });

  static const _categoryColors = <ExpenseCategory, Color>{
    ExpenseCategory.fuel: Color(0xFF2196F3),
    ExpenseCategory.parking: Color(0xFF9C27B0),
    ExpenseCategory.fines: Color(0xFFE53935),
    ExpenseCategory.tollRoad: Color(0xFFFF9800),
    ExpenseCategory.wash: Color(0xFF00BCD4),
    ExpenseCategory.carCare: Color(0xFF4CAF50),
    ExpenseCategory.accessories: Color(0xFF795548),
    ExpenseCategory.taxes: Color(0xFFFFC107),
    ExpenseCategory.insurance: Color(0xFF3F51B5),
    ExpenseCategory.other: Color(0xFF757575),
  };

  @override
  Widget build(BuildContext context) {
    if (amountByCategory.isEmpty) return const SizedBox.shrink();

    final sorted = amountByCategory.entries.toList()
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
            'Расходы по категориям',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(
                width: 120.w,
                height: 120.w,
                child: CustomPaint(
                  painter: _PieChartPainter(
                    entries: sorted,
                    colors: _categoryColors,
                    total: totalAmount,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sorted.take(5).map((entry) {
                    final percent = totalAmount > 0
                        ? (entry.value / totalAmount * 100)
                        : 0.0;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: _categoryColors[entry.key] ??
                                  AppColors.textSecondaryLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              entry.key.label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textPrimaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${percent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<ExpenseCategory, double>> entries;
  final Map<ExpenseCategory, Color> colors;
  final double total;

  _PieChartPainter({
    required this.entries,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.35;
    final drawRadius = radius - strokeWidth / 2;

    double startAngle = -math.pi / 2;

    for (final entry in entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[entry.key] ?? Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: drawRadius),
        startAngle,
        sweepAngle - 0.02,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      entries != oldDelegate.entries || total != oldDelegate.total;
}
